import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../widgets/voice_text_field.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() =>
      _MarketScreenState();
}

class _MarketScreenState
    extends State<MarketScreen> {

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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          getText(
            "Market Prices",
            "മാർക്കറ്റ് വിലകൾ",
            "बाज़ार मूल्य",
            "சந்தை விலைகள்",
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Row(
                    children: [

                      CircleAvatar(
                        backgroundColor:
                            Colors.white,
                        child: Icon(
                          Icons.store,
                          color: Colors.green,
                        ),
                      ),

                      SizedBox(width: 10),

                      Text(
                        "AGRI KEY Market",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Check crop prices using voice or text search.",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                ),

                title: Text(
                  AppState.userLocation.isEmpty
                      ? "Location Not Set"
                      : AppState.userLocation,
                ),
              ),
            ),

            const SizedBox(height: 15),

            VoiceTextField(
              controller: searchController,
              hintText: getText(
                "Search Crop",
                "വിള തിരയുക",
                "फसल खोजें",
                "பயிரைத் தேடுங்கள்",
              ),
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 8,
              runSpacing: 8,

              children: const [

                Chip(
                  label: Text("All"),
                ),

                Chip(
                  label: Text("Vegetables"),
                ),

                Chip(
                  label: Text("Fruits"),
                ),

                Chip(
                  label: Text("Grains"),
                ),

                Chip(
                  label: Text("Spices"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            marketCard(
              "Rice",
              "₹42 / Kg",
              "+2.5%",
              true,
            ),

            marketCard(
              "Tomato",
              "₹35 / Kg",
              "-1.2%",
              false,
            ),

            marketCard(
              "Potato",
              "₹28 / Kg",
              "+0.8%",
              true,
            ),

            marketCard(
              "Onion",
              "₹40 / Kg",
              "+3.1%",
              true,
            ),

            marketCard(
              "Banana",
              "₹55 / Dozen",
              "-0.5%",
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget marketCard(
    String crop,
    String price,
    String change,
    bool isUp,
  ) {
    return Card(
      elevation: 3,
      margin:
          const EdgeInsets.only(bottom: 12),

      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor:
              Color(0xFFE8F5E9),

          child: Icon(
            Icons.agriculture,
            color: Colors.green,
          ),
        ),

        title: Text(
          crop,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        subtitle: Text(price),

        trailing: Text(
          change,
          style: TextStyle(
            color:
                isUp ? Colors.green : Colors.red,
            fontWeight:
                FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}