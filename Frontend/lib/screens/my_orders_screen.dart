import 'package:flutter/material.dart';
import '../core/app_state.dart';
import 'track_order_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

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
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          getText(
            "My Orders",
            "എന്റെ ഓർഡറുകൾ",
            "मेरे ऑर्डर",
            "என் ஆர்டர்கள்",
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          orderCard(
            context,
            productName: "Premium Rice",
            farmerName: "Ravi Kumar",
            orderId: "ORD001",
            amount: "₹4200",
            status: "Confirmed",
          ),

          const SizedBox(height: 12),

          orderCard(
            context,
            productName: "Tomato",
            farmerName: "Suresh",
            orderId: "ORD002",
            amount: "₹1500",
            status: "In Transit",
          ),

          const SizedBox(height: 12),

          orderCard(
            context,
            productName: "Banana",
            farmerName: "Manoj",
            orderId: "ORD003",
            amount: "₹2500",
            status: "Delivered",
          ),
        ],
      ),
    );
  }

  Widget orderCard(
    BuildContext context, {
    required String productName,
    required String farmerName,
    required String orderId,
    required String amount,
    required String status,
  }) {
    Color statusColor;

    if (status == "Delivered") {
      statusColor = Colors.green;
    } else if (status == "Confirmed") {
      statusColor = Colors.blue;
    } else {
      statusColor = Colors.orange;
    }

    return Card(
      elevation: 3,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              productName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Farmer: $farmerName",
            ),

            const SizedBox(height: 5),

            Text(
              "Order ID: $orderId",
            ),

            const SizedBox(height: 5),

            Text(
              "Amount: $amount",
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Text(
                  "Status: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const TrackOrderScreen(),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.local_shipping,
                ),

                label: const Text(
                  "Track Order",
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}