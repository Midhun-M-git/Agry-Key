import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  Widget trackingStep({
    required String title,
    required bool completed,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor:
              completed ? Colors.green : Colors.grey,
          child: Icon(
            completed ? Icons.check : Icons.circle,
            size: 16,
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15,
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Tracking"),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Card(
              elevation: 4,

              child: Padding(
                padding: const EdgeInsets.all(15),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: const [

                    Text(
                      "Order #ORD001",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text("Crop: Rice"),
                    Text("Quantity: 20 Quintal"),
                    Text("Farmer: Ravi Kumar"),
                    Text("Buyer: Fresh Mart"),

                    SizedBox(height: 10),

                    Text(
                      "Expected Delivery: 25 Aug 2026",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Delivery Progress",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            trackingStep(
              title: "Order Placed",
              completed: true,
            ),

            trackingStep(
              title: "Farmer Accepted",
              completed: true,
            ),

            trackingStep(
              title: "Packed",
              completed: true,
            ),

            trackingStep(
              title: "In Transit",
              completed: false,
            ),

            trackingStep(
              title: "Delivered",
              completed: false,
            ),

            const SizedBox(height: 25),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.local_shipping,
                  color: Colors.green,
                ),
                title:
                    const Text("Delivery Partner"),
                subtitle:
                    const Text("AGRI KEY Logistics"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}