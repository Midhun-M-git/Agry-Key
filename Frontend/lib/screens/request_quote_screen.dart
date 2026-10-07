import 'package:flutter/material.dart';
import '../widgets/voice_text_field.dart';

class RequestQuoteScreen extends StatefulWidget {
  final String? productName;
  final String? farmerName;
  final double? currentPrice;
  final String? unit;

  const RequestQuoteScreen({
    super.key,
    this.productName,
    this.farmerName,
    this.currentPrice,
    this.unit,
  });

  @override
  State<RequestQuoteScreen> createState() => _RequestQuoteScreenState();
}

class _RequestQuoteScreenState extends State<RequestQuoteScreen> {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController offerPriceController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  late String _productName;
  late String _farmerName;
  late double _currentPrice;
  late String _unit;

  @override
  void initState() {
    super.initState();
    _productName = widget.productName ?? "Agricultural Produce";
    _farmerName = widget.farmerName ?? "Verified Farmer";
    _currentPrice = widget.currentPrice ?? 42.0;
    _unit = widget.unit ?? "kg";
    offerPriceController.text = (_currentPrice * 0.95).round().toString();
  }

  @override
  void dispose() {
    quantityController.dispose();
    offerPriceController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void submitQuote() {
    final qty = double.tryParse(quantityController.text.trim());
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid quantity")),
      );
      return;
    }

    final offer = double.tryParse(offerPriceController.text.trim());
    if (offer == null || offer <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your offer price")),
      );
      return;
    }

    final totalValue = (qty * offer).toStringAsFixed(0);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text("Quote Dispatched"),
            ],
          ),
          content: Text(
            "Your bulk purchase offer for $qty $_unit of $_productName at ₹$offer/$_unit (Total: ₹$totalValue) has been sent to $_farmerName.\n\nThe farmer will receive an immediate SMS/app alert to accept or counter-offer.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Done", style: TextStyle(color: Colors.white)),
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
        foregroundColor: Colors.white,
        title: const Text("Request Bulk Quote"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Target Produce & Producer",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(Icons.grass, color: Colors.green),
                      ),
                      title: Text(
                        _productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Producer: $_farmerName • Listed: ₹$_currentPrice/$_unit"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Required Quantity",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "e.g. 500",
                suffixText: _unit,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Your Target Offer Price (per unit)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: offerPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: "₹ ",
                suffixText: "/ $_unit",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Logistics / Quality Terms (Optional)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            VoiceTextField(
              controller: notesController,
              hintText: "e.g. Required by Monday, farmgate inspection requested...",
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: submitQuote,
                icon: const Icon(Icons.send),
                label: const Text(
                  "Submit Quote to Farmer",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}