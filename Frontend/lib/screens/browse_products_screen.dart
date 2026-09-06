import 'package:flutter/material.dart';

import '../models/product.dart';
import '../data/sample_products.dart';
import 'product_details_screen.dart';

class BrowseProductsScreen extends StatefulWidget {
  const BrowseProductsScreen({super.key});

  @override
  State<BrowseProductsScreen> createState() =>
      _BrowseProductsScreenState();
}

class _BrowseProductsScreenState
    extends State<BrowseProductsScreen> {

  List<Product> products = sampleProducts;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Browse Products",
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(12),

        itemCount: products.length,

        itemBuilder: (context, index) {

          Product product = products[index];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(
              bottom: 12,
            ),

            child: ListTile(

              leading: CircleAvatar(
                radius: 28,
                backgroundColor:
                    Colors.green.shade100,

                child: const Icon(
                  Icons.agriculture,
                  color: Colors.green,
                ),
              ),

              title: Text(
                product.name,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              subtitle: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    "Farmer: ${product.farmerName}",
                  ),

                  Text(
                    "Location: ${product.location}",
                  ),

                  Text(
                    product.quantity,
                  ),
                ],
              ),

              trailing: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Text(
                    "₹${product.price}",
                    style:
                        const TextStyle(
                      color: Colors.green,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),

              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ProductDetailsScreen(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}