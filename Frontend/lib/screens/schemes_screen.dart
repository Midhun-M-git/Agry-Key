import 'package:flutter/material.dart';
import '../core/app_state.dart';

class SchemesScreen extends StatelessWidget {
  const SchemesScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          getText(
            "Government Schemes",
            "സർക്കാർ പദ്ധതികൾ",
            "सरकारी योजनाएँ",
            "அரசுத் திட்டங்கள்",
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          schemeCard(
            "PM-KISAN",
            "₹6000 yearly support for farmers",
            Icons.currency_rupee,
          ),

          schemeCard(
            "Crop Insurance",
            "Protection against crop loss",
            Icons.shield,
          ),

          schemeCard(
            "Fertilizer Subsidy",
            "Reduced fertilizer cost",
            Icons.eco,
          ),

          schemeCard(
            "Farm Machinery Subsidy",
            "Support for equipment purchase",
            Icons.agriculture,
          ),

          schemeCard(
            "KCC Loan",
            "Low-interest agricultural loans",
            Icons.account_balance,
          ),
        ],
      ),
    );
  }

  static Widget schemeCard(
    String title,
    String description,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.green,
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(
          Icons.arrow_forward_ios,
        ),
      ),
    );
  }
}