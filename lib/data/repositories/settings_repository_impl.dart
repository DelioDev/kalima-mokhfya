import '../../domain/entities/player_progress.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource dataSource;

  const SettingsRepositoryImpl(this.dataSource);

  @override
  Future<PlayerProgress> getProgress() async {
    return PlayerProgress(
      level: await dataSource.getLevel(),
      language: await dataSource.getLanguage(),
    );
  }

  @override
  Future<void> saveProgress(PlayerProgress progress) {
    return dataSource.saveProgress(progress.level, progress.language);
  }

  @override
  Future<bool> getDarkMode() => dataSource.getDarkMode();

  @override
  Future<void> setDarkMode(bool value) => dataSource.setDarkMode(value);

  @override
  Future<bool> getSoundEnabled() => dataSource.getSoundEnabled();

  @override
  Future<void> setSoundEnabled(bool value) => dataSource.setSoundEnabled(value);
}
