import 'package:flutter/material.dart';
import 'chat_farmer_screen.dart';
import 'place_order_screen.dart';

class BuyerDetailsScreen extends StatelessWidget {
  final String crop;
  final String farmer;
  final String quantity;
  final String location;
  final String price;

  const BuyerDetailsScreen({
    super.key,
    required this.crop,
    required this.farmer,
    required this.quantity,
    required this.location,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final double parsedPrice = double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 45.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(crop),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade100, Colors.green.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Icon(Icons.agriculture, size: 80, color: Colors.green),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.green),
                      title: Text(farmer, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("Verified Producer"),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: Text(location),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.inventory, color: Colors.teal),
                      title: Text("Lot Size: $quantity"),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.currency_rupee, color: Colors.green),
                      title: Text("Price: $price"),
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.verified, color: Colors.amber),
                      title: Text("Grade A Certified"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaceOrderScreen(
                        productName: crop,
                        pricePerKg: parsedPrice,
                        unit: "kg",
                        farmerName: farmer,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text("Send Purchase Request / Order", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatFarmerScreen(
                        farmerName: farmer,
                        productName: crop,
                        farmerLocation: location,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text("Chat with Producer", style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade800,
                  side: BorderSide(color: Colors.green.shade700),
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