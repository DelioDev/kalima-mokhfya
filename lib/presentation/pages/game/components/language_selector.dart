import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose Language:', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        DropdownButton<String>(
          value: selectedLanguage,
          items: const [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'ar', child: Text('العربية')),
            DropdownMenuItem(value: 'fr', child: Text('Français')),
          ],
          onChanged: (value) {
            if (value != null) onLanguageChanged(value);
          },
        ),
      ],
    );
  }
}
