import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_create/providers/sound_provider.dart';
import 'package:word_create/providers/theme_provider.dart';
import 'screens/settings/settings_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SoundProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Word Puzzle Game',
      theme: themeProvider.currentTheme,
      home: const SettingsScreen(),
    );
  }
}