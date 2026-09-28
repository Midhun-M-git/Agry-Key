import 'package:flutter/material.dart';
import '../utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../services/token_service.dart';
import '../services/api_service.dart';
import 'farmer_onboarding_screen.dart';
import 'buyer_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
  extends ConsumerState<RegisterScreen> {

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  void showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  Future<void> registerUser() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      showMessage(
        L10n.get(
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
        L10n.get(
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
        L10n.get(
          "Passwords do not match",
          "പാസ്‌വേഡുകൾ പൊരുത്തപ്പെടുന്നില്ല",
          "पासवर्ड मेल नहीं खाते",
          "கடவுச்சொற்கள் பொருந்தவில்லை",
        ),
      );
      return;
    }

    final phone = ref.read(authProvider).phoneNumber.isNotEmpty
        ? ref.read(authProvider).phoneNumber
        : AppState.phoneNumber;

    if (phone.isEmpty) {
      showMessage("Phone number is missing. Please restart registration.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final role = AppState.selectedRole.isNotEmpty ? AppState.selectedRole : "FARMER";
    String langCode = 'en';
    switch (AppState.selectedLanguage.toLowerCase()) {
      case 'malayalam': langCode = 'ml'; break;
      case 'hindi': langCode = 'hi'; break;
      case 'tamil': langCode = 'ta'; break;
      default: langCode = 'en';
    }

    final result = await ApiService.register(
      phoneNumber: phone,
      password: passwordController.text,
      fullName: name,
      role: role,
      preferredLanguage: langCode,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (result["success"] == true) {
      ref.read(userProvider.notifier).update(
        userName: name,
      );
      await TokenService.saveLanguage(ref.read(languageProvider));
      await TokenService.saveRole(role);
      await TokenService.saveUserDetails(
        userName: name,
        phoneNumber: phone,
      );

      final accessToken = result["access_token"] as String?;
      final refreshToken = result["refresh_token"] as String?;
      if (accessToken != null && refreshToken != null) {
        await TokenService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        ref.read(authProvider.notifier).setTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      showMessage(
        L10n.get(
          "Registration Successful",
          "രജിസ്ട്രേഷൻ വിജയകരം",
          "पंजीकरण सफल",
          "பதிவு வெற்றிகரமாக முடிந்தது",
        ),
        isError: false,
      );

      if (role == "BUYER") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const BuyerScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const FarmerOnboardingScreen(),
          ),
        );
      }
    } else {
      showMessage(result["message"] ?? "Registration failed");
    }
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
    AppState.watchAll(ref);

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          L10n.get(
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
                labelText: L10n.get(
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
                labelText: L10n.get(
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
                labelText: L10n.get(
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
                labelText: L10n.get(
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
                  "${L10n.get("Language", "ഭാഷ", "भाषा", "மொழி")} : ${AppState.selectedLanguage}",
                ),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading:
                    const Icon(Icons.work),
                title: Text(
                  "${L10n.get("Role", "പങ്ക്", "भूमिका", "பங்கு")} : ${AppState.selectedRole}",
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : registerUser,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                  foregroundColor:
                      Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        L10n.get(
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