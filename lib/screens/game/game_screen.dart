import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/sound_provider.dart';

class GameScreen extends StatefulWidget {
  final int level;
  final String language; // 🌐 اللغة القادمة من SettingsScreen

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLevel(widget.level);
  }

  // 🔹 تحميل ملف المستوى الصحيح حسب اللغة المختارة
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
        gridSize = jsonResult['grid'].length;
        gridLetters = letters;
        words = List<String>.from(jsonResult['words']);
        foundWords.clear();
        selectedCells.clear();
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

  // 🔹 عندما يضغط المستخدم على خلية
 void _onCellTap(int index) {
  final soundProvider = Provider.of<SoundProvider>(context, listen: false);
  soundProvider.play('sounds/tap.mp3'); // 🔊 Play tap sound

  setState(() {
    if (selectedCells.contains(index)) {
      selectedCells.remove(index);
    } else {
      selectedCells.add(index);
    }
  });
}


  // 🔹 التحقق من الكلمة
 void _checkWord() {
  final soundProvider = Provider.of<SoundProvider>(context, listen: false);

  if (selectedCells.isEmpty) return;

  selectedCells.sort();
  String formedWord = selectedCells.map((i) => gridLetters[i]).join();

  if (words.contains(formedWord) && !foundWords.contains(formedWord)) {
    setState(() {
      foundWords.add(formedWord);
      selectedCells.clear();
    });

    soundProvider.play('sounds/success.mp3'); // ✅ play success sound

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.language == 'ar'
            ? '👏 أحسنت! وجدت الكلمة "$formedWord"'
            : widget.language == 'fr'
                ? '👏 Bravo! Vous avez trouvé "$formedWord"'
                : '👏 Great! You found "$formedWord"'),
      ),
    );

    if (foundWords.length == words.length) {
      soundProvider.play('sounds/level_up.mp3'); // 🎉 play level complete sound
      _showLevelCompletedDialog();
    }
  } else {
    soundProvider.play('sounds/tap.mp3'); // ❌ maybe same as tap for invalid
    setState(() => selectedCells.clear());
  }
}

  // 🔹 إظهار رسالة عند إكمال المستوى
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
                  ? "Vous avez terminé ce niveau avec succès!"
                  : "You have successfully completed this level!",
        ),
        actions: [
          TextButton(
            onPressed: () {
              final soundProvider = Provider.of<SoundProvider>(context, listen: false);
    soundProvider.play('sounds/tap.mp3'); // small click
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
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cellSize = (screenWidth - 40) / gridSize;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.language == 'ar'
            ? 'المستوى ${widget.level}'
            : widget.language == 'fr'
                ? 'Niveau ${widget.level}'
                : 'Level ${widget.level}'),
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
                  child: Text(widget.language == 'ar'
                      ? "تأكيد الكلمة"
                      : widget.language == 'fr'
                          ? "Confirmer le mot"
                          : "Confirm Word"),
                ),
                const SizedBox(height: 10),
              ],
            ),
    );
  }

  // 🔹 قائمة الكلمات
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

  // 🔹 الشبكة
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

            return GestureDetector(
              onTap: () => _onCellTap(index),
              child: Container(
                width: cellSize,
                height: cellSize,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.shade300
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
