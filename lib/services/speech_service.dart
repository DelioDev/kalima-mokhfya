import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  static final FlutterTts _tts = FlutterTts();
  static bool _ready = false;

  static Future<void> init(String language) async {
    await _tts.awaitSpeakCompletion(true);
    String lang = language == 'ar'
        ? 'ar-DZ'
        : language == 'fr'
            ? 'fr-FR'
            : 'en-US';
    if (!await _tts.isLanguageAvailable(lang)) lang = 'en-US';
    await _tts.setLanguage(lang);
    await _tts.setSpeechRate(0.4);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _ready = true;
  }

  static Future<void> speakLetter(String text) async {
    if (!_ready) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  static Future<void> speakWord(String text) async {
    if (!_ready) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  static Future<void> stop() async => await _tts.stop();
}
