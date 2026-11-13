import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';

import 'games/cyber_stack_game.dart';

void main() {
  // Pastikan binding Flutter terinisialisasi sebelum menjalankan engine game
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CyberStackApp());
}

class CyberStackApp extends StatelessWidget {
  const CyberStackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyber Stack - Neon Drop',
      debugShowCheckedModeBanner: false,
      // Menggunakan tema gelap Material 3 yang cocok dengan nuansa cyberpunk
      theme: ThemeData.dark(useMaterial3: true),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // GameWidget memuat kelas utama Flame Game yang akan kita buat
      body: GameWidget(game: CyberStackGame()),
    );
  }
}
