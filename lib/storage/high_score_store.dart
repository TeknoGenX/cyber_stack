import 'package:hive/hive.dart';

abstract interface class HighScoreStore {
  Future<int> loadHighScore();

  Future<void> saveHighScore(int score);
}

class HiveHighScoreStore implements HighScoreStore {
  HiveHighScoreStore(this._box);

  static const _highScoreKey = 'highScore';

  final Box<int> _box;

  @override
  Future<int> loadHighScore() async => _box.get(_highScoreKey) ?? 0;

  @override
  Future<void> saveHighScore(int score) async {
    final currentHighScore = _box.get(_highScoreKey) ?? 0;
    if (score > currentHighScore) {
      await _box.put(_highScoreKey, score);
    }
  }
}
