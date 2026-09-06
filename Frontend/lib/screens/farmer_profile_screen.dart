import 'package:flutter/material.dart';

class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key});

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

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Farmer Profile"),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 60,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Ravi Kumar",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: const [

                Icon(
                  Icons.verified,
                  color: Colors.green,
                ),

                SizedBox(width: 5),

                Text(
                  "Verified Farmer",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                statCard(
                  "32",
                  "Products",
                  Icons.inventory,
                ),

                statCard(
                  "4.8",
                  "Rating",
                  Icons.star,
                ),
              ],
            ),

            const SizedBox(height: 15),

            infoCard(
              Icons.phone,
              "Phone Number",
              "+91 9876543210",
            ),

            infoCard(
              Icons.location_on,
              "Location",
              "Palakkad, Kerala",
            ),

            infoCard(
              Icons.grass,
              "Main Crops",
              "Rice, Banana, Coconut",
            ),

            infoCard(
              Icons.agriculture,
              "Experience",
              "15 Years",
            ),

            infoCard(
              Icons.inventory_2,
              "Products Available",
              "32 Active Products",
            ),

            infoCard(
              Icons.star,
              "Farmer Rating",
              "4.8 / 5",
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},

                icon: const Icon(Icons.call),

                label: const Text(
                  "Call Farmer",
                ),

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

                icon: const Icon(Icons.chat),

                label: const Text(
                  "Chat Farmer",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}