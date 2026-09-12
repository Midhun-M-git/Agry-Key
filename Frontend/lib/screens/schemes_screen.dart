import 'package:flutter/material.dart';
import '../utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';

class SchemesScreen extends ConsumerWidget {
  const SchemesScreen({super.key});
@override
  Widget build(BuildContext context, WidgetRef ref) {
    AppState.watchAll(ref);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          L10n.get(
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