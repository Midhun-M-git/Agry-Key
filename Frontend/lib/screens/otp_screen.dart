import 'package:flutter/material.dart';
import '../core/app_state.dart';
import 'profile_setup_screen.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getText(
            "OTP Verification",
            "OTP സ്ഥിരീകരണം",
            "OTP सत्यापन",
            "OTP சரிபார்ப்பு",
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 20),

            const Icon(
              Icons.verified_user,
              size: 80,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            Text(
              getText(
                "Enter OTP",
                "OTP നൽകുക",
                "OTP दर्ज करें",
                "OTP உள்ளிடவும்",
              ),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              getText(
                "We have sent a verification code to your mobile number",
                "നിങ്ങളുടെ മൊബൈൽ നമ്പറിലേക്ക് പരിശോധന കോഡ് അയച്ചിട്ടുണ്ട്",
                "आपके मोबाइल नंबर पर सत्यापन कोड भेजा गया है",
                "உங்கள் மொபைல் எண்ணிற்கு சரிபார்ப்பு குறியீடு அனுப்பப்பட்டுள்ளது",
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 40),

            TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),

                labelText: getText(
                  "OTP",
                  "OTP",
                  "OTP",
                  "OTP",
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ProfileSetupScreen(),
                    ),
                  );
                },

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [

                    const Icon(Icons.check_circle),

                    const SizedBox(width: 8),

                    Text(
                      getText(
                        "Verify OTP",
                        "OTP സ്ഥിരീകരിക്കുക",
                        "OTP सत्यापित करें",
                        "OTP சரிபார்க்கவும்",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {},

              child: Text(
                getText(
                  "Resend OTP",
                  "OTP വീണ്ടും അയയ്ക്കുക",
                  "OTP पुनः भेजें",
                  "OTP மீண்டும் அனுப்பு",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}