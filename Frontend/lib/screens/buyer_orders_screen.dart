import 'package:flutter/material.dart';
import 'my_orders_screen.dart';

/// Buyer Orders Screen forwarded to unified live MyOrdersScreen.
class BuyerOrdersScreen extends StatelessWidget {
  const BuyerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyOrdersScreen(isFarmerView: false);
  }
}