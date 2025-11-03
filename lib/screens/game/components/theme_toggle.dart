import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return SwitchListTile(
      title: const Text("Dark Mode"),
      value: themeProvider.isDarkMode,
      onChanged: (val) => themeProvider.toggleTheme(val),
      secondary: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: theme.colorScheme.secondary,
      ),
    );
  }
}
