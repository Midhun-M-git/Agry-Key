import 'package:flutter/material.dart';
import '../core/app_state.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState
    extends State<RoleSelectionScreen> {

  String? selectedRole;

  @override
  void initState() {
    super.initState();

    if (AppState.selectedRole.isNotEmpty) {
      selectedRole = AppState.selectedRole;
    }
  }

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

  void selectRole(String role) {
    setState(() {
      selectedRole = role;
      AppState.selectedRole = role;
    });

    debugPrint(
      "Selected Role Saved: ${AppState.selectedRole}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AgriKey"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 20),

            Text(
              getText(
                "Who Are You?",
                "നിങ്ങൾ ആരാണ്?",
                "आप कौन हैं?",
                "நீங்கள் யார்?",
              ),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Card(
              color: selectedRole == "FARMER"
                  ? Colors.green.shade100
                  : null,

              child: ListTile(
                leading: const Icon(
                  Icons.agriculture,
                  size: 40,
                  color: Colors.green,
                ),

                title: Text(
                  getText(
                    "Farmer / Producer",
                    "കർഷകൻ / ഉത്പാദകൻ",
                    "किसान / उत्पादक",
                    "விவசாயி / உற்பத்தியாளர்",
                  ),
                ),

                subtitle: Text(
                  getText(
                    "Manage crops, weather, diseases and sell products.",
                    "വിളകൾ, കാലാവസ്ഥ, രോഗങ്ങൾ എന്നിവ നിയന്ത്രിക്കുകയും ഉൽപ്പന്നങ്ങൾ വിൽക്കുകയും ചെയ്യുക.",
                    "फसल, मौसम, रोग प्रबंधन और उत्पाद बिक्री करें।",
                    "பயிர்கள், வானிலை, நோய்கள் மற்றும் விற்பனையை நிர்வகிக்கவும்.",
                  ),
                ),

                onTap: () => selectRole("FARMER"),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              color: selectedRole == "BUYER"
                  ? Colors.blue.shade100
                  : null,

              child: ListTile(
                leading: const Icon(
                  Icons.shopping_cart,
                  size: 40,
                  color: Colors.blue,
                ),

                title: Text(
                  getText(
                    "Buyer / Consumer",
                    "വാങ്ങുന്നയാൾ / ഉപഭോക്താവ്",
                    "खरीदार / उपभोक्ता",
                    "வாங்குபவர் / நுகர்வோர்",
                  ),
                ),

                subtitle: Text(
                  getText(
                    "Browse products and buy directly from farmers.",
                    "കർഷകരിൽ നിന്ന് നേരിട്ട് ഉൽപ്പന്നങ്ങൾ വാങ്ങുക.",
                    "किसानों से सीधे उत्पाद खरीदें।",
                    "விவசாயிகளிடமிருந்து நேரடியாக வாங்குங்கள்.",
                  ),
                ),

                onTap: () => selectRole("BUYER"),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: selectedRole == null
                    ? null
                    : () {

                        AppState.selectedRole =
                            selectedRole!;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const LoginScreen(),
                          ),
                        );
                      },

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