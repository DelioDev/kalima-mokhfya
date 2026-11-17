import '../entities/player_progress.dart';
import '../repositories/settings_repository.dart';

class LoadPlayerProgress {
  final SettingsRepository repository;

  const LoadPlayerProgress(this.repository);

  Future<PlayerProgress> call() => repository.getProgress();
}
