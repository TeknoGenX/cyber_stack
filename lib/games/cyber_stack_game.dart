import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';

import '../audio/game_sound_effects.dart';
import '../storage/high_score_store.dart';

class CyberStackGame extends FlameGame with TapCallbacks {
  static const double _initialBlockWidth = 120;
  static const double _maximumBlockHeight = 40;
  static const double _perfectAlignmentTolerance = 3;
  static const double _initialSpeed = 200;
  static const double _speedIncrement = 15;
  static const double _maximumSpeed = 600;

  CyberStackGame({
    required this._highScoreStore,
    required this._soundEffects,
    this.soundEnabled = true,
  });

  final HighScoreStore _highScoreStore;
  final GameSoundEffects _soundEffects;

  late TextComponent scoreText;
  late TextComponent highScoreText;
  late TextComponent comboText;
  late RectangleComponent movingBlock;
  late RectangleComponent _baseBlock;
  late RectangleComponent _topBlock;
  final List<RectangleComponent> _stackBlocks = [];
  late TextComponent _startText;
  TextComponent? _pauseText;
  TextComponent? _gameOverText;

  int score = 0;
  int highScore = 0;
  int combo = 0;
  bool isStarted = false;
  bool isPaused = false;
  bool isGameOver = false;
  bool soundEnabled;
  double blockX = 0;
  double blockY = 0;
  double blockWidth = _initialBlockWidth;
  double blockHeight = _maximumBlockHeight;
  double speed = _initialSpeed;
  bool movingRight = true;
  bool _isInitialized = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    highScore = await _highScoreStore.loadHighScore();
    try {
      await _soundEffects.load();
    } catch (error, stackTrace) {
      _reportSoundError(error, stackTrace);
    }

    blockWidth = math.min(_initialBlockWidth, size.x).toDouble();
    blockHeight = math.min(_maximumBlockHeight, size.y / 2).toDouble();

    final baseX = (size.x - blockWidth) / 2;
    final baseY = size.y - blockHeight;
    blockX = baseX;
    blockY = baseY - blockHeight;

