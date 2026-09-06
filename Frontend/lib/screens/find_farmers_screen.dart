import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../widgets/voice_text_field.dart';

class FindFarmersScreen extends StatefulWidget {
  const FindFarmersScreen({super.key});

  @override
  State<FindFarmersScreen> createState() =>
      _FindFarmersScreenState();
}

class _FindFarmersScreenState
    extends State<FindFarmersScreen> {

  final TextEditingController searchController =
      TextEditingController();

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
                      getText(
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
                      getText(
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

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,

        title: Text(
          getText(
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

              hintText: getText(
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