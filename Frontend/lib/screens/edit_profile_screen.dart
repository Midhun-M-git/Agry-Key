import 'package:flutter/material.dart';
import '../core/app_state.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {

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
      AppState.watchAll(ref);
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

                ref.read(userProvider.notifier).update(
                  userName: nameController.text,
                  userOccupation: occupationController.text,
                  farmName: farmController.text,
                  userCrop: cropController.text,
                );
                ref.read(locationProvider.notifier).update(
                  userLocation: locationController.text,
                );

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