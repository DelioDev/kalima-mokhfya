import '../../domain/entities/level.dart';

class LevelModel {
  final List<List<String>> grid;
  final List<String> words;

  const LevelModel({
    required this.grid,
    required this.words,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      grid: (json['grid'] as List<dynamic>)
          .map((row) => List<String>.from(row as List<dynamic>))
          .toList(),
      words: List<String>.from(json['words'] as List<dynamic>),
    );
  }

  Level toEntity(int number) {
    final flattened = grid.expand((row) => row).toList();
    return Level(
      number: number,
      grid: flattened,
      words: words,
      gridSize: grid.isEmpty ? 0 : grid.first.length,
    );
  }
}
