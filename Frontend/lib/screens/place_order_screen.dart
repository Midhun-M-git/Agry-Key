import 'package:flutter/material.dart';
import '../widgets/voice_text_field.dart';
import 'order_success_screen.dart';

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({super.key});

  @override
  State<PlaceOrderScreen> createState() =>
      _PlaceOrderScreenState();
}

class _PlaceOrderScreenState
    extends State<PlaceOrderScreen> {

  final TextEditingController quantityController =
      TextEditingController();

  final TextEditingController addressController =
      TextEditingController();

  final TextEditingController notesController =
      TextEditingController();

  double pricePerKg = 40;
  double totalAmount = 0;

  void calculateTotal() {
    double qty =
        double.tryParse(quantityController.text) ??
            0;

    setState(() {
      totalAmount = qty * pricePerKg;
    });
  }

  @override
  void dispose() {
    quantityController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Place Order"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Card(
              elevation: 3,
              child: Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Product Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const ListTile(
                      leading: Icon(
                        Icons.grass,
                        color: Colors.green,
                      ),
                      title: Text("Rice"),
                      subtitle:
                          Text("Premium Quality"),
                    ),

                    const Divider(),

                    const Text(
                      "Farmer: Ramesh Kumar",
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "Price: ₹40 / Kg",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Quantity (Kg)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: quantityController,
              keyboardType:
                  TextInputType.number,

              onChanged: (value) {
                calculateTotal();
              },

              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.scale),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Delivery Address",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            VoiceTextField(
              controller: addressController,
              hintText:
                  "Enter delivery address",
            ),

            const SizedBox(height: 20),

            const Text(
              "Additional Notes",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            VoiceTextField(
              controller: notesController,
              hintText:
                  "Any special instructions?",
            ),

            const SizedBox(height: 20),

            Card(
              color: Colors.green.shade50,

              child: Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Column(
                  children: [

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        const Text(
                          "Price Per Kg",
                        ),

                        Text(
                          "₹${pricePerKg.toStringAsFixed(0)}",
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        const Text(
                          "Total Amount",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        Text(
                          "₹${totalAmount.toStringAsFixed(0)}",
                          style:
                              const TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: () {

                  if (quantityController.text
                      .trim()
                      .isEmpty) {

                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please enter quantity",
                        ),
                      ),
                    );

                    return;
                  }

                  if (addressController.text
                      .trim()
                      .isEmpty) {

                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please enter address",
                        ),
                      ),
                    );

                    return;
                  }

                 
                  Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => const OrderSuccessScreen(),
  ),
);
                },

                icon: const Icon(
                  Icons.shopping_cart_checkout,
                ),

                label: const Text(
                  "Place Order",
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