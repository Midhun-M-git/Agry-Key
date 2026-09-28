import 'package:flutter/material.dart';
import '../utils/localization.dart';
import '../core/app_state.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:flutter_riverpod/flutter_riverpod.dart';
class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  _AIAssistantScreenState createState() =>
      _AIAssistantScreenState();
}

class _AIAssistantScreenState
  extends ConsumerState<AIAssistantScreen> {

  final TextEditingController questionController =
      TextEditingController();
      late stt.SpeechToText speech;
bool isListening = false;

  String aiResponse =
      "Welcome to AGRI KEY AI Assistant.\n\nAsk anything about farming, weather, crops, soil health, fertilizer MRP, market prices, or government schemes.";
@override
void initState() {
  super.initState();
  speech = stt.SpeechToText();
}

Future<void> startListening() async {
  bool available = await speech.initialize();

  if (available) {
    setState(() {
      isListening = true;
    });

    speech.listen(
      onResult: (result) {
        setState(() {
          questionController.text =
              result.recognizedWords;
        });
      },
    );
  }
}

Future<void> stopListening() async {
  await speech.stop();

  setState(() {
    isListening = false;
  });
}
void askAI() {
    if (questionController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      aiResponse =
          "👨‍🌾 ${questionController.text}\n\n🤖 AI Response:\n\nThis response will be generated dynamically after AI backend integration.";
    });

    questionController.clear();
  }

  Widget quickChip(
    String title,
    String question,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        backgroundColor: Colors.green.shade100,
        label: Text(title),
        onPressed: () {
          setState(() {
            questionController.text = question;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  AppState.watchAll(ref);

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          L10n.get(
            "AI Assistant",
            "AI സഹായി",
            "AI सहायक",
            "AI உதவியாளர்",
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // HEADER CARD

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Row(
                    children: [

                      CircleAvatar(
                        backgroundColor:
                            Colors.white,
                        child: Icon(
                          Icons.smart_toy,
                          color: Colors.green,
                        ),
                      ),

                      SizedBox(width: 10),

                      Text(
                        "AGRI KEY AI",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  Text(
                    L10n.get(
                      "Ask anything about farming in your language.",
                      "നിങ്ങളുടെ ഭാഷയിൽ കൃഷിയെക്കുറിച്ച് എന്തും ചോദിക്കൂ.",
                      "अपनी भाषा में खेती के बारे में कुछ भी पूछें।",
                      "உங்கள் மொழியில் விவசாயம் பற்றி எதையும் கேளுங்கள்.",
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // QUICK ACTIONS

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child: Row(
                children: [

                  quickChip(
                    L10n.get(
                      "Weather",
                      "കാലാവസ്ഥ",
                      "मौसम",
                      "வானிலை",
                    ),
                    "Will it rain tomorrow?",
                  ),

                  quickChip(
                    L10n.get(
                      "Market",
                      "വിപണി",
                      "बाज़ार",
                      "சந்தை",
                    ),
                    "Today's market price",
                  ),

                  quickChip(
                    L10n.get(
                      "Crop",
                      "വിള",
                      "फसल",
                      "பயிர்",
                    ),
                    "Best crop for my soil",
                  ),

                  quickChip(
                    L10n.get(
                      "Soil Health",
                      "മണ്ണ് പരിശോധന",
                      "मृदा स्वास्थ्य",
                      "மண் வளம்",
                    ),
                    "Soil health and fertilizer recommendation",
                  ),

                  quickChip(
                    L10n.get(
                      "Schemes",
                      "പദ്ധതികൾ",
                      "योजनाएँ",
                      "திட்டங்கள்",
                    ),
                    "Government schemes",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // AI RESPONSE AREA

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(15),
                  border: Border.all(
                    color:
                        Colors.green.shade100,
                  ),
                ),

                child:
                    SingleChildScrollView(
                  child: Text(
                    aiResponse,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // QUESTION BOX

            TextField(
              controller:
                  questionController,
              maxLines: 2,

              decoration:
                  InputDecoration(
                hintText: L10n.get(
                  "Ask your question...",
                  "ചോദ്യം ചോദിക്കൂ...",
                  "अपना प्रश्न पूछें...",
                  "உங்கள் கேள்வியை கேளுங்கள்...",
                ),

                prefixIcon:
                    const Icon(Icons.chat),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [

                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed: askAI,

                    icon: const Icon(
                      Icons.send,
                    ),

                    label: Text(
                      L10n.get(
                        "Ask AI",
                        "AIയോട് ചോദിക്കൂ",
                        "AI से पूछें",
                        "AIயிடம் கேளுங்கள்",
                      ),
                    ),

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          Colors.green,
                      foregroundColor:
                          Colors.white,
                      minimumSize:
                          const Size(
                        0,
                        50,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

               FloatingActionButton(
  heroTag: "voiceBtn",

  backgroundColor:
      isListening
          ? Colors.red
          : Colors.green,

  onPressed: () async {

    if (isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  },

  child: Icon(
    isListening
        ? Icons.mic_off
        : Icons.mic,
  ),
)
              ],
            ),
          ],
        ),
      ),
    );
  }
}