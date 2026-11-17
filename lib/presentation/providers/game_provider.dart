import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../domain/entities/level.dart';
import '../../domain/entities/player_progress.dart';
import '../../domain/usecases/load_level.dart';
import '../../domain/usecases/save_player_progress.dart';

class GameProvider extends ChangeNotifier {
  final LoadLevel loadLevel;
  final SavePlayerProgress savePlayerProgress;
  final FlutterTts _tts = FlutterTts();

  Level? _level;
  String _language = 'ar';
  final List<String> _foundWords = [];
  final List<int> _selectedCells = [];
  final Map<String, List<int>> _foundWordPositions = {};
  bool _isLoading = false;
  String? _errorMessage;
  bool _ttsReady = false;

  GameProvider({
    required this.loadLevel,
    required this.savePlayerProgress,
  });

  Level? get level => _level;
  String get language => _language;
  List<String> get foundWords => List.unmodifiable(_foundWords);
  List<int> get selectedCells => List.unmodifiable(_selectedCells);
  Map<String, List<int>> get foundWordPositions =>
      Map.unmodifiable(_foundWordPositions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isComplete =>
      _level != null && _foundWords.length == _level!.words.length;

  Future<void> initialize({
    required int level,
    required String language,
  }) async {
    _language = language;
    await _initializeTts();
    await load(level: level);
  }

  Future<void> _initializeTts() async {
    try {
      await _tts.awaitSpeakCompletion(true);
      final languageCode = _language == 'ar'
          ? 'ar-DZ'
          : _language == 'fr'
              ? 'fr-FR'
              : 'en-US';
      final available = await _tts.isLanguageAvailable(languageCode);
      await _tts.setLanguage(available ? languageCode : 'en-US');
      await _tts.setSpeechRate(0.4);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _ttsReady = true;
    } catch (error) {
      _ttsReady = false;
      debugPrint('TTS initialization error: $error');
    }
  }

  Future<void> load({required int level}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _level = await loadLevel(level: level, language: _language);
      _foundWords.clear();
      _selectedCells.clear();
      _foundWordPositions.clear();
    } catch (error) {
      _errorMessage = 'Failed to load level';
      debugPrint('Level load error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleCell(int index) async {
    if (_level == null || index < 0 || index >= _level!.grid.length) return;
    if (_selectedCells.contains(index)) {
      _selectedCells.remove(index);
    } else {
      _selectedCells.add(index);
    }
    notifyListeners();
    await _speak(_level!.grid[index]);
  }

  String? checkWord() {
    if (_level == null || _selectedCells.isEmpty) return null;
    final ordered = _orderedIfStraight(_selectedCells);
    if (ordered == null) {
      _selectedCells.clear();
      notifyListeners();
      return 'straightLine';
    }

    final formed = ordered.map((index) => _level!.grid[index]).join();
    final reversed = formed.split('').reversed.join();
    if (_level!.words.contains(formed) && !_foundWords.contains(formed)) {
      _acceptWord(formed, ordered);
      return formed;
    }
    if (_level!.words.contains(reversed) && !_foundWords.contains(reversed)) {
      _acceptWord(reversed, ordered.reversed.toList());
      return reversed;
    }

    _selectedCells.clear();
    notifyListeners();
    return 'invalid';
  }

  Future<void> _acceptWord(String word, List<int> positions) async {
    _foundWords.add(word);
    _foundWordPositions[word] = positions;
    _selectedCells.clear();
    notifyListeners();
    await _speak(word);
    if (isComplete && _level != null) {
      await savePlayerProgress(
        PlayerProgress(level: _level!.number, language: _language),
      );
    }
  }

  Future<void> clearSelection() async {
    _selectedCells.clear();
    notifyListeners();
  }

  List<int>? _orderedIfStraight(List<int> selected) {
    if (_level == null || selected.isEmpty) return null;
    final size = _level!.gridSize;
    final set = selected.toSet();
    final cellSet =
        set.map((index) => '${index ~/ size},${index % size}').toSet();
    const directions = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1],
      [0, -1],
      [-1, 0],
      [-1, -1],
      [-1, 1],
    ];

    for (final direction in directions) {
      final starts = <int>[];
      for (final index in set) {
        final row = index ~/ size;
        final column = index % size;
        final previousRow = row - direction[0];
        final previousColumn = column - direction[1];
        if (!cellSet.contains('$previousRow,$previousColumn')) {
          starts.add(index);
        }
      }
      for (final start in starts) {
        final sequence = <int>[];
        var row = start ~/ size;
        var column = start % size;
        while (row >= 0 &&
            row < size &&
            column >= 0 &&
            column < size &&
            cellSet.contains('$row,$column')) {
          sequence.add(row * size + column);
          row += direction[0];
          column += direction[1];
        }
        if (sequence.length == set.length && set.containsAll(sequence)) {
          return sequence;
        }
      }
    }
    return null;
  }

  Future<void> _speak(String text) async {
    if (!_ttsReady) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (error) {
      debugPrint('TTS speak error: $error');
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
