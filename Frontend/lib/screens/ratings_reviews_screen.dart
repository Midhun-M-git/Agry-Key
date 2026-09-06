import 'package:flutter/material.dart';

class RatingsReviewsScreen extends StatelessWidget {
  const RatingsReviewsScreen({super.key});

  Widget reviewCard({
    required String name,
    required String review,
    required double rating,
    required bool verified,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                if (verified)
                  const Icon(
                    Icons.verified,
                    color: Colors.blue,
                  ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < rating
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(review),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ratings & Reviews",
        ),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView(
          children: [

            Card(
              color: Colors.green.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16),

                child: Column(
                  children: [

                    Text(
                      "Farmer Trust Score",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "4.8 ★",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.green,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    Text(
                      "125 Completed Orders",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            reviewCard(
              name: "Rahul Traders",
              review:
                  "Excellent quality rice and timely delivery.",
              rating: 5,
              verified: true,
            ),

            reviewCard(
              name: "Fresh Mart",
              review:
                  "Good communication and quality produce.",
              rating: 4,
              verified: true,
            ),

            reviewCard(
              name: "Metro Market",
              review:
                  "Satisfied with the overall service.",
              rating: 5,
              verified: false,
            ),
          ],
        ),
      ),
    );
  }
}