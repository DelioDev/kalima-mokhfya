import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsLocalDataSource {
  Future<int> getLevel();
  Future<String> getLanguage();
  Future<void> saveProgress(int level, String language);
  Future<bool> getDarkMode();
  Future<void> setDarkMode(bool value);
  Future<bool> getSoundEnabled();
  Future<void> setSoundEnabled(bool value);
}

class SharedPreferencesSettingsDataSource implements SettingsLocalDataSource {
  static const _levelKey = 'currentLevel';
  static const _languageKey = 'currentLanguage';
  static const _darkModeKey = 'darkMode';
  static const _soundKey = 'soundOn';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<int> getLevel() async => (await _prefs).getInt(_levelKey) ?? 1;

  @override
  Future<String> getLanguage() async =>
      (await _prefs).getString(_languageKey) ?? 'ar';

  @override
  Future<void> saveProgress(int level, String language) async {
    final prefs = await _prefs;
    await prefs.setInt(_levelKey, level);
    await prefs.setString(_languageKey, language);
  }

  @override
  Future<bool> getDarkMode() async =>
      (await _prefs).getBool(_darkModeKey) ?? false;

  @override
  Future<void> setDarkMode(bool value) async {
    await (await _prefs).setBool(_darkModeKey, value);
  }

  @override
  Future<bool> getSoundEnabled() async =>
      (await _prefs).getBool(_soundKey) ?? true;

  @override
  Future<void> setSoundEnabled(bool value) async {
    await (await _prefs).setBool(_soundKey, value);
  }
}
