import 'package:flutter/material.dart';
import '../core/app_state.dart';

class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

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

  Widget equipmentCard(
    String name,
    String owner,
    String location,
    String phone,
  ) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: const Icon(
          Icons.agriculture,
          color: Colors.green,
        ),
        title: Text(name),
        subtitle: Text(
          "$owner\n$location\n$phone",
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          getText(
            "Equipment Rental",
            "കാർഷിക ഉപകരണങ്ങൾ",
            "कृषि उपकरण",
            "வேளாண் உபகரணங்கள்",
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Text(
              getText(
                "Available Equipment",
                "ലഭ്യമായ ഉപകരണങ്ങൾ",
                "उपलब्ध उपकरण",
                "கிடைக்கும் உபகரணங்கள்",
              ),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            equipmentCard(
              "Tractor",
              "Ramesh",
              "Palakkad",
              "+91 9876543210",
            ),

            equipmentCard(
              "Power Tiller",
              "Suresh",
              "Thrissur",
              "+91 9876501234",
            ),

            equipmentCard(
              "Water Pump",
              "Anil",
              "Malappuram",
              "+91 9876505678",
            ),

            equipmentCard(
              "Crop Sprayer",
              "Manoj",
              "Kozhikode",
              "+91 9876509999",
            ),

            equipmentCard(
              "Harvest Machine",
              "Rajan",
              "Palakkad",
              "+91 9876511111",
            ),
          ],
        ),
      ),
    );
  }
}