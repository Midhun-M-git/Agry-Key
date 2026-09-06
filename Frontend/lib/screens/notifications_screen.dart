import 'package:flutter/material.dart';
import '../core/app_state.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          getText(
            "Notifications",
            "അറിയിപ്പുകൾ",
            "सूचनाएँ",
            "அறிவிப்புகள்",
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(12),

        children: [

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.cloud,
                color: Colors.blue,
              ),
              title: Text(
                getText(
                  "Weather Alert",
                  "കാലാവസ്ഥ മുന്നറിയിപ്പ്",
                  "मौसम अलर्ट",
                  "வானிலை எச்சரிக்கை",
                ),
              ),
              subtitle: Text(
                getText(
                  "Rain expected tomorrow.",
                  "നാളെ മഴ പ്രതീക്ഷിക്കുന്നു.",
                  "कल वर्षा होने की संभावना है।",
                  "நாளை மழை எதிர்பார்க்கப்படுகிறது.",
                ),
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.trending_up,
                color: Colors.green,
              ),
              title: Text(
                getText(
                  "Market Update",
                  "മാർക്കറ്റ് അപ്ഡേറ്റ്",
                  "बाज़ार अपडेट",
                  "சந்தை புதுப்பிப்பு",
                ),
              ),
              subtitle: Text(
                getText(
                  "Rice price increased by 2.5%",
                  "അരിയുടെ വില 2.5% വർധിച്ചു",
                  "चावल की कीमत 2.5% बढ़ी",
                  "அரிசி விலை 2.5% உயர்ந்துள்ளது",
                ),
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.shopping_bag,
                color: Colors.orange,
              ),
              title: Text(
                getText(
                  "Order Update",
                  "ഓർഡർ അപ്ഡേറ്റ്",
                  "ऑर्डर अपडेट",
                  "ஆர்டர் புதுப்பிப்பு",
                ),
              ),
              subtitle: Text(
                getText(
                  "Your order has been accepted.",
                  "നിങ്ങളുടെ ഓർഡർ അംഗീകരിച്ചു.",
                  "आपका ऑर्डर स्वीकार कर लिया गया है।",
                  "உங்கள் ஆர்டர் ஏற்கப்பட்டது.",
                ),
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.smart_toy,
                color: Colors.purple,
              ),
              title: Text(
                getText(
                  "AI Recommendation",
                  "AI ശുപാർശ",
                  "AI सिफारिश",
                  "AI பரிந்துரை",
                ),
              ),
              subtitle: Text(
                getText(
                  "Irrigation can be postponed until evening.",
                  "ജലസേചനം വൈകുന്നേരത്തേക്ക് മാറ്റാം.",
                  "सिंचाई शाम तक टाली जा सकती है।",
                  "நீர்ப்பாசனத்தை மாலை வரை ஒத்திவைக்கலாம்.",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}