import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sound_provider.dart';
import '../../providers/theme_provider.dart';
import '../game/game_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedLanguage = "en";

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final soundProvider = Provider.of<SoundProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose Language:", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedLanguage,
              items: const [
                DropdownMenuItem(value: "en", child: Text("English 🇬🇧")),
                DropdownMenuItem(value: "ar", child: Text("العربية 🇸🇦")),
                DropdownMenuItem(value: "fr", child: Text("Français 🇫🇷")),
              ],
              onChanged: (val) => setState(() => selectedLanguage = val!),
            ),

            const SizedBox(height: 25),

            // 🔊 Global sound switch
            SwitchListTile(
              title: const Text("Sound"),
              value: soundProvider.soundOn,
              onChanged: (val) => soundProvider.toggleSound(val),
              secondary: Icon(
                soundProvider.soundOn ? Icons.volume_up : Icons.volume_off,
                color: theme.colorScheme.secondary,
              ),
            ),

            // 🌙 Dark Mode
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: themeProvider.isDarkMode,
              onChanged: (val) => themeProvider.toggleTheme(val),
              secondary: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: theme.colorScheme.secondary,
              ),
            ),

            const Spacer(),

            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text("Start Game"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      level: 1,
                      language: selectedLanguage,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
