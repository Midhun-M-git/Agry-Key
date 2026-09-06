import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/language_selection_screen.dart';

void main() {
  runApp(const AgriKeyApp());
}

class AgriKeyApp extends StatelessWidget {
  const AgriKeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LanguageSelectionScreen(),
    );
  }
}