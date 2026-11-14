import 'package:flame_audio/flame_audio.dart';

abstract interface class GameSoundEffects {
  Future<void> load();

  Future<void> playPlacement({required bool isCombo});

  Future<void> playGameOver();
}

class FlameGameSoundEffects implements GameSoundEffects {
  static const _sounds = ['placement.wav', 'combo.wav', 'game_over.wav'];

  @override
  Future<void> load() async {
    await FlameAudio.audioCache.loadAll(_sounds);
  }

  @override
  Future<void> playPlacement({required bool isCombo}) async {
    await FlameAudio.play(isCombo ? 'combo.wav' : 'placement.wav');
  }

  @override
  Future<void> playGameOver() async {
    await FlameAudio.play('game_over.wav');
  }
}
