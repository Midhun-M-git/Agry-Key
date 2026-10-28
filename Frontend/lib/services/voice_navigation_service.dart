import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../core/app_state.dart';
import '../core/locale_provider.dart';
import '../screens/alerts_screen.dart';
import '../screens/community_screen.dart';
import '../screens/crop_advisory_screen.dart';
import '../screens/market_screen.dart';
import '../screens/schemes_screen.dart';
import '../screens/weather_screen.dart';
import 'tts_service.dart';

/// Interaction states for voice navigation
enum VoiceInteractionState {
  idle,
  listening,
  processing,
  speaking,
  awaitingClarification,
  failed,
}

/// Allowlisted voice navigation commands
enum VoiceCommand {
  openMarket,
  openSchemes,
  openCommunity,
  openWeather,
  openAlerts,
  openCropPlanner,
  goBack,
  readScreen,
  repeat,
  stopSpeaking,
  changeLanguage,
}

class VoiceNavigationService {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static bool _isInitialized = false;
  static bool _isSpeaking = false;

  static final ValueNotifier<VoiceInteractionState> stateNotifier =
      ValueNotifier<VoiceInteractionState>(VoiceInteractionState.idle);
  static final ValueNotifier<String> lastTranscriptNotifier =
      ValueNotifier<String>("");
  static final ValueNotifier<String> lastResponseNotifier =
      ValueNotifier<String>("");
  static final ValueNotifier<String?> errorNotifier =
      ValueNotifier<String?>(null);

  static VoiceInteractionState get currentState => stateNotifier.value;
  static bool get isListening =>
      stateNotifier.value == VoiceInteractionState.listening;

  /// Allowlisted command parser for English and Malayalam spoken transcripts.
  static VoiceCommand? parseCommand(String transcript) {
    final t = transcript.toLowerCase().trim();
    if (t.isEmpty) return null;

    // 1. Stop Speaking
    if (t.contains("stop") ||
        t.contains("quiet") ||
        t.contains("mute") ||
        t.contains("നിർത്തുക") ||
        t.contains("മിണ്ടരുത്") ||
        t.contains("പോതും")) {
      return VoiceCommand.stopSpeaking;
    }

    // 2. Repeat
    if (t.contains("repeat") ||
        t.contains("say again") ||
        t.contains("once more") ||
        t.contains("വീണ്ടും പറയുക") ||
        t.contains("ഒന്നുകൂടി പറയുക") ||
        t.contains("വീണ്ടും")) {
      return VoiceCommand.repeat;
    }

    // 3. Read this screen
    if (t.contains("read this screen") ||
        t.contains("read screen") ||
        t.contains("read page") ||
        t.contains("read out") ||
        t.contains("വായിക്കുക") ||
        t.contains("ഈ പേജ് വായിക്കുക") ||
        t.contains("വിവരിക്കുക")) {
      return VoiceCommand.readScreen;
    }

    // 4. Change Language
    if (t.contains("change language") ||
        t.contains("switch language") ||
        t.contains("ഭാഷ മാറ്റുക") ||
        t.contains("ഭാഷ മാറുക") ||
        t.contains("malayalam") ||
        t.contains("മലയാളം") ||
        t.contains("english") ||
        t.contains("ഇംഗ്ലീഷ്")) {
      return VoiceCommand.changeLanguage;
    }

    // 5. Open Market
    if (t.contains("open market") ||
        t.contains("market prices") ||
        t.contains("mandi rates") ||
        t.contains("market") ||
        t.contains("mandi") ||
        t.contains("prices") ||
        t.contains("rate") ||
        t.contains("മാർക്കറ്റ്") ||
        t.contains("വിപണി") ||
        t.contains("ചന്ത") ||
        t.contains("വില") ||
        t.contains("വിപണി നിരക്കുകൾ")) {
      return VoiceCommand.openMarket;
    }

    // 6. Open Schemes
    if (t.contains("open schemes") ||
        t.contains("government schemes") ||
        t.contains("schemes") ||
        t.contains("subsidies") ||
        t.contains("subsidy") ||
        t.contains("പദ്ധതികൾ") ||
        t.contains("സർക്കാർ പദ്ധതികൾ") ||
        t.contains("സബ്സിഡി") ||
        t.contains("പദ്ധതി")) {
      return VoiceCommand.openSchemes;
    }

    // 7. Open Community
    if (t.contains("open community") ||
        t.contains("community") ||
        t.contains("farmer community") ||
        t.contains("discussions") ||
        t.contains("forum") ||
        t.contains("കൂട്ടായ്മ") ||
        t.contains("കർഷക കൂട്ടായ്മ") ||
        t.contains("കമ്മ്യൂണിറ്റി")) {
      return VoiceCommand.openCommunity;
    }

    // 8. Open Alerts (checked before generic weather to handle "weather alerts")
    if (t.contains("open alerts") ||
        t.contains("weather alerts") ||
        t.contains("alerts") ||
        t.contains("warnings") ||
        t.contains("കാലാവസ്ഥാ മുന്നറിയിപ്പുകൾ") ||
        t.contains("മുന്നറിയിപ്പുകൾ") ||
        t.contains("അറിയിപ്പുകൾ") ||
        t.contains("അറിയിപ്പ്")) {
      return VoiceCommand.openAlerts;
    }

    // 9. Open Weather
    if (t.contains("open weather") ||
        t.contains("weather forecast") ||
        t.contains("weather") ||
        t.contains("forecast") ||
        t.contains("rain") ||
        t.contains("കാലാവസ്ഥ") ||
        t.contains("മഴ") ||
        t.contains("പ്രവചനം")) {
      return VoiceCommand.openWeather;
    }

    // 10. Open Crop Income Planner
    if (t.contains("open crop planner") ||
        t.contains("crop income planner") ||
        t.contains("income planner") ||
        t.contains("crop planner") ||
        t.contains("profit planner") ||
        t.contains("planner") ||
        t.contains("വിള വരുമാന പ്ലാനർ") ||
        t.contains("വരുമാന പ്ലാനർ") ||
        t.contains("വിള പ്ലാനർ") ||
        t.contains("പ്ലാനർ")) {
      return VoiceCommand.openCropPlanner;
    }

    // 11. Go Back / Home
    if (t.contains("go back") ||
        t.contains("back") ||
        t.contains("home") ||
        t.contains("dashboard") ||
        t.contains("പിന്നോട്ട്") ||
        t.contains("പിന്നോട്ട് പോവുക") ||
        t.contains("ഹോം") ||
        t.contains("മടങ്ങുക")) {
      return VoiceCommand.goBack;
    }

    return null;
  }

