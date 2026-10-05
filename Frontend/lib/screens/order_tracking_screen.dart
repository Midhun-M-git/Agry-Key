import 'package:flutter/material.dart';
import 'track_order_screen.dart';

/// Legacy redirect to the live TrackOrderScreen
class OrderTrackingScreen extends StatelessWidget {
  final int? orderId;
  const OrderTrackingScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    return TrackOrderScreen(orderId: orderId);
  }
}