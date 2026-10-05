import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../core/app_state.dart';
import 'role_selection_screen.dart';
import '../services/location_service.dart';
import '../services/tts_service.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  _LanguageSelectionScreenState createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends ConsumerState<LanguageSelectionScreen> {
  String? selectedLanguage;
  late stt.SpeechToText _speech;
  bool _hasPromptedLocation = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    if (AppState.selectedLanguage.isNotEmpty) {
      selectedLanguage = AppState.selectedLanguage;
    }

    _detectLocationAndPromptLanguage();
  }

  Future<void> _detectLocationAndPromptLanguage() async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (!mounted || position == null) return;

      ref.read(locationProvider.notifier).update(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Determine state by reverse geocoding or coordinate fallback
      String detectedState = "Kerala";
      try {
        final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty && placemarks.first.administrativeArea != null) {
          detectedState = placemarks.first.administrativeArea!;
        }
      } catch (_) {
        // Coordinate heuristic for major Indian farming states
        if (position.latitude >= 8.1 && position.latitude <= 12.8 && position.longitude >= 74.8 && position.longitude <= 77.5) {
          detectedState = "Kerala";
        } else if (position.latitude >= 8.0 && position.latitude <= 13.5 && position.longitude >= 76.5 && position.longitude <= 80.3) {
          detectedState = "Tamil Nadu";
        } else {
          detectedState = "Hindi";
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final hasPrompted = prefs.getBool('has_prompted_regional_language') ?? false;

      if (!hasPrompted && !_hasPromptedLocation && mounted) {
        _hasPromptedLocation = true;
        await prefs.setBool('has_prompted_regional_language', true);
        _showRegionalLanguageDialog(detectedState);
      }
    } catch (_) {}
  }

  void _showRegionalLanguageDialog(String detectedState) {
    String targetLanguage = 'Malayalam';
    String stateDisplayName = 'Kerala';
    String spokenPrompt = 'നമസ്കാരം! നിങ്ങൾ കേരളത്തിലാണെന്ന് കാണുന്നു. അഗ്രി കീ മലയാളത്തിൽ ഉപയോഗിക്കാൻ താല്പര്യമുണ്ടോ?';
    String titleText = 'Switch to Malayalam?';
    String subtitleText = 'We noticed your farm is in Kerala. Would you like to use AgriKey in മലയാളം (Malayalam)?';
    String yesBtnText = 'Yes, മലയാളം';
    String noBtnText = 'No, Keep English';

    final sLower = detectedState.toLowerCase();
    if (sLower.contains('tamil') || sLower.contains('tn')) {
      targetLanguage = 'Tamil';
      stateDisplayName = 'Tamil Nadu';
      spokenPrompt = 'வணக்கம்! நீங்கள் தமிழ்நாட்டில் இருக்கிறீர்கள். அக்ரி கீ செயலியை தமிழில் பயன்படுத்த விரும்புகிறீர்களா?';
      titleText = 'Switch to தமிழ் (Tamil)?';
      subtitleText = 'We noticed your location is in Tamil Nadu. Would you like to switch to தமிழ்?';
      yesBtnText = 'Yes, தமிழ்';
    } else if (!sLower.contains('kerala')) {
      targetLanguage = 'Hindi';
      stateDisplayName = 'India';
      spokenPrompt = 'नमस्ते! क्या आप एग्री की को हिंदी में उपयोग करना चाहते हैं?';
      titleText = 'Switch to हिन्दी (Hindi)?';
      subtitleText = 'Would you like to use AgriKey in your regional language हिन्दी (Hindi)?';
      yesBtnText = 'Yes, हिन्दी';
    }

    // Play greeting in the regional language
    TTSService.speak(spokenPrompt, language: targetLanguage);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => _RegionalLanguageVoicePrompt(
        speech: _speech,
        stateName: stateDisplayName,
        targetLanguage: targetLanguage,
        titleText: titleText,
        subtitleText: subtitleText,
        yesBtnText: yesBtnText,
        noBtnText: noBtnText,
        onChoiceSelected: (choseRegional) {
          TTSService.stop();
          if (choseRegional) {
            setState(() {
              selectedLanguage = targetLanguage;
            });
            ref.read(languageProvider.notifier).setLanguage(targetLanguage);
          }
        },
      ),
    );
  }

  Widget languageButton(String language, String displayText) {
    bool isSelected = selectedLanguage == language;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedLanguage = language;
          });
          ref.read(languageProvider.notifier).setLanguage(language);
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          foregroundColor: isSelected ? Colors.green.shade800 : Colors.black87,
          side: BorderSide(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 400,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Container(
                      height: 110,
                      width: 110,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.12),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "AgriKey",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Your Farm. Our Intelligence.\nBetter Tomorrow.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 35),
                    const Text(
                      "Choose Your Language",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Select your preferred regional language",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    languageButton("English", "English"),
                    languageButton("Malayalam", "മലയാളം (Malayalam)"),
                    languageButton("Hindi", "हिन्दी (Hindi)"),
                    languageButton("Tamil", "தமிழ் (Tamil)"),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: selectedLanguage == null
                            ? null
                            : () {
                                AppState.selectedLanguage = selectedLanguage!;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RoleSelectionScreen(),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Interactive voice-enabled regional language prompt dialog
class _RegionalLanguageVoicePrompt extends StatefulWidget {
  final stt.SpeechToText speech;
  final String stateName;
  final String targetLanguage;
  final String titleText;
  final String subtitleText;
  final String yesBtnText;
  final String noBtnText;
  final ValueChanged<bool> onChoiceSelected;

  const _RegionalLanguageVoicePrompt({
    required this.speech,
    required this.stateName,
    required this.targetLanguage,
    required this.titleText,
    required this.subtitleText,
    required this.yesBtnText,
    required this.noBtnText,
    required this.onChoiceSelected,
  });

  @override
  State<_RegionalLanguageVoicePrompt> createState() => _RegionalLanguageVoicePromptState();
}

class _RegionalLanguageVoicePromptState extends State<_RegionalLanguageVoicePrompt> {
  bool _isListening = false;
  String _voiceFeedback = "AI is asking in your language...";

  @override
  void initState() {
    super.initState();
    _startVoiceListener();
  }

  Future<void> _startVoiceListener() async {
    try {
      bool available = await widget.speech.initialize();
      if (!available || !mounted) return;

      setState(() {
        _isListening = true;
        _voiceFeedback = "Listening for your response (Say 'Yes' or 'No')...";
      });

      widget.speech.listen(
        onResult: (result) {
          final text = result.recognizedWords.toLowerCase();
          if (text.contains('yes') ||
              text.contains('athe') ||
              text.contains('അതെ') ||
              text.contains('ശരി') ||
              text.contains('हाँ') ||
              text.contains('ஆம்')) {
            _selectChoice(true);
          } else if (text.contains('no') ||
              text.contains('illa') ||
              text.contains('ഇല്ല') ||
              text.contains('വേണ്ട') ||
              text.contains('नहीं') ||
              text.contains('இல்லை')) {
            _selectChoice(false);
          }
        },
        listenFor: const Duration(seconds: 12),
        pauseFor: const Duration(seconds: 3),
      );
    } catch (_) {}
  }

  void _selectChoice(bool choseRegional) {
    widget.speech.stop();
    TTSService.stop();
    Navigator.of(context).pop();
    widget.onChoiceSelected(choseRegional);
  }

  @override
  void dispose() {
    widget.speech.stop();
    TTSService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.record_voice_over_rounded,
              color: Colors.green,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.titleText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.subtitleText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isListening ? Colors.green.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isListening ? Colors.green.shade200 : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isListening ? Icons.mic : Icons.volume_up,
                  size: 16,
                  color: _isListening ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _voiceFeedback,
                    style: TextStyle(
                      fontSize: 11,
                      color: _isListening ? Colors.green.shade800 : Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _selectChoice(true),
              child: Text(
                widget.yesBtnText,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _selectChoice(false),
            child: Text(
              widget.noBtnText,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}