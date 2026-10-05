import 'package:flutter/material.dart';
import 'create_listing_screen.dart';

/// Legacy redirect to the unified CreateListingScreen
class FarmerUploadScreen extends StatelessWidget {
  const FarmerUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CreateListingScreen();
  }
}