import 'package:flutter/material.dart';
import 'otp_screen.dart';
import '../core/app_state.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final TextEditingController phoneController =
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
    phoneController.dispose();
    super.dispose();
  }

  void sendOtp() {
    if (phoneController.text.trim().length !=
        10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter a valid 10-digit mobile number",
          ),
        ),
      );
      return;
    }

    AppState.phoneNumber =
        "+91${phoneController.text.trim()}";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const OtpScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(
          getText(
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
              getText(
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
              getText(
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

                labelText: getText(
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
                onPressed: sendOtp,
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
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send),

                    const SizedBox(width: 8),

                    Text(
                      getText(
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
                getText(
                  "New User? Register",
                  "പുതിയ ഉപയോക്താവാണോ? രജിസ്റ്റർ ചെയ്യുക",
                  "नए उपयोगकर्ता? पंजीकरण करें",
                  "புதிய பயனரா? பதிவு செய்யவும்",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}