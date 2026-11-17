import 'package:flutter/material.dart';

import '../game/components/language_selector.dart';
import '../game/components/sound_toggle.dart';
import '../game/components/theme_toggle.dart';
import '../game/game_screen.dart';

class SettingsScreen extends StatefulWidget {
  final int startLevel;
  final String startLanguage;

  const SettingsScreen({
    super.key,
    this.startLevel = 1,
    this.startLanguage = 'ar',
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String selectedLanguage;

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.startLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LanguageSelector(
              selectedLanguage: selectedLanguage,
              onLanguageChanged: (language) {
                setState(() => selectedLanguage = language);
              },
            ),
            const SizedBox(height: 25),
            const SoundToggle(),
            const ThemeToggle(),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Game'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      level: widget.startLevel,
                      language: selectedLanguage,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
