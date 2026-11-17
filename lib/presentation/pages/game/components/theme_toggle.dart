import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, provider, _) => SwitchListTile(
        title: const Text('Dark Mode'),
        value: provider.isDarkMode,
        onChanged: provider.toggleTheme,
      ),
    );
  }
}
