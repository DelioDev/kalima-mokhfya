import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_create/timeline_test.dart';

import '../../providers/game_provider.dart';
import '../../providers/sound_provider.dart';
import '../../../domain/usecases/load_level.dart';
import '../../../domain/usecases/save_player_progress.dart';

class GameScreen extends StatelessWidget {
  final int level;
  final String language;

  const GameScreen({
    super.key,
    this.level = 1,
    this.language = 'ar',
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(
        loadLevel: context.read<LoadLevel>(),
        savePlayerProgress: context.read<SavePlayerProgress>(),
      )..initialize(level: level, language: language),
      child: _GameView(level: level, language: language),
    );
  }
}

class _GameView extends StatelessWidget {
  final int level;
  final String language;

  const _GameView({
    required this.level,
    required this.language,
  });

  String _levelTitle() {
    if (language == 'ar') return 'المستوى $level';
    if (language == 'fr') return 'Niveau $level';
    return 'Level $level';  }

  String _confirmText() {
    if (language == 'ar') return 'تأكيد الكلمة';
    if (language == 'fr') return 'Confirmer le mot';
    return 'Confirm Word';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, _) {
        if (game.isLoading) {
          return Scaffold(
            appBar: AppBar(title: Text(_levelTitle())),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final currentLevel = game.level;
        if (currentLevel == null) {
          return Scaffold(
            appBar: AppBar(title: Text(_levelTitle())),
            body: Center(
              child: Text(game.errorMessage ?? 'Failed to load level'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_levelTitle()),
            centerTitle: true,
          ),
          body: Column(
            children: [
 // timeline test 
//  const OrderTimeline(),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 5,
                children: currentLevel.words.map((word) {
                  final found = game.foundWords.contains(word);
                  return Chip(
                    label: Text(
                      word,
                      style: TextStyle(
                        color: found ? Colors.white : null,
                      ),
                    ),
                    backgroundColor:
                        found ? Theme.of(context).colorScheme.primary : null,
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size =
                        (constraints.maxWidth - 20) / currentLevel.gridSize;
                    return GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: currentLevel.gridSize,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                      ),
                      itemCount: currentLevel.grid.length,
                      itemBuilder: (context, index) {
                        final selected = game.selectedCells.contains(index);
                        final found = game.foundWordPositions.values
                            .any((positions) => positions.contains(index));
                        return GestureDetector(
                          onTap: () async {
                            context.read<SoundProvider>().play(
                                  'sounds/tap.mp3',
                                );
                            await game.toggleCell(index);
                          },
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.blue.shade300
                                  : found
                                      ? Colors.green.shade300
                                      : Theme.of(context).colorScheme.surface,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                currentLevel.grid[index],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () => _checkWord(context, game),
                child: Text(_confirmText()),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _checkWord(
    BuildContext context,
    GameProvider game,
  ) async {
    final result = game.checkWord();
    if (result == null) return;
    if (result == 'straightLine') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select letters in a straight line.')),
      );
    } else if (result == 'invalid') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not a valid word.')),
      );
    } else {
      final soundProvider = context.read<SoundProvider>();
      await soundProvider.play('sounds/success.mp3');
      if (game.isComplete) {
        await soundProvider.play('sounds/level_up.mp3');
        if (context.mounted) _showCompletedDialog(context, game);
      }
    }
  }

  void _showCompletedDialog(BuildContext context, GameProvider game) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Congratulations!'),
        content: const Text('You completed this level!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => GameScreen(
                    level: level + 1,
                    language: language,
                  ),
                ),
              );
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
