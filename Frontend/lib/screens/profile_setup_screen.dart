import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../widgets/voice_text_field.dart';
import 'location_setup_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState
    extends State<ProfileSetupScreen> {

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController farmController =
      TextEditingController();

  final TextEditingController cropController =
      TextEditingController();

  String? selectedOccupation;

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
    nameController.dispose();
    farmController.dispose();
    cropController.dispose();
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
            "Profile Setup",
            "പ്രൊഫൈൽ സജ്ജീകരണം",
            "प्रोफ़ाइल सेटअप",
            "சுயவிவர அமைப்பு",
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 20),

            CircleAvatar(
              radius: 50,
              backgroundColor:
                  Colors.green.shade100,
              child: const Icon(
                Icons.person,
                size: 55,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              getText(
                "Complete Your Profile",
                "നിങ്ങളുടെ പ്രൊഫൈൽ പൂർത്തിയാക്കുക",
                "अपनी प्रोफ़ाइल पूरी करें",
                "உங்கள் சுயவிவரத்தை பூர்த்தி செய்யவும்",
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            Text(
              getText(
                "Use voice or text to complete your profile.",
                "ശബ്ദമോ ടെക്സ്റ്റോ ഉപയോഗിച്ച് പ്രൊഫൈൽ പൂർത്തിയാക്കുക.",
                "आवाज़ या टेक्स्ट का उपयोग करके प्रोफ़ाइल पूरी करें।",
                "குரல் அல்லது உரையை பயன்படுத்தி சுயவிவரத்தை நிரப்பவும்.",
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            VoiceTextField(
              controller: nameController,
              hintText: getText(
                "Full Name",
                "പൂർണ്ണ പേര്",
                "पूरा नाम",
                "முழு பெயர்",
              ),
            ),

            const SizedBox(height: 20),

            VoiceTextField(
              controller: farmController,
              hintText: getText(
                "Farm Name (Optional)",
                "ഫാമിന്റെ പേര് (നിർബന്ധം ഇല്ല)",
                "खेत का नाम (वैकल्पिक)",
                "பண்ணை பெயர் (விருப்பம்)",
              ),
            ),

            const SizedBox(height: 20),

            VoiceTextField(
              controller: cropController,
              hintText: getText(
                "Main Crop (Optional)",
                "പ്രധാന വിള (നിർബന്ധം ഇല്ല)",
                "मुख्य फसल (वैकल्पिक)",
                "முக்கிய பயிர் (விருப்பம்)",
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedOccupation,

              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.work),

                labelText: getText(
                  "Occupation",
                  "തൊഴിൽ",
                  "व्यवसाय",
                  "தொழில்",
                ),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),

              items: [

                DropdownMenuItem(
                  value: "Farmer",
                  child: Text(
                    getText(
                      "Farmer",
                      "കർഷകൻ",
                      "किसान",
                      "விவசாயி",
                    ),
                  ),
                ),

                DropdownMenuItem(
                  value: "Buyer",
                  child: Text(
                    getText(
                      "Buyer",
                      "വാങ്ങുന്നയാൾ",
                      "खरीदार",
                      "வாங்குபவர்",
                    ),
                  ),
                ),

                DropdownMenuItem(
                  value: "Agriculture Expert",
                  child: Text(
                    getText(
                      "Agriculture Expert",
                      "കാർഷിക വിദഗ്ധൻ",
                      "कृषि विशेषज्ञ",
                      "விவசாய நிபுணர்",
                    ),
                  ),
                ),

                DropdownMenuItem(
                  value: "Student",
                  child: Text(
                    getText(
                      "Student",
                      "വിദ്യാർത്ഥി",
                      "छात्र",
                      "மாணவர்",
                    ),
                  ),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  selectedOccupation = value;
                });

                AppState.userOccupation =
                    value ?? "";
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: () {

                  AppState.userName =
                      nameController.text;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const LocationSetupScreen(),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                  foregroundColor:
                      Colors.white,
                ),

                child: Text(
                  getText(
                    "Continue",
                    "തുടരുക",
                    "जारी रखें",
                    "தொடரவும்",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}