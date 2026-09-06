import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState
    extends State<PaymentScreen> {

  String selectedPayment = "UPI";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
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
                      "Order Summary",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text("Crop: Rice"),
                    Text("Quantity: 20 Quintal"),
                    Text("Price: ₹4200"),

                    Divider(),

                    Text(
                      "Total Amount: ₹84,000",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Select Payment Method",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            RadioListTile(
              value: "UPI",
              groupValue:
                  selectedPayment,
              title: const Text("UPI"),
              onChanged: (value) {
                setState(() {
                  selectedPayment =
                      value.toString();
                });
              },
            ),

            RadioListTile(
              value: "Net Banking",
              groupValue:
                  selectedPayment,
              title: const Text(
                  "Net Banking"),
              onChanged: (value) {
                setState(() {
                  selectedPayment =
                      value.toString();
                });
              },
            ),

            RadioListTile(
              value: "Wallet",
              groupValue:
                  selectedPayment,
              title:
                  const Text("Wallet"),
              onChanged: (value) {
                setState(() {
                  selectedPayment =
                      value.toString();
                });
              },
            ),

            RadioListTile(
              value: "Cash On Delivery",
              groupValue:
                  selectedPayment,
              title: const Text(
                  "Cash On Delivery"),
              onChanged: (value) {
                setState(() {
                  selectedPayment =
                      value.toString();
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: () {

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Order Placed Successfully",
                      ),
                    ),
                  );
                },

                icon:
                    const Icon(Icons.payment),

                label: const Text(
                  "Pay & Place Order",
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                  foregroundColor:
                      Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}