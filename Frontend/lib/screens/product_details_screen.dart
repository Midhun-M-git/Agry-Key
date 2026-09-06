import 'package:flutter/material.dart';

import 'place_order_screen.dart';
import 'chat_farmer_screen.dart';
import 'request_quote_screen.dart';
import 'farmer_profile_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        title: const Text("Product Details"),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              height: 230,
              width: double.infinity,
              color: Colors.green.shade100,
              child: const Icon(
                Icons.agriculture,
                size: 100,
                color: Colors.green,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    "Premium Rice",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "₹4200 / Quintal",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Card(
  child: Column(
    children: [

      ListTile(
        leading: const Icon(Icons.person),
        title: const Text("Ravi Kumar"),
        subtitle: const Text("Farmer"),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const FarmerProfileScreen(),
            ),
          );
        },
      ),

      const Divider(height: 1),

      const ListTile(
        leading: Icon(
          Icons.star,
          color: Colors.orange,
        ),
        title: Text("Farmer Rating"),
        subtitle: Text("4.8 / 5"),
      ),
    ],
  ),
),

                  const SizedBox(height: 10),

                  Card(
                    child: Column(
                      children: const [

                        ListTile(
                          leading:
                              Icon(Icons.location_on),
                          title:
                              Text("Palakkad"),
                        ),

                        Divider(height: 1),

                        ListTile(
                          leading:
                              Icon(Icons.inventory),
                          title:
                              Text(
                                  "Available Quantity"),
                          subtitle:
                              Text("50 Quintal"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "High quality rice harvested recently. Directly available from farmer without middlemen.",
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Farmer contact feature will be connected soon.",
                            ),
                          ),
                        );
                      },
                      icon:
                          const Icon(Icons.call),
                      label:
                          const Text("Call Farmer"),
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
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ChatFarmerScreen(),
                          ),
                        );
                      },
                      icon:
                          const Icon(Icons.chat),
                      label:
                          const Text("Chat Farmer"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const RequestQuoteScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.request_quote,
                      ),
                      label:
                          const Text("Request Quote"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const PlaceOrderScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.shopping_cart,
                      ),
                      label:
                          const Text("Place Order"),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange,
                        foregroundColor:
                            Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}