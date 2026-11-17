import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'data/datasources/level_local_data_source.dart';
import 'data/datasources/settings_local_data_source.dart';
import 'data/repositories/level_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/level_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/usecases/load_level.dart';
import 'domain/usecases/load_player_progress.dart';
import 'domain/usecases/save_player_progress.dart';
import 'presentation/pages/settings/settings_screen.dart';
import 'presentation/providers/sound_provider.dart';
import 'presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsDataSource = SharedPreferencesSettingsDataSource();
  final settingsRepository = SettingsRepositoryImpl(settingsDataSource);
  final progress = await LoadPlayerProgress(settingsRepository).call();
  final levelDataSource = AssetLevelLocalDataSource(
    assetBundle: rootBundle,
  );
  final levelRepository = LevelRepositoryImpl(levelDataSource);

  runApp(
    MultiProvider(
      providers: [
        Provider<SettingsRepository>.value(value: settingsRepository),
        Provider<LevelRepository>.value(value: levelRepository),
        Provider<LoadLevel>(
          create: (_) => LoadLevel(levelRepository),
        ),
        Provider<SavePlayerProgress>(
          create: (_) => SavePlayerProgress(settingsRepository),
        ),
        Provider<LoadPlayerProgress>(
          create: (_) => LoadPlayerProgress(settingsRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(settingsRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SoundProvider(settingsRepository),
        ),
      ],
      child: MyApp(
        startLevel: progress.level,
        startLanguage: progress.language,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final int startLevel;
  final String startLanguage;

  const MyApp({
    super.key,
    required this.startLevel,
    required this.startLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Word Puzzle Game',
      theme: themeProvider.currentTheme,
      home: SettingsScreen(
        startLevel: startLevel,
        startLanguage: startLanguage,
      ),
    );
  }
}
