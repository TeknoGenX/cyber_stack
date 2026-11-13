import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';

class CyberStackGame extends FlameGame with TapCallbacks {
  static const double _initialBlockWidth = 120;
  static const double _maximumBlockHeight = 40;
  static const double _initialSpeed = 200;
  static const double _speedIncrement = 15;
  static const double _maximumSpeed = 600;

  late TextComponent scoreText;
  late RectangleComponent movingBlock;
  late RectangleComponent _baseBlock;
  late RectangleComponent _topBlock;
  final List<RectangleComponent> _stackBlocks = [];

  int score = 0;
  bool isGameOver = false;
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

    blockWidth = math.min(_initialBlockWidth, size.x).toDouble();
    blockHeight = math.min(_maximumBlockHeight, size.y / 2).toDouble();

    final baseX = (size.x - blockWidth) / 2;
    final baseY = size.y - blockHeight;
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
    for (final stackBlock in _stackBlocks) {
      stackBlock.size.x = math
          .min(stackBlock.size.x, availableWidth)
          .toDouble();
      stackBlock.position.x = stackBlock.position.x
          .clamp(0.0, math.max(0.0, availableWidth - stackBlock.size.x))
          .toDouble();
    }
    blockWidth = math.min(blockWidth, availableWidth).toDouble();
    movingBlock.size.x = blockWidth;
    blockX = blockX.clamp(0.0, math.max(0.0, size.x - blockWidth)).toDouble();
    movingBlock.position.x = blockX;

    if (_topBlock.position.y <= 0 ||
        _baseBlock.position.y + blockHeight > size.y) {
      _endGame();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_isInitialized || isGameOver) {
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
    lockMovingBlock();
  }

  void lockMovingBlock() {
    if (isGameOver) {
      return;
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

    score++;
    scoreText.text = 'SCORE: $score';
    speed = math.min(speed + _speedIncrement, _maximumSpeed).toDouble();

    final nextBlockY = movingBlock.position.y - blockHeight;
    if (nextBlockY < 0 || movingBlock.position.y <= 0) {
      _endGame();
      return;
    }

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
    add(
      TextComponent(
        text: 'GAME OVER',
        anchor: Anchor.center,
        position: size / 2,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
