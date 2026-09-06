import 'package:flutter/material.dart';
import '../core/app_state.dart';

class SoilHealthScreen extends StatelessWidget {
  const SoilHealthScreen({super.key});

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
            "Soil Health",
            "മണ്ണിന്റെ ആരോഗ്യം",
            "मिट्टी का स्वास्थ्य",
            "மண் ஆரோக்கியம்",
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.landscape,
                  color: Colors.brown,
                ),
                title: Text(
                  getText(
                    "Soil Type",
                    "മണ്ണിന്റെ തരം",
                    "मिट्टी का प्रकार",
                    "மண் வகை",
                  ),
                ),
                subtitle: const Text("Loamy Soil"),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.water_drop,
                  color: Colors.blue,
                ),
                title: Text(
                  getText(
                    "Moisture",
                    "ഈർപ്പം",
                    "नमी",
                    "ஈரப்பதம்",
                  ),
                ),
                subtitle: const Text("68%"),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.science,
                  color: Colors.orange,
                ),
                title: const Text("pH"),
                subtitle: const Text("6.8"),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.eco,
                  color: Colors.green,
                ),
                title: const Text("NPK"),
                subtitle: const Text(
                  "Nitrogen: Good\nPhosphorus: Medium\nPotassium: Good",
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              color: Colors.green.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "AI Recommendation",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Soil condition is suitable for Rice and Banana cultivation. Add organic compost to improve fertility.",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}