import 'package:flutter/material.dart';
import '../core/api_config.dart';
import '../core/app_state.dart';
import '../services/api_service.dart';
import '../utils/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedSector = "CROPS";
  String selectedGrade = "A";
  String selectedUnit = "kg";
  bool isSubmitting = false;
  String? errorMessage;

  final List<String> sectors = ["CROPS", "DAIRY", "AQUACULTURE", "POULTRY", "LIVESTOCK"];
  final List<String> grades = ["A", "B", "C"];
  final List<String> units = ["kg", "Quintal", "Litre", "Dozen", "Box", "Tonne"];

  @override
  void initState() {
    super.initState();
    districtController.text = ref.read(locationProvider).district.isNotEmpty
        ? ref.read(locationProvider).district
        : "Palakkad";
  }

  @override
  void dispose() {
    nameController.dispose();
    typeController.dispose();
    quantityController.dispose();
    priceController.dispose();
    districtController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitListing() async {
    final name = nameController.text.trim();
    final type = typeController.text.trim().isNotEmpty ? typeController.text.trim() : name;
    final qty = double.tryParse(quantityController.text.trim());
    final price = double.tryParse(priceController.text.trim());
    final district = districtController.text.trim();

    if (name.isEmpty || qty == null || price == null || district.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields correctly.")),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });

    final payload = {
      "name": name,
      "crop_type": type,
      "sector": selectedSector,
      "quality_grade": selectedGrade,
      "district": district,
      "quantity": qty,
      "unit": selectedUnit,
      "price_per_unit": price,
      "description": descriptionController.text.trim().isNotEmpty
          ? descriptionController.text.trim()
          : null,
      "is_active": true,
    };

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/marketplace/listings');
      final res = await ApiService.requestWithAuth(
        method: 'POST',
        uri: uri,
        body: payload,
      );

      if (!mounted) return;
      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Produce listing published successfully across multi-sector marketplace."),
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          isSubmitting = false;
          errorMessage = "Submission failed: ${res.body}";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isSubmitting = false;
        errorMessage = "Error publishing listing: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        title: Text(
          L10n.get(
            "Create Produce Listing",
            "ഉൽപ്പന്ന ലിസ്റ്റിംഗ് സൃഷ്ടിക്കുക",
            "उत्पाद लिस्टिंग बनाएं",
            "உற்பத்தி பட்டியலை உருவாக்கவும்",
          ),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Direct Producer Listing",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  "List crops, milk, fish, eggs, or meat directly to verified buyers with quality grading and auto-expiry.",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const Divider(height: 24),

                // Sector Selector
                const Text("Agricultural Sector *", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedSector,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: sectors.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedSector = val!;
                      if (val == "DAIRY") selectedUnit = "Litre";
                      if (val == "POULTRY") selectedUnit = "Dozen";
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Produce Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Produce / Commodity Name *",
                    hintText: "e.g. Organic Nendran Banana, Rohu Fish, Fresh Cow Milk",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.grass),
                  ),
                ),
                const SizedBox(height: 14),

                // Quality Grade & Unit
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedGrade,
                        decoration: const InputDecoration(
                          labelText: "Quality Grade",
                          border: OutlineInputBorder(),
                        ),
                        items: grades
                            .map((g) => DropdownMenuItem(value: g, child: Text("Grade $g")))
                            .toList(),
                        onChanged: (val) => setState(() => selectedGrade = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedUnit,
                        decoration: const InputDecoration(
                          labelText: "Unit of Measurement",
                          border: OutlineInputBorder(),
                        ),
                        items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                        onChanged: (val) => setState(() => selectedUnit = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Quantity & Price
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Quantity Available *",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.scale),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Price Per Unit (INR) *",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // District
                TextField(
                  controller: districtController,
                  decoration: const InputDecoration(
                    labelText: "District Location *",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 14),

                // Description
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Harvest Details & Description (Optional)",
                    hintText: "State organic certification, harvest date, cold chain storage availability...",
                    border: OutlineInputBorder(),
                  ),
                ),

                if (errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isSubmitting ? null : _submitListing,
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: const Text(
                      "Publish Marketplace Listing",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}