import 'package:flutter/material.dart';
import 'schemes_screen.dart';

/// Legacy redirect to the live API-connected SchemesScreen
class GovernmentSchemesScreen extends StatelessWidget {
  const GovernmentSchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SchemesScreen();
  }
}