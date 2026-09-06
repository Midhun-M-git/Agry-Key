import 'package:flutter/material.dart';

class PostDetailsScreen extends StatelessWidget {
  final String userName;
  final String question;

  const PostDetailsScreen({
    super.key,
    required this.userName,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discussion"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              userName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  question,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Replies",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text("Farmer Reply"),
                subtitle: Text(
                  "Try applying micronutrient spray.",
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.smart_toy),
                ),
                title: Text("AGRI KEY AI"),
                subtitle: Text(
                  "Yellow leaves may indicate nutrient deficiency.",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}