import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WordListWidget extends StatelessWidget {
  final List<String> words;
  final Set<String> foundWords;

  const WordListWidget({
    super.key,
    required this.words,
    required this.foundWords,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: words.map((word) {
        final isFound = foundWords.contains(word);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isFound ? AppColors.primary : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            word.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isFound ? Colors.white : Colors.black87,
            ),
          ),
        );
      }).toList(),
    );
  }
}
