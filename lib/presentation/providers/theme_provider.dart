import 'package:flutter/material.dart';

import '../../domain/repositories/settings_repository.dart';

class ThemeProvider extends ChangeNotifier {
  final SettingsRepository settingsRepository;
  bool _isDarkMode = false;

  ThemeProvider(this.settingsRepository) {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> _loadTheme() async {
    _isDarkMode = await settingsRepository.getDarkMode();
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    await settingsRepository.setDarkMode(value);
  }

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFBB86FC),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFBB86FC),
          secondary: Color(0xFF03DAC6),
          surface: Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 2,
        ),
      );

  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF3F51B5),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF3F51B5),
          secondary: Color(0xFF7986CB),
          surface: Color(0xFFFFFFFF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3F51B5),
          elevation: 2,
          foregroundColor: Colors.white,
        ),
      );
}
