import 'package:flutter/material.dart';
import '../utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'otp_screen.dart';
import '../core/app_state.dart';
import '../services/token_service.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import 'market_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() =>
      _LoginScreenState();
}

class _LoginScreenState
  extends ConsumerState<LoginScreen> {

  final TextEditingController phoneController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> sendOtp() async {
    final rawPhone = phoneController.text.trim();
    if (rawPhone.length != 10 || int.tryParse(rawPhone) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            L10n.get(
              "Please enter a valid 10-digit mobile number",
              "ദയവായി സാധുവായ 10 അക്ക മൊബൈൽ നമ്പർ നൽകുക",
              "कृपया 10 अंकों का वैध मोबाइल नंबर दर्ज करें",
              "சரியான 10 இலக்க மொபைல் எண்ணை உள்ளிடவும்",
            ),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final formattedPhone = "+91$rawPhone";
    ref.read(authProvider.notifier).setPhoneNumber(formattedPhone);
    await TokenService.saveLanguage(ref.read(languageProvider));
    await TokenService.saveRole(ref.read(authProvider).selectedRole);
    await TokenService.saveUserDetails(
      phoneNumber: formattedPhone,
    );

    final result = await ApiService.sendOtp(formattedPhone);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (result["success"] == true) {
      final demoOtp = result["otp"] as String?;
      if (result["sms_delivered"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              L10n.get(
                "OTP sent to your mobile number",
                "നിങ്ങളുടെ മൊബൈലിലേക്ക് OTP അയച്ചു",
                "आपके मोबाइल पर OTP भेजा गया",
                "உங்கள் மொபைலுக்கு OTP அனுப்பப்பட்டது",
              ),
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
      } else if (demoOtp != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Demo OTP: $demoOtp (Logged to server console)"),
            backgroundColor: Colors.blueGrey.shade800,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(demoOtp: demoOtp),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ?? "Failed to send OTP"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(
          L10n.get(
            "Login",
            "ലോഗിൻ",
            "लॉगिन",
            "உள்நுழைவு",
          ),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 30),

            const Icon(
              Icons.phone_android,
              size: 90,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            Text(
              L10n.get(
                "Welcome to AGRI KEY",
                "AGRI KEY ലേക്ക് സ്വാഗതം",
                "AGRI KEY में आपका स्वागत है",
                "AGRI KEY-க்கு வரவேற்கிறோம்",
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              L10n.get(
                "Login using your mobile number",
                "മൊബൈൽ നമ്പർ ഉപയോഗിച്ച് ലോഗിൻ ചെയ്യുക",
                "मोबाइल नंबर का उपयोग करके लॉगिन करें",
                "மொபைல் எண்ணைப் பயன்படுத்தி உள்நுழைக",
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 40),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.phone,
                  color: Colors.green,
                ),

                prefixText: "+91 ",
                prefixStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),

                labelText: L10n.get(
                  "Mobile Number",
                  "മൊബൈൽ നമ്പർ",
                  "मोबाइल नंबर",
                  "மொபைல் எண்",
                ),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),

                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(
                    color: Colors.green,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : sendOtp,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                  foregroundColor:
                      Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
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
                    : Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send),
                          const SizedBox(width: 8),
                          Text(
                            L10n.get(
                              "Send OTP",
                              "OTP അയയ്ക്കുക",
                              "OTP भेजें",
                              "OTP அனுப்பு",
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const RegisterScreen(),
                  ),
                );
              },
              child: Text(
                L10n.get(
                  "New User? Register",
                  "പുതിയ ഉപയോക്താവാണോ? രജിസ്റ്റർ ചെയ്യുക",
                  "नए उपयोगकर्ता? पंजीकरण करें",
                  "புதிய பயனரா? பதிவு செய்யவும்",
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Divider(),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MarketScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.explore, color: Colors.green),
              label: Text(
                L10n.get(
                  "Explore Live Market Prices (Guest Mode)",
                  "തത്സമയ മാർക്കറ്റ് വിലകൾ കാണുക (അതിഥി മോഡ്)",
                  "लाइव बाजार भाव देखें (अतिथि मोड)",
                  "நேரலை சந்தை விலைகளை பார்க்க (விருந்தினர்)",
                ),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}