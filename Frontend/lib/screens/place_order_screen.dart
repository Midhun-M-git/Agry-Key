import 'package:flutter/material.dart';
import '../widgets/voice_text_field.dart';
import 'order_success_screen.dart';
import 'payment_screen.dart';

class PlaceOrderScreen extends StatefulWidget {
  final int? productId;
  final String? productName;
  final double? pricePerKg;
  final String? unit;
  final String? farmerName;

  const PlaceOrderScreen({
    super.key,
    this.productId,
    this.productName,
    this.pricePerKg,
    this.unit,
    this.farmerName,
  });

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  late double pricePerKg;
  late String unit;
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    pricePerKg = widget.pricePerKg ?? 40.0;
    unit = widget.unit ?? "Kg";
  }

  void calculateTotal() {
    double qty = double.tryParse(quantityController.text) ?? 0;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Product Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ListTile(
                      leading: const Icon(
                        Icons.grass,
                        color: Colors.green,
                      ),
                      title: Text(widget.productName ?? "Agricultural Produce"),
                      subtitle: Text("Price: ₹$pricePerKg / $unit"),
                    ),
                    const Divider(),
                    Text(
                      "Farmer: ${widget.farmerName ?? 'Verified Farmer'}",
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Price: ₹$pricePerKg / $unit",
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

                 
                  final qty = double.tryParse(quantityController.text) ?? 10.0;
                  final total = totalAmount > 0 ? totalAmount : (qty * pricePerKg);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        orderId: widget.productId,
                        totalAmount: total,
                        productName: widget.productName ?? "Agricultural Produce",
                        quantity: qty,
                        unit: unit,
                        deliveryAddress: addressController.text.trim(),
                      ),
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