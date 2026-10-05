import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../core/app_state.dart';

class TTSService {
  static final FlutterTts _tts = FlutterTts();
  static bool _isInitialized = false;
  static bool isMuted = false;
  static final ValueNotifier<bool> muteNotifier = ValueNotifier<bool>(false);

  static Future<void> _init() async {
    if (_isInitialized) return;
    try {
      await _tts.setSpeechRate(0.48); // Friendly, clear pacing for farmers
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
  /// If muted by the user, this silently returns.
  static Future<void> speak(String text, {String? language}) async {
    if (isMuted || text.isEmpty) return;
    await _init();

    try {
      final locale = getLocaleForLanguage(language);
      await _tts.setLanguage(locale);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('[TTSService] Speak error: $e');
      try {
        await _tts.setLanguage('en-IN');
        await _tts.speak(text);
      } catch (_) {}
    }
  }

  /// Toggles mute state. When muted, immediately cuts off any ongoing speech.
  /// When unmuted, greets the user politely.
  static void toggleMute() {
    isMuted = !isMuted;
    muteNotifier.value = isMuted;

    if (isMuted) {
      stop();
    } else {
      final lang = AppState.selectedLanguage;
      String greeting = "Voice companion active.";
      if (lang == 'Malayalam') {
        greeting = "ശബ്ദം ഓണാക്കി. ഞാൻ സഹായിക്കാം.";
      } else if (lang == 'Hindi') {
        greeting = "आवाज़ चालू है। मैं सहायता के लिए तैयार हूँ।";
      } else if (lang == 'Tamil') {
        greeting = "ஒலி இயக்கப்பட்டது. நான் உங்களுக்கு உதவ தயார்.";
      }
      speak(greeting);
    }
  }

  /// Explicitly set mute status
  static void setMuted(bool val) {
    if (isMuted == val) return;
    isMuted = val;
    muteNotifier.value = val;
    if (val) {
      stop();
    }
  }

  /// Immediately silences ongoing speech.
  static Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
