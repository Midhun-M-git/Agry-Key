import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../screens/crop_advisory_screen.dart';
import '../services/ai_service.dart';
import '../services/tts_service.dart';
import '../utils/localization.dart';
import '../widgets/voice_companion_bar.dart';
import '../widgets/voice_text_field.dart';

class FarmerAdvisoryScreen extends ConsumerStatefulWidget {
  const FarmerAdvisoryScreen({super.key});

  @override
  _FarmerAdvisoryScreenState createState() => _FarmerAdvisoryScreenState();
}

class _FarmerAdvisoryScreenState extends ConsumerState<FarmerAdvisoryScreen> {
  final TextEditingController questionController = TextEditingController();
  bool _isLoading = false;
  String? _advisoryResult;
  String? _lastQuestion;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    TTSService.muteNotifier.addListener(_onTtsStateChange);
  }

  void _onTtsStateChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    questionController.dispose();
    TTSService.muteNotifier.removeListener(_onTtsStateChange);
    TTSService.stop();
    super.dispose();
  }

  Future<void> getAdvice([String? presetQuestion]) async {
    final query = presetQuestion ?? questionController.text.trim();
    if (query.isEmpty) return;

    if (presetQuestion != null) {
      questionController.text = presetQuestion;
    }

    setState(() {
      _isLoading = true;
      _lastQuestion = query;
      _advisoryResult = null;
      _isSpeaking = false;
    });

    try {
      final state = AppState.userState.isNotEmpty ? AppState.userState : 'Kerala';
      final district = AppState.userDistrict.isNotEmpty ? AppState.userDistrict : 'Kochi';

      final answer = await AIService.askQuestion(
        question: query,
        state: state,
        district: district,
      );

      if (mounted) {
        setState(() {
          _advisoryResult = answer;
          _isLoading = false;
          _isSpeaking = true;
        });

        // Automatically speak the friendly AI suggestion
        TTSService.speak(answer);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _advisoryResult = "Could not fetch advisory. Please check your internet connection.";
          _isLoading = false;
        });
      }
    }
  }

  void _toggleAudioPlayback() {
    if (_isSpeaking) {
      TTSService.stop();
      setState(() => _isSpeaking = false);
    } else if (_advisoryResult != null && _advisoryResult!.isNotEmpty) {
      setState(() => _isSpeaking = true);
      TTSService.speak(_advisoryResult!);
    }
  }

  Widget quickChip(String title, String question) {
    return ActionChip(
      elevation: 0,
      backgroundColor: Colors.green.shade50,
      side: BorderSide(color: Colors.green.shade200),
      label: Text(
        title,
        style: TextStyle(
          color: Colors.green.shade900,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      onPressed: () => getAdvice(question),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: Text(
          L10n.get(
            "AI Voice Advisory Companion",
            "AI കാർഷിക ശബ്ദ സഹായി",
            "AI वॉयस कृषि सलाहकार",
            "AI குரல் விவசாய வழிகாட்டி",
          ),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Crop Profit Maximizer',
            icon: const Icon(Icons.psychology, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CropAdvisoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.record_voice_over, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          L10n.get(
                            "Friendly AI Farming Companion",
                            "നിങ്ങളുടെ വിശ്വസ്ത കാർഷിക ശബ്ദ സഹായി",
                            "आपका व्यक्तिगत वॉयस कृषि साथी",
                            "உங்கள் தனிப்பட்ட குரல் விவசாய வழிகாட்டி",
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          L10n.get(
                            "Speaks advice in your language · Tailored to your local weather & soil",
                            "നിങ്ങളുടെ മാതൃഭാഷയിൽ സംസാരിക്കുന്നു · കാലാവസ്ഥയ്ക്കും മണ്ണിനും അനുയോജ്യമായ ഉപദേശം",
                            "आपकी भाषा में सलाह बोलता है · मौसम और मिट्टी के अनुसार",
                            "உங்கள் மொழியில் பேசுகிறது · உள்ளூர் வானிலை மற்றும் மண் சார்ந்தது",
                          ),
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Quick Shortcut Banner to Crop Maximizer
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CropAdvisoryScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.eco, color: Color(0xFF1B5E20), size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L10n.get(
                              "AgriStack Crop Recommendation",
                              "അഗ്രിസ്റ്റാക്ക് വിള ലാഭ ഉപദേശം",
                              "एग्रीस्टैक फसल लाभ सिफारिश",
                              "அக்ரிஸ்டாக் பயிர் லாப பரிந்துரை",
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B5E20)),
                          ),
                          Text(
                            L10n.get(
                              "Synthesize plot acreage, soil, and harvest price forecasts",
                              "വിളഭൂമി, മണ്ണ്, വിപണി വില എന്നിവ അടിസ്ഥാനമാക്കിയുള്ള കണക്കുകൂട്ടൽ",
                              "भूमि, मिट्टी और मंडी भाव के आधार पर सर्वश्रेष्ठ विकल्प",
                              "நிலம், மண் மற்றும் சந்தை விலை அடிப்படையில் சிறந்த பயிர்",
                            ),
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.green),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quick Topic Chips
            Text(
              L10n.get(
                "Popular Questions:",
                "കൂടുതൽ ചോദ്യങ്ങൾ:",
                "सामान्य प्रश्न:",
                "பிரபலமான கேள்விகள்:",
              ),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                quickChip(
                  L10n.get("🌾 Best Crop to Grow", "🌾 അടുത്ത വിള", "🌾 कौन सी फसल उगाएं", "🌾 என்ன பயிர் செய்யலாம்"),
                  "What is the best profitable crop to grow this season based on current weather and market forecasts?",
                ),
                quickChip(
                  L10n.get("🌦️ Rain & Weather", "🌦️ മഴ സാധ്യത", "🌦️ बारिश का अनुमान", "🌦️ மழை வாய்ப்பு"),
                  "Will it rain in my district this week and how should I plan irrigation?",
                ),
                quickChip(
                  L10n.get("🧪 Organic Fertilizer", "🧪 ജൈവവളം", "🧪 जैविक खाद", "🧪 இயற்கை உரம்"),
                  "What is the best balanced fertilizer dosage for high yield?",
                ),
                quickChip(
                  L10n.get("🐛 Pest Protection", "🐛 കീടനിയന്ത്രണം", "🐛 कीट नियंत्रण", "🐛 பூச்சி கட்டுப்பாடு"),
                  "How to protect crops from leaf diseases and sucking pests naturally?",
                ),
                quickChip(
                  L10n.get("🏛️ PM-Kisan Scheme", "🏛️ പി.എം. കിസാൻ", "🏛️ पीएम किसान", "🏛️ பி.எம் கிசான்"),
                  "How can I apply for PM-Kisan and agriculture machinery subsidy?",
                ),
                quickChip(
                  L10n.get("📈 Mandi Market Rate", "📈 വിപണി വില", "📈 मंडी भाव", "📈 சந்தை விலை"),
                  "Where can I get the highest price for my harvest produce?",
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Voice Text Field
            VoiceTextField(
              controller: questionController,
              onSubmitted: (val) => getAdvice(val),
              hintText: L10n.get(
                "Ask your farming question (type or speak)...",
                "നിങ്ങളുടെ സംശയം ചോദിക്കൂ (ടൈപ്പ് ചെയ്യുകയോ സംസാരിക്കുകയോ ചെയ്യാം)...",
                "अपना कृषि प्रश्न पूछें (टाइप करें या बोलें)...",
                "உங்கள் விவசாய கேள்வியைக் கேளுங்கள் (டைப் செய்யவும் அல்லது பேசவும்)...",
              ),
            ),

            const SizedBox(height: 14),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () => getAdvice(),
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _isLoading
                      ? L10n.get("Consulting AI Expert...", "ഉത്തരം തയ്യാറാക്കുന്നു...", "सलाह तैयार की जा रही है...", "ஆலோசனை பெறப்படுகிறது...")
                      : L10n.get("Get Spoken Advice", "ശബ്ദ ഉപദേശം നേടുക", "वॉयस सलाह प्राप्त करें", "குரல் ஆலோசனை பெறுக"),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Spoken Response Card
            if (_advisoryResult != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade300, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology, color: Color(0xFF1B5E20), size: 22),
                            const SizedBox(width: 8),
                            Text(
                              L10n.get(
                                "AI Advisor Guidance",
                                "AI കാർഷിക നിർദ്ദേശം",
                                "AI कृषि सलाह",
                                "AI விவசாய வழிகாட்டுதல்",
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            _isSpeaking ? Icons.stop_circle : Icons.volume_up,
                            color: _isSpeaking ? Colors.red : Colors.green.shade800,
                            size: 26,
                          ),
                          tooltip: _isSpeaking ? 'Stop Audio' : 'Listen Again',
                          onPressed: _toggleAudioPlayback,
                        ),
                      ],
                    ),
                    if (_lastQuestion != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Q: "$_lastQuestion"',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Divider(height: 18),
                    ],
                    Text(
                      _advisoryResult!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const SafeArea(
        child: VoiceCompanionBar(
          customHint: "Tap mic to speak your question directly",
        ),
      ),
    );
  }
}