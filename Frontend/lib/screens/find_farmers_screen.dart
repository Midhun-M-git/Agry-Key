import 'package:flutter/material.dart';
import '../utils/localization.dart';
import '../core/app_state.dart';
import '../widgets/voice_text_field.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
class FindFarmersScreen extends ConsumerStatefulWidget {
  const FindFarmersScreen({super.key});

  @override
  _FindFarmersScreenState createState() =>
      _FindFarmersScreenState();
}

class _FindFarmersScreenState
  extends ConsumerState<FindFarmersScreen> {

  final TextEditingController searchController =
      TextEditingController();
Widget farmerCard({
    required String farmerName,
    required String crop,
    required String location,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(
              children: [

                CircleAvatar(
                  backgroundColor:
                      Colors.green.shade100,
                  child: const Icon(
                    Icons.person,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    farmerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(
                  Icons.grass,
                  color: Colors.green,
                ),
                const SizedBox(width: 5),
                Text(crop),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.red,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(location),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},

                    icon: const Icon(
                      Icons.call,
                    ),

                    label: Text(
                      L10n.get(
                        "Call",
                        "വിളിക്കുക",
                        "कॉल करें",
                        "அழைக்கவும்",
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},

                    icon: const Icon(
                      Icons.message,
                    ),

                    label: Text(
                      L10n.get(
                        "Message",
                        "സന്ദേശം",
                        "संदेश",
                        "செய்தி",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  AppState.watchAll(ref);

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,

        title: Text(
          L10n.get(
            "Find Farmers",
            "കർഷകരെ കണ്ടെത്തുക",
            "किसानों को खोजें",
            "விவசாயிகளை கண்டறியுங்கள்",
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            VoiceTextField(
              controller: searchController,

              hintText: L10n.get(
                "Search farmer, crop or location...",
                "കർഷകൻ, വിള അല്ലെങ്കിൽ സ്ഥലം തിരയുക...",
                "किसान, फसल या स्थान खोजें...",
                "விவசாயி, பயிர் அல்லது இடத்தை தேடுங்கள்...",
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [

                  farmerCard(
                    farmerName:
                        "Ramesh Kumar",
                    crop: "Rice",
                    location:
                        "Palakkad, Kerala",
                  ),

                  farmerCard(
                    farmerName:
                        "Suresh Nair",
                    crop: "Banana",
                    location:
                        "Thrissur, Kerala",
                  ),

                  farmerCard(
                    farmerName:
                        "Anil Das",
                    crop: "Tomato",
                    location:
                        "Kochi, Kerala",
                  ),

                  farmerCard(
                    farmerName:
                        "Joseph Mathew",
                    crop: "Coconut",
                    location:
                        "Kottayam, Kerala",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}