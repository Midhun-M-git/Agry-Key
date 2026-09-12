import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_theme.dart';
import 'core/app_router.dart';

void main() {
  runApp(const ProviderScope(child: AgriKeyApp()));
}

class AgriKeyApp extends StatelessWidget {
  const AgriKeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.create(),
    );
  }
}
