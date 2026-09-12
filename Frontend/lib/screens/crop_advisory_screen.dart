import 'package:flutter/material.dart';
import '../utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';

class CropAdvisoryScreen extends ConsumerWidget {
  const CropAdvisoryScreen({super.key});
@override
  Widget build(BuildContext context, WidgetRef ref) {
    AppState.watchAll(ref);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          L10n.get(
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
                labelText: L10n.get(
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
              L10n.get(
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
              L10n.get(
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