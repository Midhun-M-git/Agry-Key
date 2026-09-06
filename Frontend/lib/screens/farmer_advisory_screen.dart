import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../widgets/voice_text_field.dart';

class FarmerAdvisoryScreen extends StatefulWidget {
  const FarmerAdvisoryScreen({super.key});

  @override
  State<FarmerAdvisoryScreen> createState() =>
      _FarmerAdvisoryScreenState();
}

class _FarmerAdvisoryScreenState
    extends State<FarmerAdvisoryScreen> {

  final TextEditingController questionController =
      TextEditingController();

  String advisoryResult =
      "🌱 Ask any farming question and get guidance.";

  String getText(
    String english,
    String malayalam,
    String hindi,
    String tamil,
  ) {
    switch (AppState.selectedLanguage) {
      case "Malayalam":
        return malayalam;
      case "Hindi":
        return hindi;
      case "Tamil":
        return tamil;
      default:
        return english;
    }
  }

  void getAdvice() {
    if (questionController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      advisoryResult =
          "Question:\n${questionController.text}\n\nAI Advisory:\nRecommendation will appear here after backend integration.";
    });
  }

  Widget quickChip(String title, String question) {
    return ActionChip(
      label: Text(title),
      backgroundColor: Colors.green.shade100,
      onPressed: () {
        questionController.text = question;
      },
    );
  }

  @override
  void dispose() {
    questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          getText(
            "Farmer Advisory",
            "കർഷക ഉപദേശം",
            "किसान सलाह",
            "விவசாய ஆலோசனை",
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: Column(
                children: [

                  const Icon(
                    Icons.agriculture,
                    color: Colors.white,
                    size: 55,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    getText(
                      "Smart Farming Guidance",
                      "സ്മാർട്ട് കാർഷിക മാർഗ്ഗനിർദ്ദേശം",
                      "स्मार्ट कृषि मार्गदर्शन",
                      "ஸ்மார்ட் விவசாய வழிகாட்டுதல்",
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [

                quickChip(
                  "🌧 Weather",
                  "Will it rain tomorrow?",
                ),

                quickChip(
                  "🌾 Fertilizer",
                  "Best fertilizer for rice",
                ),

                quickChip(
                  "🐛 Pest",
                  "How to control pests?",
                ),

                quickChip(
                  "🍌 Banana",
                  "Best fertilizer for banana",
                ),

                quickChip(
                  "🥥 Coconut",
                  "Tips for coconut farming",
                ),
              ],
            ),

            const SizedBox(height: 20),

            VoiceTextField(
              controller: questionController,
              hintText: getText(
                "Ask your farming question...",
                "നിങ്ങളുടെ കാർഷിക ചോദ്യം ചോദിക്കൂ...",
                "अपना कृषि प्रश्न पूछें...",
                "உங்கள் விவசாய கேள்வியை கேளுங்கள்...",
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: getAdvice,

                icon: const Icon(
                  Icons.smart_toy,
                ),

                label: Text(
                  getText(
                    "Get Advisory",
                    "ഉപദേശം നേടുക",
                    "सलाह प्राप्त करें",
                    "ஆலோசனை பெறுங்கள்",
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                  foregroundColor:
                      Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Text(
                  advisoryResult,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}