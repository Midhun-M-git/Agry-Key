import 'package:flutter/material.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {

    double subtotal = 84000;
    double gst = subtotal * 0.05;
    double total = subtotal + gst;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice"),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Card(
          elevation: 4,

          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Center(
                  child: Text(
                    "AGRI KEY",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Invoice No: INV-2026-001",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                const Text("Farmer: Ravi Kumar"),
                const Text("Buyer: Fresh Mart"),
                const Text("Location: Palakkad"),

                const Divider(height: 30),

                const Text(
                  "Product Details",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text("Crop: Rice"),
                const Text("Quantity: 20 Quintal"),
                const Text("Rate: ₹4200"),

                const Divider(height: 30),

                Text(
                  "Subtotal: ₹${subtotal.toStringAsFixed(2)}",
                ),

                Text(
                  "GST (5%): ₹${gst.toStringAsFixed(2)}",
                ),

                const SizedBox(height: 10),

                Text(
                  "Total: ₹${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: () {},

                    icon: const Icon(
                      Icons.picture_as_pdf,
                    ),

                    label:
                        const Text("Download PDF"),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green,
                      foregroundColor:
                          Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,

                  child: OutlinedButton.icon(
                    onPressed: () {},

                    icon:
                        const Icon(Icons.share),

                    label:
                        const Text("Share Invoice"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}