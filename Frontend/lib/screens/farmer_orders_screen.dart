import 'package:flutter/material.dart';
import 'my_orders_screen.dart';

/// Incoming Orders for farmers, forwarded to unified live MyOrdersScreen in farmer view.
class FarmerOrdersScreen extends StatelessWidget {
  const FarmerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyOrdersScreen(isFarmerView: true);
  }
}