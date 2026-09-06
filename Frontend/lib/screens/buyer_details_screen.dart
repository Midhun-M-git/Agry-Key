import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(crop),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.agriculture,
                size: 100,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [

                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(farmer),
                      subtitle: const Text("Farmer"),
                    ),

                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(location),
                    ),

                    ListTile(
                      leading: const Icon(Icons.inventory),
                      title: Text(quantity),
                    ),

                    ListTile(
                      leading: const Icon(Icons.currency_rupee),
                      title: Text(price),
                    ),

                    const ListTile(
                      leading: Icon(Icons.star),
                      title: Text("Grade A Quality"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.call),
                label: const Text("Contact Farmer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart),
                label: const Text("Send Purchase Request"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}