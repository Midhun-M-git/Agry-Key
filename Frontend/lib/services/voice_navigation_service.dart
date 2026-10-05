import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../core/app_state.dart';
import '../screens/all_services_screen.dart';
import '../screens/community_screen.dart';
import '../screens/crop_advisory_screen.dart';
import '../screens/farmer_orders_screen.dart';
import '../screens/farmer_products_screen.dart';
import '../screens/market_screen.dart';
import '../screens/schemes_screen.dart';
import '../screens/soil_health_screen.dart';
import '../screens/weather_screen.dart';
import 'ai_service.dart';
import 'tts_service.dart';

class VoiceNavigationService {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static bool _isListening = false;
  static final ValueNotifier<bool> isListeningNotifier = ValueNotifier<bool>(false);
  static final ValueNotifier<String> lastTranscriptNotifier = ValueNotifier<String>("");

  static bool get isListening => _isListening;

  /// Starts listening for a voice navigation command or farming question.
  static Future<void> startListening({
    required BuildContext context,
    VoidCallback? onStarted,
    VoidCallback? onStopped,
  }) async {
    try {
      bool available = await _speech.initialize(
        onError: (err) {
          debugPrint('[VoiceNav] Error: ${err.errorMsg}');
          _stopListening(onStopped);
        },
      );

      if (!available) {
        debugPrint('[VoiceNav] Mic not available');
        return;
      }

      _isListening = true;
      isListeningNotifier.value = true;
      onStarted?.call();

      await _speech.listen(
        onResult: (result) {
          final words = result.recognizedWords.trim();
          lastTranscriptNotifier.value = words;

          if (result.finalResult && words.isNotEmpty) {
            _stopListening(onStopped);
            handleSpokenCommand(context, words);
          }
        },
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('[VoiceNav] Start listen exception: $e');
      _stopListening(onStopped);
    }
  }

  static Future<void> stopListening([VoidCallback? onStopped]) async {
    await _stopListening(onStopped);
  }

  static Future<void> _stopListening(VoidCallback? onStopped) async {
    try {
      await _speech.stop();
    } catch (_) {}
    _isListening = false;
    isListeningNotifier.value = false;
    onStopped?.call();
  }

  /// Evaluates the spoken words across regional languages and executes navigation or AI inquiry.
  static Future<void> handleSpokenCommand(BuildContext context, String input) async {
    final t = input.toLowerCase();
    final lang = AppState.selectedLanguage;

    // 1. Mute / Unmute
    if (t.contains("mute") || t.contains("quiet") || t.contains("മിണ്ടരുത്") || t.contains("നിശബ്ദ") || t.contains("चुप") || t.contains("அமைதி")) {
      TTSService.setMuted(true);
      return;
    }
    if (t.contains("unmute") || t.contains("speak") || t.contains("സംസാരിക്കൂ") || t.contains("बोलिए") || t.contains("பேசு")) {
      TTSService.setMuted(false);
      return;
    }

    // 2. Weather Navigation
    if (t.contains("weather") || t.contains("rain") || t.contains("climate") ||
        t.contains("കാലാവസ്ഥ") || t.contains("മഴ") || t.contains("ചൂട്") ||
        t.contains("मौसम") || t.contains("बारिश") ||
        t.contains("வானிலை") || t.contains("மழை")) {
      _speakNavAck(lang, "Opening weather forecast", "കാലാവസ്ഥ വിവരങ്ങൾ തുറക്കുന്നു", "मौसम की जानकारी खोली जा रही है", "வானிலை விவரங்கள் திறக்கப்படுகின்றன");
      Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen()));
      return;
    }

