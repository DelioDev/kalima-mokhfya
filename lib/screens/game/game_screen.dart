import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/sound_provider.dart';

class GameScreen extends StatefulWidget {
  final int level;
  final String language;

  const GameScreen({
    super.key,
    this.level = 1,
    this.language = 'ar',
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int gridSize = 4;
  late List<String> gridLetters = [];
  List<String> words = [];
  List<String> foundWords = [];
  List<int> selectedCells = [];
  Map<String, List<int>> foundWordPositions = {};
  bool isLoading = true;

  FlutterTts flutterTts = FlutterTts();
  bool _ttsReady = false;

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _loadLevel(widget.level);
  }

  /// 🔹 Initialize Text-to-Speech engine safely
  Future<void> _initializeTTS() async {
    try {
      await flutterTts.awaitSpeakCompletion(true);

      flutterTts.setStartHandler(() {
        debugPrint("🔊 TTS started");
      });

      flutterTts.setCompletionHandler(() {
        debugPrint("✅ TTS completed");
      });

      flutterTts.setErrorHandler((msg) {
        debugPrint("❌ TTS error: $msg");
      });

      String langCode = widget.language == 'ar'
          ? 'ar-DZ'
          : widget.language == 'fr'
              ? 'fr-FR'
              : 'en-US';

      var isAvailable = await flutterTts.isLanguageAvailable(langCode);
      if (!isAvailable) {
        debugPrint("⚠️ $langCode not available, fallback to en-US");
        langCode = 'en-US';
      }

      await flutterTts.setLanguage(langCode);
      await flutterTts.setSpeechRate(0.4);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);

      _ttsReady = true;
      debugPrint("✅ TTS initialized with $langCode");
    } catch (e) {
      debugPrint("⚠️ Failed to init TTS: $e");
      _ttsReady = false;
    }
  }

  /// 🔊 Speak a single letter
  Future<void> _speakLetter(String letter) async {
    if (!_ttsReady) return;
    try {
      await flutterTts.stop();
      await flutterTts.speak(letter);
    } catch (e) {
      debugPrint("⚠️ Speak letter error: $e");
    }
  }

  /// 🔊 Speak a word when found
  Future<void> _speakWord(String word) async {
    if (!_ttsReady) return;
    try {
      await flutterTts.stop();
      await flutterTts.speak(word);
    } catch (e) {
      debugPrint("⚠️ Speak word error: $e");
    }
  }

  /// 🔹 Load JSON level
  Future<void> _loadLevel(int level) async {
    setState(() => isLoading = true);
    try {
      final String data = await rootBundle.loadString(
        'lib/data/levels/${widget.language}/level_$level.json',
      );

      final Map<String, dynamic> jsonResult = json.decode(data);

      List<String> letters = [];
      for (var row in jsonResult['grid']) {
        letters.addAll(List<String>.from(row));
      }

      setState(() {
        gridSize = jsonResult['grid'][0].length;
        gridLetters = letters;
        words = List<String>.from(jsonResult['words']);
        foundWords.clear();
        selectedCells.clear();
        foundWordPositions.clear();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error loading level JSON: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Failed to load level!")),
      );
    }
  }

  /// 🔹 Handle cell tap
  void _onCellTap(int index) {
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);
    soundProvider.play('sounds/tap.mp3');

    setState(() {
      if (selectedCells.contains(index)) {
        selectedCells.remove(index);
      } else {
        selectedCells.add(index);
      }
    });

    _speakLetter(gridLetters[index]); // 🔊 Speak letter
  }

