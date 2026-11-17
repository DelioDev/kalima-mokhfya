import '../entities/level.dart';
import '../repositories/level_repository.dart';

class LoadLevel {
  final LevelRepository repository;

  const LoadLevel(this.repository);

  Future<Level> call({
    required int level,
    required String language,
  }) {
    return repository.getLevel(level: level, language: language);
  }
}
