import 'dart:io';
import 'dart:ui' show Size;

import 'package:cyber_stack/audio/game_sound_effects.dart';
import 'package:cyber_stack/games/cyber_stack_game.dart';
import 'package:cyber_stack/storage/game_settings_store.dart';
import 'package:cyber_stack/main.dart' as app;
import 'package:cyber_stack/storage/high_score_store.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class FakeHighScoreStore implements HighScoreStore {
  FakeHighScoreStore([this.highScore = 0]);

  int highScore;

  @override
  Future<int> loadHighScore() async => highScore;

  @override
  Future<void> saveHighScore(int score) async {
    if (score > highScore) {
      highScore = score;
    }
  }
}

class FakeGameSoundEffects implements GameSoundEffects {
  final playedSounds = <String>[];

  @override
  Future<void> load() async {}

  @override
  Future<void> playPlacement({required bool isCombo}) async {
    playedSounds.add(isCombo ? 'combo' : 'placement');
  }

  @override
  Future<void> playGameOver() async {
    playedSounds.add('game_over');
  }
}

class FakeGameSettingsStore implements GameSettingsStore {
  FakeGameSettingsStore({this.soundEnabled = true});

  bool soundEnabled;

  @override
  Future<bool> loadSoundEnabled() async => soundEnabled;

  @override
  Future<void> saveSoundEnabled(bool enabled) async {
    soundEnabled = enabled;
  }
}

Future<CyberStackGame> loadGame(
  WidgetTester tester, {
  required Size viewportSize,
  HighScoreStore? highScoreStore,
  GameSoundEffects? soundEffects,
  bool soundEnabled = true,
}) async {
  tester.view
    ..physicalSize = viewportSize
    ..devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final game = CyberStackGame(
    highScoreStore: highScoreStore ?? FakeHighScoreStore(),
    soundEffects: soundEffects ?? FakeGameSoundEffects(),
    soundEnabled: soundEnabled,
  );
  await tester.pumpWidget(GameWidget(game: game));
  await game.toBeLoaded();
  await tester.pump();
  game.pauseEngine();
  return game;
}

