import 'package:flutter/material.dart';
import '../utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import 'profile_setup_screen.dart';

class OtpScreen extends ConsumerWidget {
  const OtpScreen({super.key});
@override
  Widget build(BuildContext context, WidgetRef ref) {
    AppState.watchAll(ref);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          L10n.get(
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
              L10n.get(
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
              L10n.get(
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

                labelText: L10n.get(
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
                      L10n.get(
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
                L10n.get(
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