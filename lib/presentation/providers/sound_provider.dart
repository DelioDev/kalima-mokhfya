import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/settings_repository.dart';

class SoundProvider extends ChangeNotifier {
  final SettingsRepository settingsRepository;
  final AudioPlayer _player = AudioPlayer();
  bool _soundOn = true;

  SoundProvider(this.settingsRepository) {
    _loadSoundSetting();
  }

  bool get soundOn => _soundOn;

  Future<void> _loadSoundSetting() async {
    _soundOn = await settingsRepository.getSoundEnabled();
    notifyListeners();
  }

  Future<void> toggleSound(bool value) async {
    _soundOn = value;
    notifyListeners();
    await settingsRepository.setSoundEnabled(value);
  }

  Future<void> play(String asset) async {
    if (!_soundOn) return;
    try {
      await _player.play(AssetSource(asset));
    } catch (error) {
      debugPrint('Sound play error: $error');
    }
  }

  void disposePlayer() {
    _player.dispose();
  }
}