  /// Begins listening for an allowlisted voice command.
  static Future<void> startListening({
    required BuildContext context,
    WidgetRef? ref,
    String? currentScreenName,
  }) async {
    // If speaking, stop speaking first
    if (_isSpeaking) {
      await stopSpeaking();
    }

    errorNotifier.value = null;
    stateNotifier.value = VoiceInteractionState.listening;

    try {
      if (!_isInitialized) {
        _isInitialized = await _speech.initialize(
          onError: (err) {
            debugPrint('[VoiceNav] STT Error: ${err.errorMsg}');
            errorNotifier.value = err.errorMsg;
            stateNotifier.value = VoiceInteractionState.failed;
          },
        );
      }

      if (!_isInitialized) {
        errorNotifier.value = "Microphone permission denied or unavailable.";
        stateNotifier.value = VoiceInteractionState.failed;
        return;
      }

      final isMalayalam = AppState.selectedLanguage == 'Malayalam';
      final localeId = isMalayalam ? 'ml_IN' : 'en_IN';

      await _speech.listen(
        localeId: localeId,
        onResult: (result) {
          final words = result.recognizedWords.trim();
          lastTranscriptNotifier.value = words;

          if (result.finalResult && words.isNotEmpty) {
            _handleCompletedTranscript(
              context: context,
              transcript: words,
              ref: ref,
              currentScreenName: currentScreenName,
            );
          }
        },
      );
    } catch (e) {
      debugPrint('[VoiceNav] Exception during startListening: $e');
      errorNotifier.value = e.toString();
      stateNotifier.value = VoiceInteractionState.failed;
    }
  }

  /// Stops STT listening immediately.
  static Future<void> stopListening() async {
    try {
      await _speech.stop();
    } catch (_) {}
    if (stateNotifier.value == VoiceInteractionState.listening) {
      stateNotifier.value = VoiceInteractionState.idle;
    }
  }

  /// Stops TTS speech immediately.
  static Future<void> stopSpeaking() async {
    _isSpeaking = false;
    await TTSService.stop();
    if (stateNotifier.value == VoiceInteractionState.speaking) {
      stateNotifier.value = VoiceInteractionState.idle;
    }
  }

