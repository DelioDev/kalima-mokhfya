import '../entities/player_progress.dart';
import '../repositories/settings_repository.dart';

class SavePlayerProgress {
  final SettingsRepository repository;

  const SavePlayerProgress(this.repository);

  Future<void> call(PlayerProgress progress) {
    return repository.saveProgress(progress);
  }
}
