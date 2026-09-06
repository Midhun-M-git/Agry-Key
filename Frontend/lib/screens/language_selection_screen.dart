import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../core/api_config.dart';
import '../core/app_state.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../widgets/voice_assistant_fab.dart';
import 'role_selection_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends State<LanguageSelectionScreen> {

  String? selectedLanguage;

  @override
  void initState() {
    super.initState();

    if (AppState.selectedLanguage.isNotEmpty) {
      selectedLanguage = AppState.selectedLanguage;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAutoLocationAndVoice();
    });
  }

  Future<void> _initAutoLocationAndVoice() async {
    String langName = 'Malayalam';
    String langCode = 'ml';
    String audioUrl = '/api/v1/voice/greeting?lang=ml';

    try {
      await LocationService.getCurrentLocation().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint("Location request timed out; using default region.");
        },
      );

      double lat = AppState.latitude != 0.0 ? AppState.latitude : 10.7867;
      double lng = AppState.longitude != 0.0 ? AppState.longitude : 76.6548;

      final res = await ApiService.detectLanguage(
        latitude: lat,
        longitude: lng,
      );

      if (res.containsKey('language_name')) {
        langName = res['language_name'] ?? 'Malayalam';
        langCode = res['regional_language_code'] ?? 'ml';
        audioUrl = res['audio_greeting_url'] ?? audioUrl;
      }
    } catch (e) {
      debugPrint("Auto location detection error: $e");
    }

    if (mounted) {
      _showVoiceLanguagePrompt(langName, langCode, audioUrl);
    }
  }

  void _showVoiceLanguagePrompt(
      String langName, String langCode, String audioUrl) async {
    if (!mounted) return;

    final AudioPlayer player = AudioPlayer();

    String regionalPromptText = {
          'ml':
              'നിങ്ങളുടെ ലൊക്കേഷൻ അനുസരിച്ച് ഇന്റർഫേസ് മലയാളത്തിലേക്ക് മാറ്റണോ?',
          'ta': 'உங்கள் இருப்பிடத்தின் அடிப்படையில் இடைமுகத்தை தமிழிற்கு மாற்றவா?',
          'hi':
              'क्या आप अपने स्थान के आधार पर इंटरफ़ेस को हिंदी में बदलना चाहते हैं?',
        }[langCode] ??
        'Would you like to switch to $langName based on your location?';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void playVoice() async {
              if (audioUrl.isNotEmpty) {
                try {
                  final fullAudioUrl = '${ApiConfig.baseUrl}$audioUrl';
                  await player.stop();
                  await player.play(UrlSource(fullAudioUrl));
                } catch (e) {
                  debugPrint("Audio playback error: $e");
                }
              }
            }

            return AlertDialog(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.record_voice_over, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Location Detected: $langName',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    regionalPromptText,
                    style:
                        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: playVoice,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade300, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.volume_up, color: Colors.green, size: 24),
                          SizedBox(width: 8),
                          Text(
                            "Listen Voice Guidance",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Switch interface and voice guidance to $langName?',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                OutlinedButton(
                  onPressed: () {
                    try {
                      player.stop();
                      player.dispose();
                    } catch (_) {}
                    Navigator.pop(dialogContext);
                    setState(() {
                      selectedLanguage = 'English';
                      AppState.selectedLanguage = 'English';
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoleSelectionScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('No / English'),
                ),
                ElevatedButton(
                  onPressed: () {
                    try {
                      player.stop();
                      player.dispose();
                    } catch (_) {}
                    Navigator.pop(dialogContext);
                    setState(() {
                      selectedLanguage = langName;
                      AppState.selectedLanguage = langName;
                    });
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Yes / $langName'),
                ),
              ],
            );
          },
        );
      },
    );

    if (audioUrl.isNotEmpty) {
      try {
        final fullAudioUrl = '${ApiConfig.baseUrl}$audioUrl';
        player.play(UrlSource(fullAudioUrl)).catchError((e) {
          debugPrint("Audio playback error: $e");
        });
      } catch (e) {
        debugPrint("Audio play exception: $e");
      }
    }
  }

  Widget languageButton(
    String language,
    String displayText,
  ) {
    bool isSelected =
        selectedLanguage == language;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedLanguage = language;
            AppState.selectedLanguage =
                language;
          });
        },

        style: ElevatedButton.styleFrom(
          elevation: 0,

          backgroundColor: isSelected
              ? const Color(0xFFE8F5E9)
              : Colors.white,

          foregroundColor: isSelected
              ? Colors.green.shade800
              : Colors.black87,

          side: BorderSide(
            color: isSelected
                ? Colors.green
                : Colors.grey.shade300,
            width: 1.5,
          ),

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),

          padding:
              const EdgeInsets.symmetric(
            vertical: 16,
          ),
        ),

        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w500,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF5),
      floatingActionButton: const VoiceAssistantFab(),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // User gesture unlocks browser AudioContext automatically
          if (AppState.selectedLanguage.isEmpty) {
            _initAutoLocationAndVoice();
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: 400,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 15),

                      // Voice Assistant Header Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.green.shade400),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.mic, color: Colors.green, size: 22),
                            SizedBox(width: 8),
                            Text(
                              "Voice Assistant Ready (Tap to Speak/Listen)",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                    Container(
                      height: 130,
                      width: 130,

                      decoration:
                          BoxDecoration(
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),

                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    const Text(
                      "AgriKey",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      "Your Farm. Our Intelligence.\nBetter Tomorrow.",
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 40,
                    ),

                    const Text(
                      "Choose Your Language",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      "Select your preferred language",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    languageButton(
                      "English",
                      "English",
                    ),

                    languageButton(
                      "Malayalam",
                      "മലയാളം (Malayalam)",
                    ),

                    languageButton(
                      "Hindi",
                      "हिन्दी (Hindi)",
                    ),

                    languageButton(
                      "Tamil",
                      "தமிழ் (Tamil)",
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(
                        onPressed:
                            selectedLanguage ==
                                    null
                                ? null
                                : () {

                                    AppState
                                            .selectedLanguage =
                                        selectedLanguage!;

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (
                                              context,
                                            ) =>
                                                const RoleSelectionScreen(),
                                      ),
                                    );
                                  },

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors
                                  .green
                                  .shade700,

                          foregroundColor:
                              Colors.white,

                          elevation: 4,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),
                          ),
                        ),

                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}