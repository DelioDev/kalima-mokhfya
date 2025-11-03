import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play(String path) async {
    await _player.play(AssetSource(path));
  }

  static Future<void> playTap() async => play('sounds/tap.mp3');
  static Future<void> playSuccess() async => play('sounds/success.mp3');
  static Future<void> playLevelUp() async => play('sounds/level_up.mp3');
}
