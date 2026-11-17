class GridUtils {
  /// Checks if the selected cells form a straight line (horizontal, vertical, or diagonal).
  /// If so, returns the ordered sequence of indexes; otherwise returns null.
  static List<int>? orderedIfStraight(
      List<int> selected, int gridSize, int totalCells) {
    if (selected.isEmpty) return null;

    final set = selected.toSet();
    final rows = (totalCells / gridSize).ceil();

    // 8 directions: right, down, diagonal ↘, diagonal ↙, left, up, ↖, ↗
    const dirs = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1],
      [0, -1],
      [-1, 0],
      [-1, -1],
      [-1, 1],
    ];

    // Convert selected cells into row,col form
    final cellSet = set.map((i) {
      final r = i ~/ gridSize;
      final c = i % gridSize;
      return '$r,$c';
    }).toSet();

    for (final d in dirs) {
      final dr = d[0];
      final dc = d[1];
      final starts = <int>[];

      // Find potential start cells (no previous neighbor in this direction)
      for (final i in set) {
        final r = i ~/ gridSize;
        final c = i % gridSize;
        final prevR = r - dr;
        final prevC = c - dc;
        if (prevR < 0 ||
            prevR >= rows ||
            prevC < 0 ||
            prevC >= gridSize ||
            !cellSet.contains('$prevR,$prevC')) {
          starts.add(i);
        }
      }

      // Try building sequences
      for (final s in starts) {
        final seq = <int>[];
        var r = s ~/ gridSize;
        var c = s % gridSize;

        while (r >= 0 &&
            r < rows &&
            c >= 0 &&
            c < gridSize &&
            cellSet.contains('$r,$c')) {
          seq.add(r * gridSize + c);
          r += dr;
          c += dc;
        }

        if (seq.length == set.length && set.containsAll(seq)) return seq;
      }
    }

    return null;
  }
}
