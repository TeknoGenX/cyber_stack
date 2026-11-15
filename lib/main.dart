import 'dart:async';

import 'package:flame/game.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'audio/game_sound_effects.dart';
import 'games/cyber_stack_game.dart';
import 'storage/game_settings_store.dart';
import 'storage/high_score_store.dart';

Future<void> main() async {
  // Pastikan binding Flutter terinisialisasi sebelum menjalankan engine game
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final highScoreBox = await Hive.openBox<int>('cyber_stack');
  final settingsStore = HiveGameSettingsStore(
    await Hive.openBox<bool>('cyber_stack_settings'),
  );
  final soundEnabled = await settingsStore.loadSoundEnabled();
  runApp(
    CyberStackApp(
      highScoreStore: HiveHighScoreStore(highScoreBox),
      soundEffects: FlameGameSoundEffects(),
      settingsStore: settingsStore,
      soundEnabled: soundEnabled,
    ),
  );
}

class CyberStackApp extends StatelessWidget {
  const CyberStackApp({
    super.key,
    required this.highScoreStore,
    required this.soundEffects,
    required this.settingsStore,
    required this.soundEnabled,
  });

  final HighScoreStore highScoreStore;
  final GameSoundEffects soundEffects;
  final GameSettingsStore settingsStore;
  final bool soundEnabled;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyber Stack - Neon Drop',
      debugShowCheckedModeBanner: false,
      // Menggunakan tema gelap Material 3 yang cocok dengan nuansa cyberpunk
      theme: ThemeData.dark(useMaterial3: true),
      home: GameScreen(
        highScoreStore: highScoreStore,
        soundEffects: soundEffects,
        settingsStore: settingsStore,
        soundEnabled: soundEnabled,
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.highScoreStore,
    required this.soundEffects,
    required this.settingsStore,
    required this.soundEnabled,
  });

  final HighScoreStore highScoreStore;
  final GameSoundEffects soundEffects;
  final GameSettingsStore settingsStore;
  final bool soundEnabled;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final CyberStackGame _game;

  @override
  void initState() {
    super.initState();
    _soundEnabled = widget.soundEnabled;
    _game = CyberStackGame(
      highScoreStore: widget.highScoreStore,
      soundEffects: widget.soundEffects,
      soundEnabled: widget.soundEnabled,
    );
  }

  void _togglePause() {
    setState(() {
      if (_game.isPaused) {
        _game.resumeGame();
      } else {
        _game.pauseGame();
      }
    });
  }

  late bool _soundEnabled;

  void _toggleSound() {
    final enabled = !_soundEnabled;
    setState(() => _soundEnabled = enabled);
    _game.soundEnabled = enabled;
    unawaited(_saveSoundSetting(enabled));
  }

  Future<void> _saveSoundSetting(bool enabled) async {
    try {
      await widget.settingsStore.saveSoundEnabled(enabled);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'cyber_stack',
          context: ErrorDescription('while saving sound settings'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _game)),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.filledTonal(
                      onPressed: _togglePause,
                      tooltip: _game.isPaused ? 'Resume game' : 'Pause game',
                      icon: Icon(
                        _game.isPaused ? Icons.play_arrow : Icons.pause,
                      ),
                    ),
                    const SizedBox(height: 8),
                    IconButton.filledTonal(
                      onPressed: _toggleSound,
                      tooltip: _soundEnabled ? 'Mute sound' : 'Enable sound',
                      icon: Icon(
                        _soundEnabled ? Icons.volume_up : Icons.volume_off,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_game.isPaused) ...[
            // Dimmed overlay background
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.65),
              ),
            ),
            // Cyberpunk Game Paused Modal Dialog
            Center(
              child: Container(
                width: 290,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D121F),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.cyanAccent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.35),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'GAME PAUSED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 26),
                    // RESUME Button (Solid Neon Cyan)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _game.resumeGame();
                          });
                        },
                        child: const Text(
                          'RESUME',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // RESTART Button (Outlined Neon Cyan)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.cyanAccent,
                          side: const BorderSide(
                            color: Colors.cyanAccent,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _game.restart();
                          });
                        },
                        child: const Text(
                          'RESTART',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
