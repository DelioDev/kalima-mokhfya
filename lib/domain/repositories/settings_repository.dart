import '../entities/player_progress.dart';

abstract class SettingsRepository {
  Future<PlayerProgress> getProgress();
  Future<void> saveProgress(PlayerProgress progress);
  Future<bool> getDarkMode();
  Future<void> setDarkMode(bool value);
  Future<bool> getSoundEnabled();
  Future<void> setSoundEnabled(bool value);
}
