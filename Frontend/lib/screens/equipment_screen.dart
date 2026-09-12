import 'package:flutter/material.dart';
import '../utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';

class EquipmentScreen extends ConsumerWidget {
  const EquipmentScreen({super.key});
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
  Widget build(BuildContext context, WidgetRef ref) {
    AppState.watchAll(ref);
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          L10n.get(
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
              L10n.get(
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