import 'package:hive/hive.dart';

abstract interface class GameSettingsStore {
  Future<bool> loadSoundEnabled();

  Future<void> saveSoundEnabled(bool enabled);
}

class HiveGameSettingsStore implements GameSettingsStore {
  HiveGameSettingsStore(this._box);

  static const _soundEnabledKey = 'soundEnabled';

  final Box<bool> _box;

  @override
  Future<bool> loadSoundEnabled() async => _box.get(_soundEnabledKey) ?? true;

  @override
  Future<void> saveSoundEnabled(bool enabled) =>
      _box.put(_soundEnabledKey, enabled);
}