    scoreText = TextComponent(
      text: 'SCORE: 0',
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.cyanAccent,
          fontSize: 26,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
    highScoreText = TextComponent(
      text: 'BEST: $highScore',
      position: Vector2(20, 54),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
    comboText = TextComponent(
      text: 'COMBO: 0',
      position: Vector2(20, 80),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.amberAccent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
    _startText = _createCenterText('TAP TO START', Colors.cyanAccent);

    _baseBlock = _createBlock(
      x: baseX,
      y: baseY,
      width: blockWidth,
      color: Colors.cyanAccent,
    );
    _topBlock = _baseBlock;
    _stackBlocks.add(_baseBlock);
    movingBlock = _createBlock(
      x: blockX,
      y: blockY,
      width: blockWidth,
      color: Colors.purpleAccent,
    );

    add(scoreText);
    add(highScoreText);
    add(comboText);
    add(_startText);
    add(_baseBlock);
    add(movingBlock);
    _isInitialized = true;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!_isInitialized) {
      return;
    }

    final availableWidth = math.max(0.0, size.x).toDouble();
    final baseWidth = math.min(_initialBlockWidth, availableWidth).toDouble();
    final baseX = (availableWidth - baseWidth) / 2;
    final horizontalOffset = baseX - _baseBlock.position.x;

    _baseBlock
      ..size.x = baseWidth
      ..position.x = baseX;

    for (var i = 1; i < _stackBlocks.length; i++) {
      final stackBlock = _stackBlocks[i];
      stackBlock.size.x = math
          .min(stackBlock.size.x, availableWidth)
          .toDouble();
      stackBlock.position.x = (stackBlock.position.x + horizontalOffset)
          .clamp(0.0, math.max(0.0, availableWidth - stackBlock.size.x))
          .toDouble();
    }

    final visibleBlockCount = _stackBlocks.length + (isGameOver ? 0 : 1);
    blockHeight = math
        .min(_maximumBlockHeight, size.y / visibleBlockCount)
        .toDouble();
    final baseY = size.y - blockHeight;
    for (var i = 0; i < _stackBlocks.length; i++) {
      _stackBlocks[i]
        ..size.y = blockHeight
        ..position.y = baseY - i * blockHeight;
    }

    blockWidth = math.min(_topBlock.size.x, availableWidth).toDouble();
    if (!isGameOver) {
      blockY = baseY - _stackBlocks.length * blockHeight;
      blockX = (blockX + horizontalOffset)
          .clamp(0.0, math.max(0.0, availableWidth - blockWidth))
          .toDouble();
      movingBlock
        ..size.x = blockWidth
        ..size.y = blockHeight
        ..position.x = blockX
        ..position.y = blockY;
    }

    if (!isStarted) {
      _startText.position = size / 2;
    }
    final gameOverText = _gameOverText;
    if (gameOverText != null) {
      gameOverText.position = size / 2;
    }
    final pauseText = _pauseText;
    if (pauseText != null) {
      pauseText.position = size / 2;
    }
  }

  @override
  void update(double dt) {
    if (isPaused) {
      return;
    }
    super.update(dt);
    if (!_isInitialized || !isStarted || isGameOver) {
      return;
    }

    final safeDt = dt > 0.1 ? 0.1 : (dt < 0 ? 0.0 : dt);
    final maxBlockX = math.max(0.0, size.x - blockWidth).toDouble();
    final direction = movingRight ? 1.0 : -1.0;
    blockX += speed * safeDt * direction;
    blockX = blockX.clamp(0.0, maxBlockX).toDouble();

    if (blockX >= maxBlockX) {
      movingRight = false;
    } else if (blockX <= 0) {
      movingRight = true;
    }
    movingBlock.position.x = blockX;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (isPaused) {
      return;
    }
    if (isGameOver) {
      restart();
    } else if (!isStarted) {
      isStarted = true;
      _startText.removeFromParent();
    } else {
      lockMovingBlock();
    }
  }

  void pauseGame() {
    if (!isStarted || isPaused || isGameOver) {
      return;
    }
    isPaused = true;
  }

  void resumeGame() {
    if (!isPaused) {
      return;
    }
    isPaused = false;
    _pauseText?.removeFromParent();
    _pauseText = null;
  }

  void restart() {
    if (!isGameOver && !isPaused) {
      return;
    }

    final placedBlocks = _stackBlocks.skip(1).toSet();
    if (!placedBlocks.contains(movingBlock)) {
      placedBlocks.add(movingBlock);
    }
    for (final block in placedBlocks) {
      block.removeFromParent();
    }
    _gameOverText?.removeFromParent();
    _gameOverText = null;
    _pauseText?.removeFromParent();
    _pauseText = null;
    _startText = _createCenterText('TAP TO START', Colors.cyanAccent);
    add(_startText);

    score = 0;
    combo = 0;
    speed = _initialSpeed;
    isStarted = false;
    isPaused = false;
    isGameOver = false;
    movingRight = true;
    blockWidth = math.min(_initialBlockWidth, size.x).toDouble();
    blockHeight = math.min(_maximumBlockHeight, size.y / 2).toDouble();
    blockX = (size.x - blockWidth) / 2;
    blockY = size.y - 2 * blockHeight;
    scoreText.text = 'SCORE: 0';
    comboText.text = 'COMBO: 0';

    _baseBlock
      ..size.x = blockWidth
      ..size.y = blockHeight
      ..position.x = blockX
      ..position.y = size.y - blockHeight;
    _stackBlocks
      ..clear()
      ..add(_baseBlock);
    _topBlock = _baseBlock;
    movingBlock = _createBlock(
      x: blockX,
      y: blockY,
      width: blockWidth,
      color: Colors.purpleAccent,
    );
    add(movingBlock);
  }

  void lockMovingBlock() {
    if (isGameOver || isPaused) {
      return;
    }

    final centerOffset =
        blockX + blockWidth / 2 - (_topBlock.position.x + _topBlock.size.x / 2);
    final perfectTolerance = math.min(
      _perfectAlignmentTolerance,
      math.min(blockWidth, _topBlock.size.x) / 2,
    );
    final isPerfect = centerOffset.abs() <= perfectTolerance;
    if (isPerfect) {
      blockX = _topBlock.position.x + (_topBlock.size.x - blockWidth) / 2;
      movingBlock.position.x = blockX;
    }

    final overlapLeft = math.max(blockX, _topBlock.position.x).toDouble();
    final overlapRight = math
        .min(blockX + blockWidth, _topBlock.position.x + _topBlock.size.x)
        .toDouble();
    final overlapWidth = overlapRight - overlapLeft;

    if (overlapWidth <= 0) {
      _endGame();
      return;
    }

    movingBlock
      ..position.x = overlapLeft
      ..size.x = overlapWidth;
    blockX = overlapLeft;
    blockWidth = overlapWidth;
    _topBlock = movingBlock;
    _stackBlocks.add(movingBlock);

    combo = isPerfect ? combo + 1 : 0;
    final pointsEarned = 1 + combo;
    score += pointsEarned;
    scoreText.text = 'SCORE: $score';
    comboText.text = combo == 0 ? 'COMBO: 0' : 'COMBO: $combo (+$combo BONUS)';
    if (score > highScore) {
      highScore = score;
      highScoreText.text = 'BEST: $highScore';
      unawaited(_persistHighScore(score));
    }
    speed = math.min(speed + _speedIncrement, _maximumSpeed).toDouble();

    final nextBlockY = movingBlock.position.y - blockHeight;
    if (nextBlockY < 0 || movingBlock.position.y <= 0) {
      _endGame();
      return;
    }

    _playSound(() => _soundEffects.playPlacement(isCombo: combo > 0));
    blockY = nextBlockY;
    movingRight = !movingRight;
    final maxBlockX = math.max(0.0, size.x - blockWidth).toDouble();
    blockX = movingRight ? 0.0 : maxBlockX;
    movingBlock = _createBlock(
      x: blockX,
      y: blockY,
      width: blockWidth,
      color: Colors.purpleAccent,
    );
    add(movingBlock);
  }

  RectangleComponent _createBlock({
    required double x,
    required double y,
    required double width,
    required Color color,
  }) {
    return RectangleComponent(
      position: Vector2(x, y),
      size: Vector2(width, blockHeight),
      paint: Paint()..color = color,
    );
  }

  void _endGame() {
    if (isGameOver) {
      return;
    }

    isGameOver = true;
    _playSound(_soundEffects.playGameOver);
    _gameOverText = _createCenterText(
      'GAME OVER\nTAP TO RESTART',
      Colors.redAccent,
    );
    add(_gameOverText!);
  }

  TextComponent _createCenterText(String text, Color color) {
    return TextComponent(
      text: text,
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: TextStyle(
          color: color,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _persistHighScore(int value) async {
    try {
      await _highScoreStore.saveHighScore(value);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'cyber_stack',
          context: ErrorDescription('while saving the high score'),
        ),
      );
    }
  }

  void _playSound(Future<void> Function() play) {
    if (!soundEnabled) {
      return;
    }
    unawaited(() async {
      try {
        await play();
      } catch (error, stackTrace) {
        _reportSoundError(error, stackTrace);
      }
    }());
  }

  void _reportSoundError(Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'cyber_stack',
        context: ErrorDescription('while loading or playing game audio'),
      ),
    );
  }
}
