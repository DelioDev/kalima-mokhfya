import 'package:audioplayers/audioplayers.dart';
// import 'package:audio'
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SoundProvider extends ChangeNotifier {
  bool _soundOn = true;
  final AudioPlayer _player = AudioPlayer();

  bool get soundOn => _soundOn;

  SoundProvider() {
    _loadSoundSetting();
  }

  Future<void> _loadSoundSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _soundOn = prefs.getBool('soundOn') ?? true;
    notifyListeners();
  }

  Future<void> toggleSound(bool value) async {
    _soundOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundOn', _soundOn);
    notifyListeners();
  }

  Future<void> play(String asset) async {
    if (!_soundOn) return;
    try {
      await _player.play(AssetSource(asset));
    } catch (e) {
      debugPrint("⚠️ Sound play error: $e");
    }
  }
}
