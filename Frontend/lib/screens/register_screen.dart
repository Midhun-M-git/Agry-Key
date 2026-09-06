import 'package:flutter/material.dart';
import '../core/app_state.dart';
import 'farmer_onboarding_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
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

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void registerUser() {

    if (nameController.text.trim().isEmpty) {
      showMessage(
        getText(
          "Please enter your name",
          "ദയവായി പേര് നൽകുക",
          "कृपया अपना नाम दर्ज करें",
          "தயவுசெய்து உங்கள் பெயரை உள்ளிடவும்",
        ),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      showMessage(
        getText(
          "Password must be at least 6 characters",
          "പാസ്‌വേഡ് കുറഞ്ഞത് 6 അക്ഷരങ്ങൾ വേണം",
          "पासवर्ड कम से कम 6 अक्षरों का होना चाहिए",
          "கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்",
        ),
      );
      return;
    }

    if (passwordController.text !=
        confirmPasswordController.text) {
      showMessage(
        getText(
          "Passwords do not match",
          "പാസ്‌വേഡുകൾ പൊരുത്തപ്പെടുന്നില്ല",
          "पासवर्ड मेल नहीं खाते",
          "கடவுச்சொற்கள் பொருந்தவில்லை",
        ),
      );
      return;
    }

    AppState.userName =
        nameController.text.trim();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          getText(
            "Registration Successful",
            "രജിസ്ട്രേഷൻ വിജയകരം",
            "पंजीकरण सफल",
            "பதிவு வெற்றிகரமாக முடிந்தது",
          ),
        ),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const FarmerOnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
            "Register",
            "രജിസ്റ്റർ",
            "पंजीकरण",
            "பதிவு",
          ),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 20),

            const Icon(
              Icons.person_add,
              size: 90,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: getText(
                  "Full Name",
                  "പൂർണ്ണ നാമം",
                  "पूरा नाम",
                  "முழு பெயர்",
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: getText(
                  "Mobile Number",
                  "മൊബൈൽ നമ്പർ",
                  "मोबाइल नंबर",
                  "மொபைல் எண்",
                ),
                hintText:
                    AppState.phoneNumber,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: getText(
                  "Password",
                  "പാസ്‌വേഡ്",
                  "पासवर्ड",
                  "கடவுச்சொல்",
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller:
                  confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: getText(
                  "Confirm Password",
                  "പാസ്‌വേഡ് സ്ഥിരീകരിക്കുക",
                  "पासवर्ड पुष्टि करें",
                  "கடவுச்சொல்லை உறுதிப்படுத்தவும்",
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading:
                    const Icon(Icons.language),
                title: Text(
                  "${getText("Language", "ഭാഷ", "भाषा", "மொழி")} : ${AppState.selectedLanguage}",
                ),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading:
                    const Icon(Icons.work),
                title: Text(
                  "${getText("Role", "പങ്ക്", "भूमिका", "பங்கு")} : ${AppState.selectedRole}",
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: registerUser,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                  foregroundColor:
                      Colors.white,
                ),
                child: Text(
                  getText(
                    "Register",
                    "രജിസ്റ്റർ ചെയ്യുക",
                    "पंजीकरण करें",
                    "பதிவு செய்யவும்",
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}