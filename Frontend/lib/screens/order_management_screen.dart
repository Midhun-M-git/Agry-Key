import 'package:flutter/material.dart';
import 'my_orders_screen.dart';

/// Forwarded to unified live MyOrdersScreen in farmer management mode.
class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyOrdersScreen(isFarmerView: true);
  }
}