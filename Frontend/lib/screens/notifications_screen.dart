import 'package:flutter/material.dart';
import 'alerts_screen.dart';

/// Legacy redirect to the live AlertsScreen
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertsScreen();
  }
}