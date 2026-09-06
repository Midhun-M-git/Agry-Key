import 'package:flutter/material.dart';
import '../core/app_state.dart';

class BuyerOrdersScreen extends StatelessWidget {
  const BuyerOrdersScreen({super.key});

  String getText(
    String english,
    String malayalam,
    String hindi,
    String tamil,
  ) {
    switch (AppState.selectedLanguage) {
      case "Malayalam":
        return malayalam;
      case "Hindi":
        return hindi;
      case "Tamil":
        return tamil;
      default:
        return english;
    }
  }

  Widget orderCard({
    required String product,
    required String farmer,
    required String quantity,
    required String amount,
    required String status,
    required Color statusColor,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(
              children: [

                const Icon(
                  Icons.shopping_basket,
                  color: Colors.green,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    product,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text("Farmer : $farmer"),

            const SizedBox(height: 5),

            Text("Quantity : $quantity"),

            const SizedBox(height: 5),

            Text("Amount : $amount"),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),

              decoration: BoxDecoration(
                color:
                    statusColor.withOpacity(0.15),
                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},

                    icon: const Icon(
                      Icons.visibility,
                    ),

                    label: Text(
                      getText(
                        "View",
                        "കാണുക",
                        "देखें",
                        "பார்க்க",
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},

                    icon: const Icon(
                      Icons.support_agent,
                    ),

                    label: Text(
                      getText(
                        "Support",
                        "സഹായം",
                        "सहायता",
                        "உதவி",
                      ),
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

        title: Text(
          getText(
            "My Orders",
            "എന്റെ ഓർഡറുകൾ",
            "मेरे ऑर्डर",
            "என் ஆர்டர்கள்",
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView(
          children: [

            orderCard(
              product: "Rice",
              farmer: "Ramesh Kumar",
              quantity: "50 Kg",
              amount: "₹2100",
              status: "Delivered",
              statusColor: Colors.green,
            ),

            orderCard(
              product: "Banana",
              farmer: "Suresh Nair",
              quantity: "20 Dozen",
              amount: "₹1100",
              status: "In Transit",
              statusColor: Colors.orange,
            ),

            orderCard(
              product: "Tomato",
              farmer: "Anil Das",
              quantity: "100 Kg",
              amount: "₹3500",
              status: "Processing",
              statusColor: Colors.blue,
            ),

            orderCard(
              product: "Coconut",
              farmer: "Joseph Mathew",
              quantity: "200 Pieces",
              amount: "₹5000",
              status: "Pending",
              statusColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}