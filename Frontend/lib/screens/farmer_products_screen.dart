import 'package:flutter/material.dart';
import 'add_product_screen.dart';

class FarmerProductsScreen extends StatefulWidget {
  const FarmerProductsScreen({super.key});

  @override
  State<FarmerProductsScreen> createState() =>
      _FarmerProductsScreenState();
}

class _FarmerProductsScreenState
    extends State<FarmerProductsScreen> {

  List<Map<String, dynamic>> products = [
    {
      "name": "Rice",
      "price": "₹4200 / Quintal",
      "quantity": "50 Quintal",
    },
    {
      "name": "Banana",
      "price": "₹35 / Kg",
      "quantity": "300 Kg",
    },
    {
      "name": "Coconut",
      "price": "₹40 / Piece",
      "quantity": "500 Pieces",
    },
  ];

  void deleteProduct(int index) {
    setState(() {
      products.removeAt(index);
    });
  }

  Widget productCard(
    BuildContext context,
    int index,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              products[index]["name"],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              products[index]["price"],
            ),

            const SizedBox(height: 5),

            Text(
              "Available: ${products[index]["quantity"]}",
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Edit Product API will be connected later",
                          ),
                        ),
                      );
                    },

                    icon: const Icon(Icons.edit),

                    label: const Text("Edit"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      deleteProduct(index);
                    },

                    icon: const Icon(Icons.delete),

                    label: const Text("Delete"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red,
                      foregroundColor:
                          Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5FAF5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "My Products",
        ),
      ),

      floatingActionButton:
          FloatingActionButton(
        backgroundColor: Colors.green,

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddProductScreen(),
            ),
          );
        },

        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius:
                    BorderRadius.circular(12),
              ),

              child: Column(
                children: [

                  const Icon(
                    Icons.inventory,
                    color: Colors.white,
                    size: 50,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Total Products: ${products.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: products.length,

                itemBuilder:
                    (context, index) {
                  return productCard(
                    context,
                    index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}