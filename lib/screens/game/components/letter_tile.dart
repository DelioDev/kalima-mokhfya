import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LetterTile extends StatelessWidget {
  final String letter;
  final bool isSelected;
  final bool isFound;

  const LetterTile({
    super.key,
    required this.letter,
    required this.isSelected,
    required this.isFound,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    if (isFound) {
      bgColor = AppColors.primary;
    } else if (isSelected) {
      bgColor = AppColors.primary.withOpacity(0.7);
    } else {
      bgColor = theme.colorScheme.surfaceVariant;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade400,
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ]
            : [],
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isFound
                ? Colors.white
                : theme.textTheme.bodyLarge?.color ?? Colors.black,
          ),
        ),
      ),
    );
  }
}
