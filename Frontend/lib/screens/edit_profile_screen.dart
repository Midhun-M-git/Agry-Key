import 'package:flutter/material.dart';
import '../core/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  late TextEditingController nameController;
  late TextEditingController locationController;
  late TextEditingController occupationController;
  late TextEditingController farmController;
  late TextEditingController cropController;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: AppState.userName);

    locationController =
        TextEditingController(text: AppState.userLocation);

    occupationController =
        TextEditingController(text: AppState.userOccupation);

    farmController =
        TextEditingController(text: AppState.farmName);

    cropController =
        TextEditingController(text: AppState.userCrop);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
              ),
            ),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Location",
              ),
            ),

            TextField(
              controller: occupationController,
              decoration: const InputDecoration(
                labelText: "Occupation",
              ),
            ),

            TextField(
              controller: farmController,
              decoration: const InputDecoration(
                labelText: "Farm Name",
              ),
            ),

            TextField(
              controller: cropController,
              decoration: const InputDecoration(
                labelText: "Crop",
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: () {

                AppState.userName =
                    nameController.text;

                AppState.userLocation =
                    locationController.text;

                AppState.userOccupation =
                    occupationController.text;

                AppState.farmName =
                    farmController.text;

                AppState.userCrop =
                    cropController.text;

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}