  /// 🔹 Check if selected cells are straight
  List<int>? _orderedIfStraight(List<int> selected) {
    if (selected.isEmpty) return null;
    final Set<int> set = selected.toSet();
    int totalCells = gridLetters.length;
    int rows = (totalCells / gridSize).ceil();

    final List<List<int>> dirs = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1],
      [0, -1],
      [-1, 0],
      [-1, -1],
      [-1, 1],
    ];

    Set<String> cellSet = set.map((i) {
      int r = i ~/ gridSize;
      int c = i % gridSize;
      return '$r,$c';
    }).toSet();

    for (final d in dirs) {
      int dr = d[0];
      int dc = d[1];
      List<int> starts = [];
      for (final i in set) {
        int r = i ~/ gridSize;
        int c = i % gridSize;
        int prevR = r - dr;
        int prevC = c - dc;
        if (prevR < 0 || prevR >= rows || prevC < 0 || prevC >= gridSize) {
          starts.add(i);
        } else if (!cellSet.contains('$prevR,$prevC')) starts.add(i);
      }

      for (final s in starts) {
        List<int> seq = [];
        int r = s ~/ gridSize;
        int c = s % gridSize;
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

  /// 🔹 Check and confirm word
  void _checkWord() {
    if (selectedCells.isEmpty) return;
    List<int>? ordered = _orderedIfStraight(selectedCells);
    if (ordered == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Select letters in a straight line.")),
      );
      setState(() => selectedCells.clear());
      return;
    }

    String formed = ordered.map((i) => gridLetters[i]).join();
    String reversed = formed.split('').reversed.join();

    if (words.contains(formed) && !foundWords.contains(formed)) {
      _acceptFoundWord(formed, ordered);
    } else if (words.contains(reversed) && !foundWords.contains(reversed)) {
      _acceptFoundWord(reversed, ordered.reversed.toList());
    } else {
      // soundProvider.play('sounds/tap.mp3');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Not a valid word.")),
      );
      setState(() => selectedCells.clear());
    }
  }

  /// 🔹 When a word is found
  void _acceptFoundWord(String word, List<int> positions) {
    final soundProvider = Provider.of<SoundProvider>(context, listen: false);
    setState(() {
      foundWords.add(word);
      foundWordPositions[word] = positions;
      selectedCells.clear();
    });

    soundProvider.play('sounds/success.mp3');
    _speakWord(word); // 🔊 Speak the full word

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.language == 'ar'
              ? '👏 أحسنت! وجدت الكلمة "$word"'
              : widget.language == 'fr'
                  ? '👏 Bravo! Vous avez trouvé "$word"'
                  : '👏 Great! You found "$word"',
        ),
      ),
    );

    if (foundWords.length == words.length) {
      final sp = Provider.of<SoundProvider>(context, listen: false);
      sp.play('sounds/level_up.mp3');
      _showLevelCompletedDialog();
      
    }
  }

  /// 🔹 Level completed dialog
  void _showLevelCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(
          widget.language == 'ar'
              ? "🎉 مبروك!"
              : widget.language == 'fr'
                  ? "🎉 Félicitations!"
                  : "🎉 Congratulations!",
        ),
        content: Text(
          widget.language == 'ar'
              ? "لقد أكملت هذا المستوى بنجاح!"
              : widget.language == 'fr'
                  ? "Vous avez terminé ce niveau!"
                  : "You completed this level!",
        ),
        actions: [
          TextButton(
            onPressed: () {
              final soundProvider =
                  Provider.of<SoundProvider>(context, listen: false);
              soundProvider.play('sounds/tap.mp3');
              Navigator.pop(context);
              if (widget.level < 30) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      level: widget.level + 1,
                      language: widget.language,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.language == 'ar'
                          ? "🎯 أنهيت جميع المستويات!"
                          : widget.language == 'fr'
                              ? "🎯 Vous avez terminé tous les niveaux!"
                              : "🎯 You have completed all levels!",
                    ),
                  ),
                );
              }
            },
            child: Text(
              widget.language == 'ar'
                  ? "التالي"
                  : widget.language == 'fr'
                      ? "Suivant"
                      : "Next",
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    flutterTts = FlutterTts(); // Reset
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cellSize = (screenWidth - 40) / gridSize;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.language == 'ar'
              ? 'المستوى ${widget.level}'
              : widget.language == 'fr'
                  ? 'Niveau ${widget.level}'
                  : 'Level ${widget.level}',
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 10),
                _buildWordList(),
                const SizedBox(height: 10),
                _buildGrid(cellSize),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _checkWord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    widget.language == 'ar'
                        ? "تأكيد الكلمة"
                        : widget.language == 'fr'
                            ? "Confirmer le mot"
                            : "Confirm Word",
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
    );
  }

  /// 🔹 Words list display
  Widget _buildWordList() {
    return Wrap(
      spacing: 8,
      runSpacing: 5,
      children: words.map((w) {
        bool found = foundWords.contains(w);
        return Chip(
          label: Text(
            w,
            style: TextStyle(
              fontSize: 14,
              color: found ? Colors.white : AppColors.text,
            ),
          ),
          backgroundColor: found ? AppColors.primary : Colors.grey.shade200,
        );
      }).toList(),
    );
  }

  /// 🔹 Letter grid
  Widget _buildGrid(double cellSize) {
    return Expanded(
      child: Center(
        child: GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
          ),
          itemCount: gridLetters.length,
          itemBuilder: (context, index) {
            bool isSelected = selectedCells.contains(index);
            bool isFound = foundWordPositions.values
                .any((positions) => positions.contains(index));

            return GestureDetector(
              onTap: () => _onCellTap(index),
              child: Container(
                width: cellSize,
                height: cellSize,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.shade300
                      : isFound
                          ? Colors.green.shade300
                          : Colors.white,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    gridLetters[index],
                    style: TextStyle(
                      fontSize: gridSize <= 8 ? 18 : 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
 