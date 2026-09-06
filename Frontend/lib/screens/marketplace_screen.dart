import 'package:flutter/material.dart';
import 'create_listing_screen.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  Widget productCard(
    String crop,
    String price,
    String seller,
  ) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: const Icon(
          Icons.store,
          color: Colors.green,
        ),
        title: Text(crop),
        subtitle: Text(
          "Seller: $seller",
        ),
        trailing: Text(
          price,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Marketplace"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search products",
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [

                  productCard(
                    "Rice",
                    "₹4200 / Quintal",
                    "Ravi Kumar",
                  ),

                  productCard(
                    "Banana",
                    "₹55 / Dozen",
                    "Anil",
                  ),

                  productCard(
                    "Tomato",
                    "₹35 / Kg",
                    "Suresh",
                  ),

                  productCard(
                    "Potato",
                    "₹28 / Kg",
                    "Manoj",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton:
          FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const CreateListingScreen(),
    ),
  );
},
        child: const Icon(Icons.add),
      ),
    );
  }
}