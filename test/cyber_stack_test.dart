import 'dart:ui' show Size;

import 'package:cyber_stack/games/cyber_stack_game.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

Future<CyberStackGame> loadGame(
  WidgetTester tester, {
  required Size viewportSize,
}) async {
  tester.view
    ..physicalSize = viewportSize
    ..devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final game = CyberStackGame();
  await tester.pumpWidget(GameWidget(game: game));
  await game.toBeLoaded();
  await tester.pump();
  game.pauseEngine();
  return game;
}

void main() {
  testWidgets('loads the game and mounts the initial score component', (
    tester,
  ) async {
    final game = await loadGame(tester, viewportSize: const Size(800, 600));

    expect(
      find.byWidgetPredicate((widget) => widget is GameWidget),
      findsOneWidget,
    );
    expect(game.children.contains(game.scoreText), isTrue);
    expect(game.scoreText.text, 'SCORE: 0');
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

    game.update(1);
    expect(game.blockX, 20);

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

    game.update(1);

    expect(game.blockWidth, 100);
    expect(game.blockX, 0);
    expect(game.movingBlock.position.x, 0);
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