    // 3. Market / Mandi Prices
    if (t.contains("market") || t.contains("mandi") || t.contains("price") || t.contains("rate") ||
        t.contains("മാർക്കറ്റ്") || t.contains("ചന്ത") || t.contains("വില") || t.contains("റേറ്റ്") ||
        t.contains("बाजार") || t.contains("मंडी") || t.contains("भाव") ||
        t.contains("சந்தை") || t.contains("விலை")) {
      _speakNavAck(lang, "Opening mandi market rates", "വിപണി നിരക്കുകൾ തുറക്കുന്നു", "मंडी भाव खोले जा रहे हैं", "சந்தை விலைகள் திறக்கப்படுகின்றன");
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketScreen()));
      return;
    }

    // 4. Crop Profit Maximizer / Advisory
    if (t.contains("crop") || t.contains("profit") || t.contains("advisory") ||
        t.contains("വിള") || t.contains("ലാഭം") || t.contains("ഉപദേശം") ||
        t.contains("फसल") || t.contains("लाभ") ||
        t.contains("பயிர்") || t.contains("லாபம்")) {
      _speakNavAck(lang, "Opening crop profit advisor", "വിള ലാഭ ഉപദേശം തുറക്കുന്നു", "फसल लाभ सलाहकार खोला जा रहा है", "பயிர் லாப ஆலோசகர் திறக்கப்படுகிறது");
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CropAdvisoryScreen()));
      return;
    }

    // 5. Soil Health
    if (t.contains("soil") || t.contains("earth") ||
        t.contains("മണ്ണ്") || t.contains("സോയിൽ") ||
        t.contains("मिट्टी") || t.contains("मृदा") ||
        t.contains("மண்")) {
      _speakNavAck(lang, "Opening soil health report", "മണ്ണ് പരിശോധന വിവരങ്ങൾ തുറക്കുന്നു", "मृदा स्वास्थ्य खोला जा रहा है", "மண் பரிசோதனை திறக்கப்படுகிறது");
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SoilHealthScreen()));
      return;
    }

    // 6. Farmer Products
    if (t.contains("product") || t.contains("produce") ||
        t.contains("ഉൽപ്പന്നങ്ങൾ") || t.contains("സാധനങ്ങൾ") ||
        t.contains("उत्पाद") || t.contains("பொருட்கள்")) {
      _speakNavAck(lang, "Opening your farm products", "നിങ്ങളുടെ ഉൽപ്പന്നങ്ങൾ തുറക്കുന്നു", "आपके उत्पाद खोले जा रहे हैं", "உங்கள் பொருட்கள் திறக்கப்படுகின்றன");
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmerProductsScreen()));
      return;
    }

    // 7. Orders
    if (t.contains("order") || t.contains("orders") ||
        t.contains("ഓർഡർ") || t.contains("ഓർഡറുകൾ") ||
        t.contains("ऑर्डर") || t.contains("ஆர்டர்")) {
      _speakNavAck(lang, "Opening orders", "നിങ്ങളുടെ ഓർഡറുകൾ തുറക്കുന്നു", "ऑर्डर खोले जा रहे हैं", "ஆர்டர்கள் திறக்கப்படுகின்றன");
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmerOrdersScreen()));
      return;
    }

    // 8. Schemes & Govt Subsidies
    if (t.contains("scheme") || t.contains("subsidy") || t.contains("government") ||
        t.contains("പദ്ധതി") || t.contains("സഹായം") || t.contains("സബ്സിഡി") ||
        t.contains("योजना") || t.contains("திட்டம்")) {
      _speakNavAck(lang, "Opening government schemes", "സർക്കാർ പദ്ധതികൾ തുറക്കുന്നു", "सरकारी योजनाएं खोली जा रही हैं", "அரசு திட்டங்கள் திறக்கப்படுகின்றன");
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SchemesScreen()));
      return;
    }

    // 9. Community
    if (t.contains("community") || t.contains("forum") ||
        t.contains("കമ്മ്യൂണിറ്റി") || t.contains("കൂട്ടായ്മ") ||
        t.contains("समुदाय") || t.contains("சமூகம்")) {
      _speakNavAck(lang, "Opening farmer community", "കർഷക കൂട്ടായ്മ തുറക്കുന്നു", "किसान समुदाय खोला जा रहा है", "விவசாய சமூகம் திறக்கப்படுகிறது");
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityScreen()));
      return;
    }

    // 10. All Services
    if (t.contains("service") || t.contains("services") || t.contains("all") ||
        t.contains("സേവനങ്ങൾ") || t.contains("सेवाएं") || t.contains("சேவைகள்")) {
      _speakNavAck(lang, "Opening all services", "എല്ലാ സേവനങ്ങളും തുറക്കുന്നു", "सभी सेवाएं खोली जा रही हैं", "அனைத்து சேவைகளும் திறக்கப்படுகின்றன");
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AllServicesScreen()));
      return;
    }

    // 11. Back / Home
    if (t.contains("back") || t.contains("home") || t.contains("dashboard") ||
        t.contains("തിരികെ") || t.contains("ഹോം") || t.contains("वापस") || t.contains("திரும்பு")) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        _speakNavAck(lang, "Returning home", "പ്രധാന പേജിലേക്ക് മടങ്ങുന്നു", "मुख्य पृष्ठ पर वापस जा रहे हैं", "முகப்புக்கு திரும்புகிறோம்");
      }
      return;
    }

    // 12. General Farming Question -> Pass to AI Companion and speak answer!
    _speakNavAck(lang, "Checking with AI companion...", "AI പരിശോധിക്കുന്നു...", "AI जांच कर रहा है...", "AI சரிபார்க்கிறது...");
    final answer = await AIService.askQuestion(
      question: input,
      state: AppState.userState.isNotEmpty ? AppState.userState : 'Kerala',
      district: AppState.userDistrict.isNotEmpty ? AppState.userDistrict : 'Palakkad',
    );
    TTSService.speak(answer);
  }

  static void _speakNavAck(String lang, String en, String ml, String hi, String ta) {
    if (lang == 'Malayalam') {
      TTSService.speak(ml);
    } else if (lang == 'Hindi') {
      TTSService.speak(hi);
    } else if (lang == 'Tamil') {
      TTSService.speak(ta);
    } else {
      TTSService.speak(en);
    }
  }
}
