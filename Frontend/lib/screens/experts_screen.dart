import 'package:flutter/material.dart';
import '../core/app_state.dart';

class ExpertsScreen extends StatelessWidget {
  const ExpertsScreen({super.key});

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

  Widget expertCard(
    IconData icon,
    String title,
    String name,
    String location,
    String phone,
  ) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.green,
        ),
        title: Text(title),
        subtitle: Text(
          "$name\n$location\n$phone",
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
            "Nearby Experts",
            "സമീപ വിദഗ്ധർ",
            "नज़दीकी विशेषज्ञ",
            "அருகிலுள்ள நிபுணர்கள்",
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            expertCard(
              Icons.account_balance,
              "Krishi Bhavan",
              "Agriculture Officer",
              "Palakkad",
              "+91 9876543210",
            ),

            expertCard(
              Icons.science,
              "Soil Testing Center",
              "Soil Expert",
              "Thrissur",
              "+91 9876543220",
            ),

            expertCard(
              Icons.local_hospital,
              "Veterinary Doctor",
              "Dr. Kumar",
              "Malappuram",
              "+91 9876543230",
            ),

            expertCard(
              Icons.support_agent,
              "Farm Consultant",
              "Mr. Rajesh",
              "Kozhikode",
              "+91 9876543240",
            ),
          ],
        ),
      ),
    );
  }
}