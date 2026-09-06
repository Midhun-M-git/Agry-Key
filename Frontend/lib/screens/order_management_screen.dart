import 'package:flutter/material.dart';

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  Widget orderCard({
    required String orderId,
    required String crop,
    required String buyer,
    required String quantity,
    required String date,
    required String status,
  }) {
    Color statusColor = Colors.orange;

    if (status == "Accepted") {
      statusColor = Colors.green;
    }

    if (status == "Delivered") {
      statusColor = Colors.blue;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),

      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  orderId,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),

                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              "Crop: $crop",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),

            Text("Buyer: $buyer"),
            Text("Quantity: $quantity"),
            Text("Date: $date"),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child:
                        const Text("Details"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red,
                      foregroundColor:
                          Colors.white,
                    ),
                    child:
                        const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Order Management"),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView(
          children: [

            orderCard(
              orderId: "ORD001",
              crop: "Rice",
              buyer: "Rahul Traders",
              quantity: "20 Quintal",
              date: "19 Aug 2026",
              status: "Pending",
            ),

            orderCard(
              orderId: "ORD002",
              crop: "Banana",
              buyer: "Fresh Mart",
              quantity: "100 Dozen",
              date: "18 Aug 2026",
              status: "Accepted",
            ),

            orderCard(
              orderId: "ORD003",
              crop: "Tomato",
              buyer: "Metro Market",
              quantity: "500 Kg",
              date: "15 Aug 2026",
              status: "Delivered",
            ),
          ],
        ),
      ),
    );
  }
}