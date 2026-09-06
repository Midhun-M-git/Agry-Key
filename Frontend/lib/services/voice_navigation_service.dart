import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import '../core/api_config.dart';
import '../core/app_state.dart';
import '../screens/language_selection_screen.dart';
import '../screens/role_selection_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/buyer_dashboard_screen.dart';
import '../screens/market_screen.dart';
import '../screens/weather_screen.dart';
import '../screens/crop_advisory_screen.dart';
import '../screens/disease_detection_screen.dart';
import '../screens/government_schemes_screen.dart';
import '../screens/soil_health_screen.dart';
import '../screens/ai_assistant_screen.dart';
import '../screens/buyer_ai_assistant_screen.dart';
import '../screens/my_orders_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/login_screen.dart';

class VoiceNavigationService {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isInitialized = false;

  static Future<bool> initSpeech() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onError: (val) => debugPrint('Speech error: $val'),
        onStatus: (val) => debugPrint('Speech status: $val'),
      );
    }
    return _isInitialized;
  }

  static void listenAndNavigate(
    BuildContext context, {
    required Function(String text) onResultText,
    required Function(bool listening) onListeningState,
  }) async {
    bool available = await initSpeech();
    if (!available) {
      onResultText("Speech recognition not supported on this browser.");
      return;
    }

    onListeningState(true);

    _speech.listen(
      onResult: (result) {
        String recognizedWords = result.recognizedWords.toLowerCase().trim();
        onResultText(result.recognizedWords);

        if (result.finalResult || recognizedWords.isNotEmpty) {
          onListeningState(false);
          _speech.stop();
          processVoiceCommand(context, recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 8),
      pauseFor: const Duration(seconds: 3),
      localeId: AppState.selectedLanguage == "Malayalam"
          ? "ml_IN"
          : AppState.selectedLanguage == "Hindi"
              ? "hi_IN"
              : AppState.selectedLanguage == "Tamil"
                  ? "ta_IN"
                  : "en_US",
    );
  }

  static void stopListening() {
    _speech.stop();
  }

  static void processVoiceCommand(BuildContext context, String command) async {
    String text = command.toLowerCase().trim();
    debugPrint("Voice Command Received: $text");
    if (text.isEmpty) return;

    String langCode = AppState.selectedLanguage == "Malayalam"
        ? "ml"
        : AppState.selectedLanguage == "Hindi"
            ? "hi"
            : AppState.selectedLanguage == "Tamil"
                ? "ta"
                : "en";

    String? targetScreen;
    String? spokenText;

    // 1. Query Backend AI Intent Parser for intelligent screen navigation
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/v1/voice/intent"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"query": text, "lang": langCode}),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        targetScreen = data["target_screen"];
        spokenText = data["spoken_text"];
      }
    } catch (e) {
      debugPrint("Voice AI backend intent call failed: $e, falling back to local parsing");
    }

    // 2. Client-Side Parsing Fallback if network/backend is unavailable
    if (targetScreen == null) {
      targetScreen = _parseLocalTargetScreen(text);
      spokenText = "Opening $targetScreen";
    }

    if (spokenText != null) {
      await speakResponse(spokenText);
    }

    if (!context.mounted) return;
    _navigateToTargetScreen(context, targetScreen);
  }

  static String _parseLocalTargetScreen(String text) {
    if (text.contains("language") || text.contains("भाषा") || text.contains("ഭാഷ") || text.contains("மொழி")) {
      return "language";
    } else if (text.contains("market") || text.contains("mandi") || text.contains("വില") || text.contains("मंडी")) {
      return "market";
    } else if (text.contains("weather") || text.contains("rain") || text.contains("കാലാവസ്ഥ") || text.contains("मौसम")) {
      return "weather";
    } else if (text.contains("advisory") || text.contains("crop") || text.contains("ഉപദേശം")) {
      return "crop_advisory";
    } else if (text.contains("disease") || text.contains("pest") || text.contains("രോഗം")) {
      return "disease_detection";
    } else if (text.contains("scheme") || text.contains("government") || text.contains("പദ്ധതി")) {
      return "government_schemes";
    } else if (text.contains("soil") || text.contains("മണ്ണ്") || text.contains("मिट्टी")) {
      return "soil_health";
    } else if (text.contains("buyer") || text.contains("consumer") || text.contains("ഉപഭോക്താവ്") || text.contains("खरीदार")) {
      return "buyer_dashboard";
    } else if (text.contains("farmer") || text.contains("kisan") || text.contains("കർഷകൻ") || text.contains("വിவசாயി")) {
      return "farmer_dashboard";
    } else if (text.contains("order") || text.contains("ഓർഡർ") || text.contains("ऑर्डर")) {
      return "my_orders";
    } else if (text.contains("profile") || text.contains("account") || text.contains("പ്രൊഫൈൽ")) {
      return "profile";
    } else if (text.contains("login") || text.contains("signin") || text.contains("ലോഗിൻ")) {
      return "login";
    }
    return "ai_assistant";
  }

  static void _navigateToTargetScreen(BuildContext context, String targetScreen) {
    Widget nextScreen;
    switch (targetScreen) {
      case "language":
        nextScreen = const LanguageSelectionScreen();
        break;
      case "farmer_dashboard":
        AppState.selectedRole = "FARMER";
        nextScreen = const DashboardScreen();
        break;
      case "buyer_dashboard":
        AppState.selectedRole = "BUYER";
        nextScreen = const BuyerDashboardScreen();
        break;
      case "market":
        nextScreen = const MarketScreen();
        break;
      case "weather":
        nextScreen = const WeatherScreen();
        break;
      case "crop_advisory":
        nextScreen = const CropAdvisoryScreen();
        break;
      case "disease_detection":
        nextScreen = const DiseaseDetectionScreen();
        break;
      case "government_schemes":
        nextScreen = const GovernmentSchemesScreen();
        break;
      case "soil_health":
        nextScreen = const SoilHealthScreen();
        break;
      case "my_orders":
        nextScreen = const MyOrdersScreen();
        break;
      case "profile":
        nextScreen = const ProfileScreen();
        break;
      case "login":
        nextScreen = const LoginScreen();
        break;
      case "ai_assistant":
      default:
        nextScreen = AppState.selectedRole == "BUYER"
            ? const BuyerAIAssistantScreen()
            : const AIAssistantScreen();
        break;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => nextScreen));
  }

  static Future<void> speakResponse(String text) async {
    try {
      String langCode = AppState.selectedLanguage == "Malayalam"
          ? "ml"
          : AppState.selectedLanguage == "Hindi"
              ? "hi"
              : AppState.selectedLanguage == "Tamil"
                  ? "ta"
                  : "en";
      final audioUrl = "${ApiConfig.baseUrl}/api/v1/voice/greeting?lang=$langCode";
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      debugPrint("Voice audio playback suppressed (requires user interaction first): $e");
    }
  }
}