void main() {
  test('Hive stores high scores and sound preferences', () async {
    final directory = await Directory.systemTemp.createTemp(
      'cyber-stack-high-score-',
    );
    try {
      Hive.init(directory.path);
      final box = await Hive.openBox<int>('high_score_test');
      final store = HiveHighScoreStore(box);

      expect(await store.loadHighScore(), 0);
      await store.saveHighScore(12);
      await store.saveHighScore(7);
      expect(await store.loadHighScore(), 12);

      await box.close();
      final settingsBox = await Hive.openBox<bool>('settings_test');
      final settingsStore = HiveGameSettingsStore(settingsBox);
      expect(await settingsStore.loadSoundEnabled(), isTrue);
      await settingsStore.saveSoundEnabled(false);
      expect(await settingsStore.loadSoundEnabled(), isFalse);
      await settingsBox.close();
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });

  testWidgets('loads the game and mounts the initial score component', (
    tester,
  ) async {
    final game = await loadGame(tester, viewportSize: const Size(800, 600));
    final baseX = (game.size.x - game.blockWidth) / 2;

    expect(
      find.byWidgetPredicate((widget) => widget is GameWidget),
      findsOneWidget,
    );
    expect(game.children.contains(game.scoreText), isTrue);
    expect(game.children.contains(game.highScoreText), isTrue);
    expect(game.children.contains(game.comboText), isTrue);
    expect(game.scoreText.text, 'SCORE: 0');
    expect(game.highScoreText.text, 'BEST: 0');
    expect(game.comboText.text, 'COMBO: 0');
    expect(game.isStarted, isFalse);
    expect(game.isGameOver, isFalse);
    expect(game.blockX, baseX);
  });

  testWidgets('loads and persists the high score', (tester) async {
    final store = FakeHighScoreStore();
    final game = await loadGame(
      tester,
      viewportSize: const Size(800, 600),
      highScoreStore: store,
    );
    game.lockMovingBlock();

    expect(game.score, 2);
    expect(game.highScore, 2);
    expect(game.highScoreText.text, 'BEST: 2');
    expect(store.highScore, 2);

    final nextGame = await loadGame(
      tester,
      viewportSize: const Size(800, 600),
      highScoreStore: store,
    );
    expect(nextGame.highScore, 2);
    expect(nextGame.highScoreText.text, 'BEST: 2');
  });

  testWidgets('centered placements grow the combo bonus', (tester) async {
    final game = await loadGame(tester, viewportSize: const Size(800, 600));
    final baseX = (game.size.x - game.blockWidth) / 2;

    game
      ..blockX = baseX + 2
      ..movingBlock.position.x = baseX + 2
      ..lockMovingBlock();

    expect(game.combo, 1);
    expect(game.score, 2);
    expect(game.comboText.text, 'COMBO: 1 (+1 BONUS)');
    final firstPlacedBlock = game.children
        .whereType<RectangleComponent>()
        .firstWhere(
          (block) => block.position.y == game.size.y - 2 * game.blockHeight,
        );
    expect(firstPlacedBlock.position.x, baseX);

    game
      ..blockX = baseX
      ..movingBlock.position.x = baseX
      ..lockMovingBlock();

    expect(game.combo, 2);
    expect(game.score, 5);
    expect(game.comboText.text, 'COMBO: 2 (+2 BONUS)');

    game
      ..blockX = baseX + 90
      ..movingBlock.position.x = baseX + 90
      ..lockMovingBlock();

    expect(game.combo, 0);
    expect(game.score, 6);
    expect(game.comboText.text, 'COMBO: 0');
  });

  testWidgets('plays placement, combo, and game-over feedback', (tester) async {
    final soundEffects = FakeGameSoundEffects();
    final game = await loadGame(
      tester,
      viewportSize: const Size(800, 600),
      soundEffects: soundEffects,
    );
    final baseX = (game.size.x - game.blockWidth) / 2;

    game.lockMovingBlock();
    game
      ..blockX = baseX + 90
      ..movingBlock.position.x = baseX + 90
      ..lockMovingBlock();
    game
      ..blockX = 0
      ..movingBlock.position.x = 0
      ..lockMovingBlock();
    await tester.pump();

    expect(soundEffects.playedSounds, ['combo', 'placement', 'game_over']);
  });

  testWidgets('pause button pauses and resumes the game', (tester) async {
    await tester.pumpWidget(
      app.CyberStackApp(
        highScoreStore: FakeHighScoreStore(),
        soundEffects: FakeGameSoundEffects(),
        settingsStore: FakeGameSettingsStore(),
        soundEnabled: true,
      ),
    );
    final gameWidget = tester.widget<GameWidget<CyberStackGame>>(
      find.byType(GameWidget<CyberStackGame>),
    );
    final game = gameWidget.game!;
    await game.toBeLoaded();
    game.isStarted = true;
    final startingX = game.blockX;

    await tester.tap(find.byTooltip('Pause game'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(game.isPaused, isTrue);
    expect(game.blockX, startingX);

    await tester.tap(find.byTooltip('Resume game'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(game.isPaused, isFalse);
    expect(game.blockX, greaterThan(startingX));
  });

  testWidgets('sound button toggles audio and saves the preference', (
    tester,
  ) async {
    final settingsStore = FakeGameSettingsStore();
    final soundEffects = FakeGameSoundEffects();
    await tester.pumpWidget(
      app.CyberStackApp(
        highScoreStore: FakeHighScoreStore(),
        soundEffects: soundEffects,
        settingsStore: settingsStore,
        soundEnabled: true,
      ),
    );
    final gameWidget = tester.widget<GameWidget<CyberStackGame>>(
      find.byType(GameWidget<CyberStackGame>),
    );
    final game = gameWidget.game!;
    await game.toBeLoaded();

    await tester.tap(find.byTooltip('Mute sound'));
    await tester.pump();
    expect(game.soundEnabled, isFalse);
    expect(settingsStore.soundEnabled, isFalse);

    game.lockMovingBlock();
    await tester.pump();
    expect(soundEffects.playedSounds, isEmpty);

    await tester.tap(find.byTooltip('Enable sound'));
    await tester.pump();
    expect(game.soundEnabled, isTrue);
    expect(settingsStore.soundEnabled, isTrue);

    final baseX = (game.size.x - game.blockWidth) / 2;
    game
      ..blockX = baseX
      ..movingBlock.position.x = baseX
      ..lockMovingBlock();
    await tester.pump();
    expect(soundEffects.playedSounds, ['combo']);
  });

  testWidgets('the first tap starts the game without ending it', (
    tester,
  ) async {
    final game = await loadGame(tester, viewportSize: const Size(800, 600));

    await tester.tap(find.byWidgetPredicate((widget) => widget is GameWidget));
    await tester.pump(const Duration(milliseconds: 50));

    expect(game.isStarted, isTrue);
    expect(game.isGameOver, isFalse);
    expect(game.score, 0);
  });

  testWidgets('trims a partially overlapping block and increments the score', (
    tester,
  ) async {
    final game = await loadGame(tester, viewportSize: const Size(800, 600));
    final baseX = (game.size.x - game.blockWidth) / 2;
    game
      ..blockX = baseX + 90
      ..movingBlock.position.x = baseX + 90;

    game.lockMovingBlock();

    expect(game.score, 1);
    expect(game.blockWidth, 30);
    expect(game.movingBlock.size.x, 30);
    final trimmedBlock = game.children
        .whereType<RectangleComponent>()
        .firstWhere((block) => block.size.x == 30);
    expect(trimmedBlock.position.x, baseX + 90);
    expect(game.movingRight, isFalse);
    expect(game.blockX, game.size.x - game.blockWidth);
    expect(game.isGameOver, isFalse);
  });

  testWidgets('ends the game when a block misses the stack', (tester) async {
    final game = await loadGame(tester, viewportSize: const Size(800, 600));
    game.blockX = 0;

    game.lockMovingBlock();

    expect(game.score, 0);
    expect(game.isGameOver, isTrue);
  });

  testWidgets('clamps movement delta and caps the speed', (tester) async {
    final game = await loadGame(tester, viewportSize: const Size(800, 2000));

    game.isStarted = true;
    game.update(1);
    expect(game.blockX, (game.size.x - game.blockWidth) / 2 + 20);

    final baseX = (game.size.x - game.blockWidth) / 2;
    for (var i = 0; i < 30; i++) {
      game
        ..blockX = baseX
        ..movingBlock.position.x = baseX
        ..lockMovingBlock();
    }

    expect(game.speed, 600);
  });

  testWidgets('keeps the moving block inside a narrow viewport', (
    tester,
  ) async {
    final game = await loadGame(tester, viewportSize: const Size(100, 300));

    game.isStarted = true;
    game.update(1);

    expect(game.blockWidth, 100);
    expect(game.blockX, 0);
    expect(game.movingBlock.position.x, 0);
  });

  testWidgets('resizing the viewport does not end the game', (tester) async {
    final game = await loadGame(tester, viewportSize: const Size(800, 600));

    game.onGameResize(Vector2(game.size.x, game.size.y - 100));

    expect(game.isGameOver, isFalse);
    expect(game.movingBlock.position.y, greaterThanOrEqualTo(0));
    expect(
      game.movingBlock.position.y + game.blockHeight,
      lessThanOrEqualTo(game.size.y),
    );
  });

  testWidgets('tapping after game over restarts the game', (tester) async {
    final game = await loadGame(tester, viewportSize: const Size(800, 600));
    game
      ..blockX = 0
      ..movingBlock.position.x = 0
      ..lockMovingBlock();
    expect(game.isGameOver, isTrue);

    await tester.tap(find.byWidgetPredicate((widget) => widget is GameWidget));
    await tester.pump(const Duration(milliseconds: 50));

    expect(game.isGameOver, isFalse);
    expect(game.score, 0);
    expect(game.scoreText.text, 'SCORE: 0');
    expect(game.blockX, (game.size.x - game.blockWidth) / 2);
  });

  testWidgets('ends the game when the stack reaches the top', (tester) async {
    final game = await loadGame(tester, viewportSize: const Size(800, 200));
    final baseX = (game.size.x - game.blockWidth) / 2;

    for (var i = 0; i < 4; i++) {
      game
        ..blockX = baseX
        ..movingBlock.position.x = baseX
        ..lockMovingBlock();
    }

    expect(game.isGameOver, isTrue);
  });
}
