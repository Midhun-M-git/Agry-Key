import 'package:flutter/material.dart';
import '../core/app_state.dart';
import 'my_orders_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

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
      backgroundColor: Colors.white,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 120,
              ),

              const SizedBox(height: 20),

              Text(
                getText(
                  "Order Placed Successfully",
                  "ഓർഡർ വിജയകരമായി നൽകി",
                  "ऑर्डर सफलतापूर्वक किया गया",
                  "ஆர்டர் வெற்றிகரமாக இடப்பட்டது",
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                getText(
                  "Your order has been sent to the farmer. You can track the order status from My Orders.",
                  "നിങ്ങളുടെ ഓർഡർ കർഷകനിലേക്ക് അയച്ചിട്ടുണ്ട്. My Orders വഴി നില പരിശോധിക്കാം.",
                  "आपका ऑर्डर किसान को भेज दिया गया है। आप My Orders में इसकी स्थिति देख सकते हैं।",
                  "உங்கள் ஆர்டர் விவசாயியிடம் அனுப்பப்பட்டுள்ளது. My Orders பகுதியில் அதன் நிலையை பார்க்கலாம்.",
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const MyOrdersScreen(),
                      ),
                    );
                  },

                  icon: const Icon(
                    Icons.receipt_long,
                  ),

                  label: Text(
                    getText(
                      "View My Orders",
                      "എന്റെ ഓർഡറുകൾ കാണുക",
                      "मेरे ऑर्डर देखें",
                      "என் ஆர்டர்களைப் பார்க்கவும்",
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}