  /// Processes completed voice input through the allowlisted command router.
  static Future<void> _handleCompletedTranscript({
    required BuildContext context,
    required String transcript,
    WidgetRef? ref,
    String? currentScreenName,
  }) async {
    await stopListening();
    stateNotifier.value = VoiceInteractionState.processing;

    final command = parseCommand(transcript);

    if (command == null) {
      stateNotifier.value = VoiceInteractionState.awaitingClarification;
      final isMalayalam = AppState.selectedLanguage == 'Malayalam';
      final clarificationMsg = isMalayalam
          ? "അഗ്രി-കീ AI: കമാൻഡ് മനസ്സിലായില്ല. മാർക്കറ്റ്, പദ്ധതികൾ, അല്ലെങ്കിൽ കാലാവസ്ഥ എന്ന് വീണ്ടും പറയൂ."
          : "Agry-Key AI: Command not recognized. Please say Market, Schemes, or Weather.";
      await _speakResponse(clarificationMsg);
      stateNotifier.value = VoiceInteractionState.idle;
      return;
    }

    await executeCommand(
      context: context,
      command: command,
      ref: ref,
      currentScreenName: currentScreenName,
    );
  }

  /// Allowlisted command execution router.
  static Future<void> executeCommand({
    required BuildContext context,
    required VoiceCommand command,
    WidgetRef? ref,
    String? currentScreenName,
  }) async {
    final isMalayalam = AppState.selectedLanguage == 'Malayalam';

    switch (command) {
      case VoiceCommand.stopSpeaking:
        await stopSpeaking();
        stateNotifier.value = VoiceInteractionState.idle;
        return;

      case VoiceCommand.repeat:
        if (lastResponseNotifier.value.isNotEmpty) {
          await _speakResponse(lastResponseNotifier.value);
        } else {
          final noRepeatMsg = isMalayalam
              ? "അഗ്രി-കീ AI: മുൻപ് പറഞ്ഞ മറുപടികളൊന്നുമില്ല."
              : "Agry-Key AI: No previous statement to repeat.";
          await _speakResponse(noRepeatMsg);
        }
        stateNotifier.value = VoiceInteractionState.idle;
        return;

      case VoiceCommand.readScreen:
        final narration = _getScreenNarration(currentScreenName ?? 'Home', isMalayalam);
        await _speakResponse(narration);
        stateNotifier.value = VoiceInteractionState.idle;
        return;

      case VoiceCommand.changeLanguage:
        final newLocale = isMalayalam ? const Locale('en') : const Locale('ml');
        if (ref != null) {
          await ref.read(localeProvider.notifier).setLocale(newLocale, isExplicit: true);
        }
        final ack = isMalayalam
            ? "Agry-Key AI: Language switched to English."
            : "അഗ്രി-കീ AI: ഭാഷ മലയാളത്തിലേക്ക് മാറ്റി.";
        await _speakResponse(ack);
        stateNotifier.value = VoiceInteractionState.idle;
        return;

      case VoiceCommand.openMarket:
        final ack = isMalayalam
            ? "അഗ്രി-കീ AI: വിപണി നിരക്കുകൾ തുറക്കുന്നു."
            : "Agry-Key AI: Opening market prices.";
        await _speakResponse(ack);
        if (context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketScreen()));
        }
        stateNotifier.value = VoiceInteractionState.idle;
        return;

