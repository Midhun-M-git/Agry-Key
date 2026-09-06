import 'package:flutter/material.dart';
import '../core/app_state.dart';

class FarmerOnboardingScreen extends StatefulWidget {
  const FarmerOnboardingScreen({super.key});

  @override
  State<FarmerOnboardingScreen> createState() =>
      _FarmerOnboardingScreenState();
}

class _FarmerOnboardingScreenState
    extends State<FarmerOnboardingScreen> {

  final stateController =
      TextEditingController();

  final districtController =
      TextEditingController();

  final farmNameController =
      TextEditingController();

  final cropController =
      TextEditingController();

  final acreageController =
      TextEditingController();
      final soilTypeController = TextEditingController();
final waterSourceController = TextEditingController();

final animalTypeController = TextEditingController();
final breedController = TextEditingController();
final headCountController = TextEditingController();

final birdTypeController = TextEditingController();
final birdCountController = TextEditingController();

final pondNameController = TextEditingController();
final pondSizeController = TextEditingController();
final fishSpeciesController = TextEditingController();

  @override
  void dispose() {
    stateController.dispose();
    districtController.dispose();
    farmNameController.dispose();
    cropController.dispose();
    acreageController.dispose();
    soilTypeController.dispose();
waterSourceController.dispose();

animalTypeController.dispose();
breedController.dispose();
headCountController.dispose();

birdTypeController.dispose();
birdCountController.dispose();

pondNameController.dispose();
pondSizeController.dispose();
fishSpeciesController.dispose();
    super.dispose();
  }

  void saveFarmDetails() {

    if (stateController.text.isEmpty ||
        districtController.text.isEmpty ||
        farmNameController.text.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all required fields",
          ),
        ),
      );

      return;
    }

    AppState.farmName =
        farmNameController.text;

    AppState.userCrop =
        cropController.text;

    AppState.userLocation =
        "${districtController.text}, ${stateController.text}";
        AppState.farmPayload = {
  "state": stateController.text.trim(),
  "district": districtController.text.trim(),
  "latitude": AppState.latitude,
  "longitude": AppState.longitude,

  "plots": [
    {
      "plot_name": farmNameController.text.trim(),
      "acreage":
          double.tryParse(
            acreageController.text,
          ) ??
          0,

      "soil_type":
          soilTypeController.text.trim(),

      "water_source":
          waterSourceController.text.trim(),

      "crops_currently_grown": [
        cropController.text.trim(),
      ]
    }
  ],

  "livestock": animalTypeController
          .text
          .trim()
          .isEmpty
      ? []
      : [
          {
            "animal_type":
                animalTypeController.text.trim(),
            "breed":
                breedController.text.trim(),
            "head_count":
                int.tryParse(
                      headCountController.text,
                    ) ??
                    0,
            "purpose": "DAIRY"
          }
        ],

  "poultry": birdTypeController
          .text
          .trim()
          .isEmpty
      ? []
      : [
          {
            "bird_type":
                birdTypeController.text.trim(),
            "bird_count":
                int.tryParse(
                      birdCountController.text,
                    ) ??
                    0,
            "purpose": "EGGS"
          }
        ],

  "aquaculture": pondNameController
          .text
          .trim()
          .isEmpty
      ? []
      : [
          {
            "pond_name":
                pondNameController.text.trim(),
            "pond_size_acres":
                double.tryParse(
                      pondSizeController.text,
                    ) ??
                    0,
            "fish_species":
                fishSpeciesController.text.trim(),
          }
        ],
};

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Farm Details Saved Successfully",
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Farmer Onboarding",
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: stateController,
              decoration:
                  const InputDecoration(
                labelText: "State",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  districtController,
              decoration:
                  const InputDecoration(
                labelText: "District",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  farmNameController,
              decoration:
                  const InputDecoration(
                labelText: "Farm Name",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: cropController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Main Crop",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  acreageController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText:
                    "Land Area (Acres)",
                border:
                    OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

TextField(
  controller: soilTypeController,
  decoration: const InputDecoration(
    labelText: "Soil Type",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 15),

TextField(
  controller: waterSourceController,
  decoration: const InputDecoration(
    labelText: "Water Source",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 25),

const Text(
  "Livestock (Optional)",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

TextField(
  controller: animalTypeController,
  decoration: const InputDecoration(
    labelText: "Animal Type",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 15),

TextField(
  controller: breedController,
  decoration: const InputDecoration(
    labelText: "Breed",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 15),

TextField(
  controller: headCountController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
    labelText: "Head Count",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 25),

const Text(
  "Poultry (Optional)",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

TextField(
  controller: birdTypeController,
  decoration: const InputDecoration(
    labelText: "Bird Type",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 15),

TextField(
  controller: birdCountController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
    labelText: "Bird Count",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 25),

const Text(
  "Aquaculture (Optional)",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

TextField(
  controller: pondNameController,
  decoration: const InputDecoration(
    labelText: "Pond Name",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 15),

TextField(
  controller: pondSizeController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
    labelText: "Pond Size (Acres)",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 15),

TextField(
  controller: fishSpeciesController,
  decoration: const InputDecoration(
    labelText: "Fish Species",
    border: OutlineInputBorder(),
  ),
),

const SizedBox(height: 30),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    saveFarmDetails,
                child: const Text(
                  "Save & Continue",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}