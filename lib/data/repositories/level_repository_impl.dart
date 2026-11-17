import '../../domain/entities/level.dart';
import '../../domain/repositories/level_repository.dart';
import '../datasources/level_local_data_source.dart';

class LevelRepositoryImpl implements LevelRepository {
  final LevelLocalDataSource dataSource;

  const LevelRepositoryImpl(this.dataSource);

  @override
  Future<Level> getLevel({
    required int level,
    required String language,
  }) async {
    final model = await dataSource.getLevel(
      level: level,
      language: language,
    );
    return model.toEntity(level);
  }
}
