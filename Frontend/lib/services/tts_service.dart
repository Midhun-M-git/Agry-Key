import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../core/app_state.dart';

class TTSService {
  static final FlutterTts _tts = FlutterTts();
  static bool _isInitialized = false;

  static Future<void> _init() async {
    if (_isInitialized) return;
    try {
      await _tts.setSpeechRate(0.48); // Gentle, clearly articulated tempo for farmers
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
      _isInitialized = true;
    } catch (e) {
      debugPrint('[TTSService] Init warning: $e');
    }
  }

  /// Resolves the BCP-47 locale code for the current app language.
  static String getLocaleForLanguage(String? language) {
    final lang = language ?? AppState.selectedLanguage;
    switch (lang) {
      case 'Malayalam':
        return 'ml-IN';
      case 'Tamil':
        return 'ta-IN';
      case 'Hindi':
        return 'hi-IN';
      default:
        return 'en-IN';
    }
  }

  /// Speaks the given text in the requested or currently selected regional language.
  static Future<void> speak(String text, {String? language}) async {
    if (text.isEmpty) return;
    await _init();

    try {
      final locale = getLocaleForLanguage(language);
      await _tts.setLanguage(locale);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('[TTSService] Speak error: $e');
      // Graceful fallback to default engine voice if specific locale is missing
      try {
        await _tts.setLanguage('en-IN');
        await _tts.speak(text);
      } catch (_) {}
    }
  }

  /// Immediately silences ongoing speech.
  static Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
