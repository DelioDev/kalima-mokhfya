import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/sound_provider.dart';

class SoundToggle extends StatelessWidget {
  const SoundToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SoundProvider>(
      builder: (context, provider, _) => SwitchListTile(
        title: const Text('Sound'),
        value: provider.soundOn,
        onChanged: provider.toggleSound,
      ),
    );
  }
}
