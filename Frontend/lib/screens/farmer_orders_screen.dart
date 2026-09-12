import 'package:flutter/material.dart';

class FarmerOrdersScreen extends StatelessWidget {
  const FarmerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Incoming Orders"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          orderCard(
            buyerName: "Arjun",
            product: "Premium Rice",
            quantity: "5 Quintal",
            amount: "₹4200",
          ),

          const SizedBox(height: 12),

          orderCard(
            buyerName: "Rahul",
            product: "Tomato",
            quantity: "100 Kg",
            amount: "₹1500",
          ),
        ],
      ),
    );
  }

  Widget orderCard({
    required String buyerName,
    required String product,
    required String quantity,
    required String amount,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              product,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text("Buyer: $buyerName"),
            Text("Quantity: $quantity"),
            Text("Amount: $amount"),

            const SizedBox(height: 15),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check),
                    label: const Text("Accept"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.close),
                    label: const Text("Reject"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
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
}