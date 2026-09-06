import 'package:flutter/material.dart';
import '../core/app_state.dart';

class CropAdvisoryScreen extends StatelessWidget {
  const CropAdvisoryScreen({super.key});

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
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          getText(
            "Crop Advisory",
            "വിള ഉപദേശം",
            "फसल सलाह",
            "பயிர் ஆலோசனை",
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.mic),
                labelText: getText(
                  "Search Crop",
                  "വിള തിരയുക",
                  "फसल खोजें",
                  "பயிரைத் தேடுங்கள்",
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              getText(
                "AI Recommendations",
                "AI ശുപാർശകൾ",
                "AI सिफारिशें",
                "AI பரிந்துரைகள்",
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            cropCard(
              "Rice",
              "Suitable for current weather",
            ),

            cropCard(
              "Banana",
              "Good market demand",
            ),

            cropCard(
              "Vegetables",
              "Fast growing crop",
            ),

            const SizedBox(height: 20),

            Text(
              getText(
                "Seasonal Crops",
                "കാലാവസ്ഥാ വിളകൾ",
                "मौसमी फसलें",
                "பருவகால பயிர்கள்",
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            cropCard(
              "Tomato",
              "Monsoon season crop",
            ),

            cropCard(
              "Onion",
              "High yield crop",
            ),

            cropCard(
              "Groundnut",
              "Suitable for dry climate",
            ),
          ],
        ),
      ),
    );
  }

  static Widget cropCard(
    String crop,
    String description,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(
          Icons.agriculture,
          color: Colors.green,
        ),
        title: Text(crop),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}