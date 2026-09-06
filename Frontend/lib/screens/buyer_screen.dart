import 'package:flutter/material.dart';
import 'buyer_profile_screen.dart';

class BuyerScreen extends StatelessWidget {
  const BuyerScreen({super.key});

  Widget categoryChip(String text) {
    return Chip(
      label: Text(text),
      backgroundColor: Colors.green.shade100,
    );
  }

  Widget statCard(
    IconData icon,
    String count,
    String title,
  ) {
    return Expanded(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(
                icon,
                color: Colors.green,
                size: 28,
              ),
              const SizedBox(height: 5),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget productCard({
    required String crop,
    required String seller,
    required String quantity,
    required String location,
    required String price,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [

            Row(
              children: [

                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.agriculture,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        crop,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      Text(
                        "Farmer: $seller",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.inventory,
                  color: Colors.green,
                  size: 18,
                ),
                const SizedBox(width: 5),
                Text(
                  "Available: $quantity",
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 18,
                ),
                const SizedBox(width: 5),
                Text(location),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.call,
                    ),
                    label: const Text(
                      "Contact",
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

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.favorite_border,
                    ),
                    label: const Text(
                      "Wishlist",
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
          Colors.grey.shade100,

     appBar: AppBar(
  title: Text(
    "Buyer Marketplace",
  ),
  backgroundColor: Colors.green,

  actions: [

    IconButton(
      icon: const Icon(Icons.person),

      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const BuyerProfileScreen(),
          ),
        );
      },
    ),
  ],
),

      floatingActionButton:
          FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {},
        child: const Icon(
          Icons.chat,
          color: Colors.white,
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Container(
              padding:
                  const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius:
                    BorderRadius.circular(
                        15),
              ),

              child: const Row(
                children: [

                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        Colors.white,
                    child: Icon(
                      Icons.person,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),

                  SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [

                        Text(
                          "Buyer Dashboard",
                          style: TextStyle(
                            color:
                                Colors.white,
                            fontSize: 18,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "Connect directly with farmers",
                          style: TextStyle(
                            color:
                                Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [

                statCard(
                  Icons.shopping_bag,
                  "12",
                  "Orders",
                ),

                statCard(
                  Icons.favorite,
                  "8",
                  "Wishlist",
                ),
              ],
            ),

            const SizedBox(height: 15),

            TextField(
              decoration: InputDecoration(
                hintText:
                    "Search crops...",
                prefixIcon:
                    const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal,

              child: Row(
                children: [

                  categoryChip("Rice"),

                  const SizedBox(width: 8),

                  categoryChip(
                      "Vegetables"),

                  const SizedBox(width: 8),

                  categoryChip("Fruits"),

                  const SizedBox(width: 8),

                  categoryChip("Spices"),

                  const SizedBox(width: 8),

                  categoryChip("Coconut"),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: ListView(
                children: [

                  productCard(
                    crop: "Rice",
                    seller: "Ravi Kumar",
                    quantity:
                        "50 Quintal",
                    location:
                        "Palakkad",
                    price: "₹4200",
                  ),

                  productCard(
                    crop: "Banana",
                    seller: "Anil",
                    quantity:
                        "200 Dozen",
                    location:
                        "Thrissur",
                    price: "₹55",
                  ),

                  productCard(
                    crop: "Tomato",
                    seller: "Suresh",
                    quantity:
                        "500 Kg",
                    location: "Kochi",
                    price: "₹35",
                  ),

                  productCard(
                    crop: "Potato",
                    seller: "Manoj",
                    quantity:
                        "1000 Kg",
                    location:
                        "Wayanad",
                    price: "₹28",
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