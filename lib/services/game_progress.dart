import 'package:shared_preferences/shared_preferences.dart';

class GameProgress {
  static const _levelKey = 'currentLevel';
  static const _langKey = 'currentLanguage';

  /// Save the player’s current progress
  static Future<void> saveProgress(int level, String language, Set<String> foundWords) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_levelKey, level);
    await prefs.setString(_langKey, language);
  }

  /// Load saved progress, or return defaults
  static Future<Map<String, dynamic>> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    int level = prefs.getInt(_levelKey) ?? 1;
    String lang = prefs.getString(_langKey) ?? 'ar';
    return {'level': level, 'language': lang};
  }

  /// Reset progress (optional)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_levelKey);
    await prefs.remove(_langKey);
  }
}
