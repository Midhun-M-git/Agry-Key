import 'package:flutter/material.dart';
import '../core/app_state.dart';

class BuyerProfileScreen extends StatelessWidget {
  const BuyerProfileScreen({super.key});

  Widget infoCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.green,
        ),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Widget statCard(
    String count,
    String title,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Icon(
                icon,
                color: Colors.green,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 20,
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

  @override
  Widget build(BuildContext context) {

    String userName =
        AppState.userName.isEmpty
            ? "Buyer"
            : AppState.userName;

    String location =
        AppState.userLocation.isEmpty
            ? "Location Not Set"
            : AppState.userLocation;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Buyer Profile"),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: Column(
                children: [

                  const CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Verified Buyer",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                statCard(
                  "12",
                  "Orders",
                  Icons.shopping_bag,
                ),

                statCard(
                  "8",
                  "Farmers",
                  Icons.agriculture,
                ),
              ],
            ),

            const SizedBox(height: 15),

            infoCard(
              Icons.person,
              "Name",
              userName,
            ),

            infoCard(
              Icons.location_on,
              "Location",
              location,
            ),

            infoCard(
              Icons.work,
              "Occupation",
              "Buyer",
            ),

            infoCard(
              Icons.business,
              "Business Type",
              "Agricultural Buyer",
            ),

            infoCard(
              Icons.shopping_cart,
              "Purchases",
              "Rice, Banana, Coconut",
            ),

            infoCard(
              Icons.star,
              "Buyer Rating",
              "4.8 / 5",
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Edit Profile Feature Coming Soon",
                      ),
                    ),
                  );
                },

                icon: const Icon(Icons.edit),

                label: const Text(
                  "Edit Profile",
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                  foregroundColor:
                      Colors.white,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Settings Coming Soon",
                      ),
                    ),
                  );
                },

                icon: const Icon(Icons.settings),

                label: const Text(
                  "Settings",
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.white,
                  foregroundColor:
                      Colors.green,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}