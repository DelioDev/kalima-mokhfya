import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_create/providers/sound_provider.dart';
import 'package:word_create/providers/theme_provider.dart';
import 'package:word_create/services/game_progress.dart';
import 'screens/game/game_screen.dart';
import 'screens/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Load saved progress before running app
  final progress = await GameProgress.loadProgress();
  final startLevel = progress['level'] ?? 1;
  final startLanguage = progress['language'] ?? 'ar';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SoundProvider()),
      ],
      child: MyApp(
        startLevel: startLevel,
        startLanguage: startLanguage,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final int startLevel;
  final String startLanguage;

  const MyApp({
    super.key,
    required this.startLevel,
    required this.startLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Word Puzzle Game',
      theme: themeProvider.currentTheme,
      home: 
      SettingsScreen(
        startLevel: startLevel,
        startLanguage: startLanguage,
      ),
    );
  }
}
