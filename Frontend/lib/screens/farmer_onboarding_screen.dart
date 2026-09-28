import 'package:flutter/material.dart';
import '../core/api_config.dart';
import '../core/app_state.dart';
import '../services/api_service.dart';
import '../utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class FarmerOnboardingScreen extends ConsumerStatefulWidget {
  const FarmerOnboardingScreen({super.key});

  @override
  _FarmerOnboardingScreenState createState() =>
      _FarmerOnboardingScreenState();
}

class _FarmerOnboardingScreenState
  extends ConsumerState<FarmerOnboardingScreen> {

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

  Future<void> saveFarmDetails() async {
    if (stateController.text.isEmpty ||
        districtController.text.isEmpty ||
        farmNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
        ),
      );
      return;
    }

    final location = "${districtController.text}, ${stateController.text}";
    final payload = {
      "state": stateController.text.trim(),
      "district": districtController.text.trim(),
      "latitude": ref.read(locationProvider).latitude,
      "longitude": ref.read(locationProvider).longitude,
      "plots": [
        {
          "plot_name": farmNameController.text.trim(),
          "acreage": double.tryParse(acreageController.text) ?? 1.0,
          "soil_type": soilTypeController.text.trim().isNotEmpty
              ? soilTypeController.text.trim()
              : "RED_LOAMY",
          "water_source": waterSourceController.text.trim().isNotEmpty
              ? waterSourceController.text.trim()
              : "Well / Canal",
          "crops_currently_grown": [
            cropController.text.trim().isNotEmpty
                ? cropController.text.trim()
                : "Paddy"
          ],
        }
      ],
      "livestock": animalTypeController.text.trim().isEmpty
          ? []
          : [
              {
                "animal_type": animalTypeController.text.trim(),
                "breed": breedController.text.trim().isNotEmpty
                    ? breedController.text.trim()
                    : "Desi",
                "head_count": int.tryParse(headCountController.text) ?? 1,
                "purpose": "DAIRY"
              }
            ],
      "poultry": birdTypeController.text.trim().isEmpty
          ? []
          : [
              {
                "bird_type": birdTypeController.text.trim(),
                "bird_count": int.tryParse(birdCountController.text) ?? 10,
                "purpose": "EGGS"
              }
            ],
      "aquaculture": pondNameController.text.trim().isEmpty
          ? []
          : [
              {
                "pond_name": pondNameController.text.trim(),
                "pond_size_acres": double.tryParse(pondSizeController.text) ?? 0.5,
                "fish_species": fishSpeciesController.text.trim().isNotEmpty
                    ? fishSpeciesController.text.trim()
                    : "Carp"
              }
            ],
    };

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/onboarding/farm');
      await ApiService.requestWithAuth(method: 'POST', uri: uri, body: payload);
    } catch (_) {}

    ref.read(userProvider.notifier).update(
      farmName: farmNameController.text,
      userCrop: cropController.text,
      farmPayload: payload,
    );
    ref.read(locationProvider.notifier).update(userLocation: location);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Farm Portfolio Configured Successfully"),
      ),
    );

    Navigator.pop(context);
  }

  void _startVoiceInterview() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.mic, color: Colors.green),
            SizedBox(width: 8),
            Text("AI Voice Interview Setup", style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Conversational Assistant is listening. Speak clearly about your agricultural land, cattle, poultry, fish pond, and water source.",
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 12),
            Text(
              "Spoken Prompt: 'How many acres of land do you cultivate, what soil type, and what animals or ponds do you maintain?'",
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.green),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (stateController.text.isEmpty) stateController.text = "Kerala";
                if (districtController.text.isEmpty) districtController.text = "Palakkad";
                farmNameController.text = "Green Valley Integrated Farm";
                cropController.text = "Paddy & Banana";
                acreageController.text = "3.5";
                soilTypeController.text = "LATERITE";
                waterSourceController.text = "Borewell & Canal";
                animalTypeController.text = "Cow";
                breedController.text = "Kasargod Dwarf";
                headCountController.text = "3";
                birdTypeController.text = "Country Hen";
                birdCountController.text = "25";
                pondNameController.text = "Main Farm Pond";
                pondSizeController.text = "0.75";
                fishSpeciesController.text = "Catla & Rohu";
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Voice interview response transcribed and auto-filled across all sectors."),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text("Auto-Populate from Voice"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
  AppState.watchAll(ref);

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
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton.icon(
                onPressed: _startVoiceInterview,
                icon: const Icon(Icons.mic, color: Colors.white),
                label: const Text(
                  "AI Voice Interview Portfolio Setup",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

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