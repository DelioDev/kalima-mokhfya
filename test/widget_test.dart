import 'package:flutter_test/flutter_test.dart';
import 'package:word_create/domain/entities/level.dart';

void main() {
  test('level entity exposes grid metadata', () {
    const level = Level(
      number: 1,
      grid: ['a', 'b', 'c', 'd'],
      words: ['ab'],
      gridSize: 2,
    );

    expect(level.number, 1);
    expect(level.gridSize, 2);
    expect(level.words, ['ab']);
  });
}
