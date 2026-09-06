import 'package:flutter/material.dart';
import '../widgets/voice_text_field.dart';

class FarmerUploadScreen extends StatefulWidget {
  const FarmerUploadScreen({super.key});

  @override
  State<FarmerUploadScreen> createState() =>
      _FarmerUploadScreenState();
}

class _FarmerUploadScreenState
    extends State<FarmerUploadScreen> {

  final TextEditingController cropController =
      TextEditingController();

  final TextEditingController quantityController =
      TextEditingController();

  final TextEditingController priceController =
      TextEditingController();

  final TextEditingController locationController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  String selectedCategory = "Rice";

  final List<String> categories = [
    "Rice",
    "Vegetables",
    "Fruits",
    "Spices",
    "Coconut",
  ];

  @override
  void dispose() {
    cropController.dispose();
    quantityController.dispose();
    priceController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        title: const Text("Add Crop"),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Row(
                    children: [

                      CircleAvatar(
                        backgroundColor:
                            Colors.white,
                        child: Icon(
                          Icons.agriculture,
                          color: Colors.green,
                        ),
                      ),

                      SizedBox(width: 10),

                      Text(
                        "Crop Upload",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Upload your crop details using text or voice.",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: CircleAvatar(
                radius: 55,
                backgroundColor:
                    Colors.green.shade100,
                child: const Icon(
                  Icons.image,
                  size: 55,
                  color: Colors.green,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload),
                label:
                    const Text("Upload Image"),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Crop Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            VoiceTextField(
              controller: cropController,
              hintText:
                  "Speak or type crop name",
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField(
              value: selectedCategory,

              decoration:
                  const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),

              items: categories.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedCategory =
                      value.toString();
                });
              },
            ),

            const SizedBox(height: 15),

            const Text(
              "Quantity",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            VoiceTextField(
              controller: quantityController,
              hintText:
                  "Speak or enter quantity",
            ),

            const SizedBox(height: 15),

            TextField(
              controller: priceController,
              keyboardType:
                  TextInputType.number,

              decoration:
                  const InputDecoration(
                labelText: "Price (₹)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Location",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            VoiceTextField(
              controller:
                  locationController,
              hintText:
                  "Speak or enter location",
            ),

            const SizedBox(height: 15),

            const Text(
              "Description",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            VoiceTextField(
              controller:
                  descriptionController,
              hintText:
                  "Describe your crop",
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: () {

                  ScaffoldMessenger.of(
                          context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Crop Uploaded Successfully",
                      ),
                    ),
                  );
                },

                icon: const Icon(Icons.check),

                label: const Text(
                  "Upload Crop",
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                  foregroundColor:
                      Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}