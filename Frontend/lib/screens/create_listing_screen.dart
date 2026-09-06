import 'package:flutter/material.dart';

class CreateListingScreen extends StatelessWidget {
  const CreateListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Listing"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const TextField(
              decoration: InputDecoration(
                labelText: "Crop Name",
              ),
            ),

            const TextField(
              decoration: InputDecoration(
                labelText: "Price",
              ),
            ),

            const TextField(
              decoration: InputDecoration(
                labelText: "Quantity",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Post Listing"),
            ),
          ],
        ),
      ),
    );
  }
}