      case VoiceCommand.openSchemes:
        final ack = isMalayalam
            ? "അഗ്രി-കീ AI: സർക്കാർ പദ്ധതികൾ തുറക്കുന്നു."
            : "Agry-Key AI: Opening government schemes.";
        await _speakResponse(ack);
        if (context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SchemesScreen()));
        }
        stateNotifier.value = VoiceInteractionState.idle;
        return;

      case VoiceCommand.openCommunity:
        final ack = isMalayalam
            ? "അഗ്രി-കീ AI: കർഷക കൂട്ടായ്മ തുറക്കുന്നു."
            : "Agry-Key AI: Opening farmer community.";
        await _speakResponse(ack);
        if (context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityScreen()));
        }
        stateNotifier.value = VoiceInteractionState.idle;
        return;

      case VoiceCommand.openWeather:
        final ack = isMalayalam
            ? "അഗ്രി-കീ AI: കാലാവസ്ഥ വിവരങ്ങൾ തുറക്കുന്നു."
            : "Agry-Key AI: Opening weather forecast.";
        await _speakResponse(ack);
        if (context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen()));
        }
        stateNotifier.value = VoiceInteractionState.idle;
        return;

      case VoiceCommand.openAlerts:
        final ack = isMalayalam
            ? "അഗ്രി-കീ AI: കാലാവസ്ഥാ മുന്നറിയിപ്പുകൾ തുറക്കുന്നു."
            : "Agry-Key AI: Opening weather alerts.";
        await _speakResponse(ack);
        if (context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertsScreen()));
        }
        stateNotifier.value = VoiceInteractionState.idle;
        return;

      case VoiceCommand.openCropPlanner:
        final ack = isMalayalam
            ? "അഗ്രി-കീ AI: വിള വരുമാന പ്ലാനർ തുറക്കുന്നു."
            : "Agry-Key AI: Opening Crop Income Planner.";
        await _speakResponse(ack);
        if (context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CropAdvisoryScreen()));
        }
        stateNotifier.value = VoiceInteractionState.idle;
        return;

      case VoiceCommand.goBack:
        final ack = isMalayalam
            ? "അഗ്രി-കീ AI: പ്രധാന പേജിലേക്ക് മടങ്ങുന്നു."
            : "Agry-Key AI: Returning to previous screen.";
        await _speakResponse(ack);
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        stateNotifier.value = VoiceInteractionState.idle;
        return;
    }
  }

  /// Speaks a narration or response with honest limitations, setting state to speaking.
  static Future<void> _speakResponse(String text) async {
    lastResponseNotifier.value = text;
    stateNotifier.value = VoiceInteractionState.speaking;
    _isSpeaking = true;
    await TTSService.speak(text);
    _isSpeaking = false;
  }

  /// Generates truthful, traceable spoken narration explaining data limitations.
  static String _getScreenNarration(String screenName, bool isMalayalam) {
    switch (screenName.toLowerCase()) {
      case 'market':
        return isMalayalam
            ? "അഗ്രി-കീ AI: വിപണി നിരക്കുകൾ. വിവരങ്ങളുടെ ഉറവിടം അഗ്മാർക്ക്നെറ്റ്. ലഭ്യമല്ലാത്ത വിലകൾ വ്യക്തമായി രേഖപ്പെടുത്തിയിട്ടുണ്ട്."
            : "Agry-Key AI: Mandi market rates. Source: Agmarknet. Missing rates are labeled unavailable, never simulated.";

      case 'weather':
        return isMalayalam
            ? "അഗ്രി-കീ AI: ഓപ്പൺ-മെറ്റിയോ മോഡൽ പ്രവചനം. ഇത് കമ്പ്യൂട്ടർ മോഡൽ അനുമാനമാണ്, നേരിട്ടുള്ള ഫീൽഡ് നിരീക്ഷണമല്ല."
            : "Agry-Key AI: Open-Meteo model forecast. This is a computer model output, not a direct ground sensor observation.";

      case 'schemes':
        return isMalayalam
            ? "അഗ്രി-കീ AI: കേന്ദ്ര-സംസ്ഥാന കർഷക ക്ഷേമ പദ്ധതികൾ. പരിശോധിച്ചുറപ്പിച്ച പദ്ധതികളിൽ ഔദ്യോഗിക പോർട്ടൽ ലിങ്കുകൾ ഉൾപ്പെടുത്തിയിട്ടുണ്ട്."
            : "Agry-Key AI: Government welfare schemes. Verified schemes include official portal links.";

      case 'crop_planner':
        return isMalayalam
            ? "അഗ്രി-കീ AI: വിള വരുമാന പ്ലാനർ. കൃഷിഭൂമിയുടെ വിസ്തൃതിയും പ്രതീക്ഷിക്കുന്ന വിളവും നൽകി ചെലവും വരുമാനവും കണക്കുകൂട്ടാം."
            : "Agry-Key AI: Crop Income Planner calculates estimated net return from farmer-entered acreage and official mandi prices.";

      case 'alerts':
        return isMalayalam
            ? "അഗ്രി-കീ AI: നിങ്ങളുടെ ജില്ലയിലെ കാലാവസ്ഥാ മുന്നറിയിപ്പുകൾ."
            : "Agry-Key AI: Active weather and crop advisories for your district.";

      default:
        return isMalayalam
            ? "അഗ്രി-കീ AI: പ്രധാന പേജ്. മാർക്കറ്റ്, പദ്ധതികൾ, കൂട്ടായ്മ, കാലാവസ്ഥ എന്നീ സേവനങ്ങൾ ലഭ്യമാണ്."
            : "Agry-Key AI: Dashboard. Market, Schemes, Community, Weather, and Crop Income Planner are available.";
    }
  }
}
