import '../entities/level.dart';

abstract class LevelRepository {
  Future<Level> getLevel({
    required int level,
    required String language,
  });
}
