import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../widgets/voice_text_field.dart';

class GovernmentSchemesScreen extends StatefulWidget {
  const GovernmentSchemesScreen({super.key});

  @override
  State<GovernmentSchemesScreen> createState() =>
      _GovernmentSchemesScreenState();
}

class _GovernmentSchemesScreenState
    extends State<GovernmentSchemesScreen> {

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

  Widget schemeCard(
    String title,
    String description,
    String eligibility,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(
              children: [

                const Icon(
                  Icons.account_balance,
                  color: Colors.green,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    title,
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

            Text(description),

            const SizedBox(height: 10),

            Container(
              padding:
                  const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius:
                    BorderRadius.circular(10),
              ),

              child: Row(
                children: [

                  const Icon(
                    Icons.verified_user,
                    color: Colors.green,
                    size: 20,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      eligibility,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(
                          context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Application portal integration coming soon",
                      ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.open_in_new,
                ),

                label: Text(
                  getText(
                    "View Details",
                    "കൂടുതൽ വിവരങ്ങൾ",
                    "विवरण देखें",
                    "விவரங்களை காண்க",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
            "Government Schemes",
            "സർക്കാർ പദ്ധതികൾ",
            "सरकारी योजनाएँ",
            "அரசுத் திட்டங்கள்",
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          children: [

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),

              child: Column(
                children: [

                  const Icon(
                    Icons.campaign,
                    color: Colors.white,
                    size: 55,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    getText(
                      "Farmer Welfare Schemes",
                      "കർഷക ക്ഷേമ പദ്ധതികൾ",
                      "किसान कल्याण योजनाएँ",
                      "விவசாயி நலத் திட்டங்கள்",
                    ),
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            VoiceTextField(
              controller:
                  searchController,
              hintText: getText(
                "Search schemes...",
                "പദ്ധതികൾ തിരയുക...",
                "योजनाएँ खोजें...",
                "திட்டங்களை தேடுங்கள்...",
              ),
            ),

            const SizedBox(height: 20),

            schemeCard(
              "PM-KISAN",
              getText(
                "Income support provided directly to eligible farmers.",
                "അർഹരായ കർഷകർക്ക് നേരിട്ടുള്ള സാമ്പത്തിക സഹായം.",
                "योग्य किसानों को प्रत्यक्ष आय सहायता।",
                "தகுதியான விவசாயிகளுக்கு நேரடி வருமான உதவி.",
              ),
              getText(
                "Small and marginal farmers",
                "ചെറിയ കർഷകർ",
                "छोटे किसान",
                "சிறு விவசாயிகள்",
              ),
            ),

            schemeCard(
              "PM Fasal Bima Yojana",
              getText(
                "Crop insurance scheme protecting farmers from losses.",
                "വിളനാശത്തിൽ നിന്ന് സംരക്ഷിക്കുന്ന ഇൻഷുറൻസ് പദ്ധതി.",
                "फसल हानि से सुरक्षा देने वाली योजना।",
                "பயிர் இழப்பிலிருந்து பாதுகாக்கும் திட்டம்.",
              ),
              getText(
                "All registered farmers",
                "രജിസ്റ്റർ ചെയ്ത കർഷകർ",
                "पंजीकृत किसान",
                "பதிவு செய்யப்பட்ட விவசாயிகள்",
              ),
            ),

            schemeCard(
              "Kisan Credit Card",
              getText(
                "Provides easy access to agricultural loans.",
                "കാർഷിക വായ്പകൾ എളുപ്പത്തിൽ ലഭ്യമാക്കുന്നു.",
                "कृषि ऋण आसानी से उपलब्ध कराता है।",
                "விவசாய கடன் எளிதில் பெற உதவுகிறது.",
              ),
              getText(
                "Farmers with cultivable land",
                "കൃഷിയോഗ്യ ഭൂമിയുള്ളവർ",
                "खेती योग्य भूमि वाले किसान",
                "விவசாய நிலம் கொண்டவர்கள்",
              ),
            ),

            schemeCard(
              "State Agriculture Subsidy",
              getText(
                "Support for seeds, fertilizers and equipment.",
                "വിത്തുകൾ, വളങ്ങൾ, ഉപകരണങ്ങൾ എന്നിവയ്ക്കുള്ള സഹായം.",
                "बीज, उर्वरक और उपकरण सहायता.",
                "விதைகள், உரங்கள் மற்றும் உபகரண உதவி.",
              ),
              getText(
                "Depends on state guidelines",
                "സംസ്ഥാന മാനദണ്ഡങ്ങൾ അനുസരിച്ച്",
                "राज्य दिशा-निर्देशों के अनुसार",
                "மாநில வழிகாட்டுதலின்படி",
              ),
            ),
          ],
        ),
      ),
    );
  }
}