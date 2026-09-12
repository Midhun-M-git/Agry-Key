import 'package:flutter/material.dart';
import '../utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import 'chat_farmer_screen.dart';

class TrackOrderScreen extends ConsumerWidget {
  const TrackOrderScreen({super.key});
@override
  Widget build(BuildContext context, WidgetRef ref) {
    AppState.watchAll(ref);
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          L10n.get(
            "Track Order",
            "ഓർഡർ ട്രാക്ക് ചെയ്യുക",
            "ऑर्डर ट्रैक करें",
            "ஆர்டரை கண்காணிக்கவும்",
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.inventory_2,
                  color: Colors.green,
                ),
                title: const Text("Premium Rice"),
                subtitle: const Text(
                  "Order ID: ORD001",
                ),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Ravi Kumar"),
                subtitle: Text(
                  L10n.get(
                    "Farmer",
                    "കർഷകൻ",
                    "किसान",
                    "விவசாயி",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                ),
                title: Text(
                  L10n.get(
                    "Estimated Delivery",
                    "പ്രതീക്ഷിക്കുന്ന ഡെലിവറി",
                    "अनुमानित डिलीवरी",
                    "மதிப்பிடப்பட்ட டெலிவரி",
                  ),
                ),
                subtitle: const Text(
                  "25 Aug 2026",
                ),
              ),
            ),

            const SizedBox(height: 25),

            orderStep(
              L10n.get(
                "Order Placed",
                "ഓർഡർ നൽകി",
                "ऑर्डर दिया गया",
                "ஆர்டர் செய்யப்பட்டது",
              ),
              true,
            ),

            orderStep(
              L10n.get(
                "Farmer Accepted",
                "കർഷകൻ അംഗീകരിച്ചു",
                "किसान ने स्वीकार किया",
                "விவசாயி ஏற்றுக்கொண்டார்",
              ),
              true,
            ),

            orderStep(
              L10n.get(
                "Packed",
                "പാക്ക് ചെയ്തു",
                "पैक किया गया",
                "பேக் செய்யப்பட்டது",
              ),
              true,
            ),

            orderStep(
              L10n.get(
                "Shipped",
                "അയച്ചു",
                "भेज दिया गया",
                "அனுப்பப்பட்டது",
              ),
              true,
            ),

            orderStep(
              L10n.get(
                "Delivered",
                "ഡെലിവർ ചെയ്തു",
                "डिलीवर किया गया",
                "டெலிவரி செய்யப்பட்டது",
              ),
              false,
            ),

            const Spacer(),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Calling feature will be connected with backend.",
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.call),
                    label: Text(
                      L10n.get(
                        "Call",
                        "വിളിക്കുക",
                        "कॉल",
                        "அழை",
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ChatFarmerScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: Text(
                      L10n.get(
                        "Chat",
                        "ചാറ്റ്",
                        "चैट",
                        "அரட்டை",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget orderStep(
    String title,
    bool completed,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Column(
          children: [

            Icon(
              completed
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: completed
                  ? Colors.green
                  : Colors.grey,
            ),

            Container(
              width: 2,
              height: 45,
              color: Colors.grey.shade300,
            ),
          ],
        ),

        const SizedBox(width: 15),

        Padding(
          padding: const EdgeInsets.only(top: 3),

          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: completed
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}