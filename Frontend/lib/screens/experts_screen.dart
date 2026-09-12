import 'package:flutter/material.dart';
import '../utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';

class ExpertsScreen extends ConsumerWidget {
  const ExpertsScreen({super.key});
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
  Widget build(BuildContext context, WidgetRef ref) {
    AppState.watchAll(ref);
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          L10n.get(
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