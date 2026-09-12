import 'package:flutter/material.dart';
import '../utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../widgets/voice_text_field.dart';
import 'location_setup_screen.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  _ProfileSetupScreenState createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState
  extends ConsumerState<ProfileSetupScreen> {

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController farmController =
      TextEditingController();

  final TextEditingController cropController =
      TextEditingController();

  String? selectedOccupation;
@override
  void dispose() {
    nameController.dispose();
    farmController.dispose();
    cropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          L10n.get(
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
              L10n.get(
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
              L10n.get(
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
              hintText: L10n.get(
                "Full Name",
                "പൂർണ്ണ പേര്",
                "पूरा नाम",
                "முழு பெயர்",
              ),
            ),

            const SizedBox(height: 20),

            VoiceTextField(
              controller: farmController,
              hintText: L10n.get(
                "Farm Name (Optional)",
                "ഫാമിന്റെ പേര് (നിർബന്ധം ഇല്ല)",
                "खेत का नाम (वैकल्पिक)",
                "பண்ணை பெயர் (விருப்பம்)",
              ),
            ),

            const SizedBox(height: 20),

            VoiceTextField(
              controller: cropController,
              hintText: L10n.get(
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

                labelText: L10n.get(
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
                    L10n.get(
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
                    L10n.get(
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
                    L10n.get(
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
                    L10n.get(
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

                ref.read(userProvider.notifier).update(
                  userOccupation: value ?? "",
                );
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: () {

                  ref.read(userProvider.notifier).update(
                    userName: nameController.text,
                  );

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
                  L10n.get(
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