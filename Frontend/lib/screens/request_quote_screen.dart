import 'package:flutter/material.dart';
import '../widgets/voice_text_field.dart';

class RequestQuoteScreen extends StatefulWidget {
  const RequestQuoteScreen({super.key});

  @override
  State<RequestQuoteScreen> createState() =>
      _RequestQuoteScreenState();
}

class _RequestQuoteScreenState
    extends State<RequestQuoteScreen> {

  final TextEditingController quantityController =
      TextEditingController();

  final TextEditingController offerPriceController =
      TextEditingController();

  final TextEditingController notesController =
      TextEditingController();

  @override
  void dispose() {
    quantityController.dispose();
    offerPriceController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void submitQuote() {

    if (quantityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter quantity",
          ),
        ),
      );
      return;
    }

    if (offerPriceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter your offer price",
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text(
            "Quote Sent",
          ),

          content: const Text(
            "Your quote request has been sent to the farmer.",
          ),

          actions: [

            TextButton(
              onPressed: () {

                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Request Quote",
        ),
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
                      "Product",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const ListTile(
                      leading: Icon(
                        Icons.grass,
                        color: Colors.green,
                      ),
                      title: Text(
                        "Premium Rice",
                      ),
                      subtitle: Text(
                        "Farmer: Ravi Kumar",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Required Quantity (Kg)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: quantityController,
              keyboardType:
                  TextInputType.number,

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
              "Your Offer Price (₹ / Kg)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller:
                  offerPriceController,

              keyboardType:
                  TextInputType.number,

              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.currency_rupee),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Additional Message",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            VoiceTextField(
              controller: notesController,
              hintText:
                  "Add message to farmer...",
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: submitQuote,

                icon: const Icon(
                  Icons.send,
                ),

                label: const Text(
                  "Send Quote Request",
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