import 'package:flutter/material.dart';
import '../utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'otp_screen.dart';
import '../core/app_state.dart';
import '../services/token_service.dart';
import '../services/api_service.dart';
import 'market_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-strip country code prefix if autofilled by Android
    phoneController.addListener(() {
      final text = phoneController.text;
      if (text.startsWith("+91")) {
        phoneController.text = text.substring(3).trim();
        phoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: phoneController.text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  String? _normalizeInput(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10 && RegExp(r'^[6-9]').hasMatch(digits)) {
      return "+91$digits";
    } else if (digits.length == 12 && digits.startsWith('91') && RegExp(r'^[6-9]').hasMatch(digits.substring(2))) {
      return "+$digits";
    } else if (digits.length == 11 && digits.startsWith('0') && RegExp(r'^[6-9]').hasMatch(digits.substring(1))) {
      return "+91${digits.substring(1)}";
    }
    return null;
  }

  Future<void> sendOtp() async {
    final rawPhone = phoneController.text.trim();
    final normalized = _normalizeInput(rawPhone);

    if (normalized == null) {
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

    ref.read(authProvider.notifier).setPhoneNumber(normalized);
    await TokenService.saveLanguage(ref.read(languageProvider));
    await TokenService.saveRole(
      ref.read(authProvider).selectedRole.isNotEmpty
          ? ref.read(authProvider).selectedRole
          : "FARMER",
    );
    await TokenService.saveUserDetails(
      phoneNumber: normalized,
    );

    final result = await ApiService.sendOtp(normalized);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (result["success"] == true) {
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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OtpScreen(),
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
        elevation: 0,
        title: Text(
          L10n.get(
            "Login with Mobile",
            "മൊബൈൽ ലോഗിൻ",
            "मोबाइल लॉगिन",
            "மொபைல் உள்நுழைவு",
          ),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Brand Icon
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_android,
                  size: 72,
                  color: Colors.green,
                ),
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                L10n.get(
                  "Use your mobile number to continue",
                  "തുടരാൻ നിങ്ങളുടെ മൊബൈൽ നമ്പർ ഉപയോഗിക്കുക",
                  "आगे बढ़ने के लिए अपना मोबाइल नंबर दर्ज करें",
                  "தொடர உங்கள் மொபைல் எண்ணைப் பயன்படுத்தவும்",
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 35),

              // Mobile Number Field with Android Phone Number Hint support
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                autofillHints: const [
                  AutofillHints.telephoneNumber,
                  AutofillHints.telephoneNumberNational,
                ],
                maxLength: 10,
                decoration: InputDecoration(
                  counterText: "",
                  prefixIcon: const Icon(
                    Icons.phone,
                    color: Colors.green,
                  ),
                  prefixText: "+91 ",
                  prefixStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  labelText: L10n.get(
                    "Mobile Number",
                    "മൊബൈൽ നമ്പർ",
                    "मोबाइल नंबर",
                    "மொபைல் எண்",
                  ),
                  hintText: "9876543210",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.green,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Submit / Continue Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_forward),
                            const SizedBox(width: 8),
                            Text(
                              L10n.get(
                                "Continue with mobile number",
                                "മൊബൈൽ നമ്പർ ഉപയോഗിച്ച് തുടരുക",
                                "मोबाइल नंबर से आगे बढ़ें",
                                "மொபைல் எண் மூலம் தொடரவும்",
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 25),

              const Divider(),

              const SizedBox(height: 15),

              // Guest explore live market prices
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
      ),
    );
  }
}