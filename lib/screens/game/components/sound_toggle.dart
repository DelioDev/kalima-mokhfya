import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/sound_provider.dart';

class SoundToggle extends StatelessWidget {
  const SoundToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final soundProvider = Provider.of<SoundProvider>(context);
    final theme = Theme.of(context);

    return SwitchListTile(
      title: const Text("Sound"),
      value: soundProvider.soundOn,
      onChanged: (val) => soundProvider.toggleSound(val),
      secondary: Icon(
        soundProvider.soundOn ? Icons.volume_up : Icons.volume_off,
        color: theme.colorScheme.secondary,
      ),
    );
  }
}
