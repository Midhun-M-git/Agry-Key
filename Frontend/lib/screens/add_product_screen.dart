import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState
    extends State<AddProductScreen> {

  final TextEditingController cropController =
      TextEditingController();

  final TextEditingController priceController =
      TextEditingController();

  final TextEditingController quantityController =
      TextEditingController();

  final TextEditingController locationController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  @override
  void dispose() {
    cropController.dispose();
    priceController.dispose();
    quantityController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Widget buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: label == "Description" ? 4 : 1,
        keyboardType:
            label.contains("Price") ||
                    label.contains("Quantity")
                ? TextInputType.number
                : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void addProduct() {

    if (cropController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        quantityController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Please fill all fields"),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text("Product Added Successfully"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),

      appBar: AppBar(
        title: const Text("Add Product"),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Container(
              height: 180,
              width: double.infinity,

              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: const [

                  Icon(
                    Icons.image,
                    size: 60,
                    color: Colors.green,
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Upload Product Image",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            buildTextField(
              cropController,
              "Crop Name",
              Icons.grass,
            ),

            buildTextField(
              priceController,
              "Price (₹)",
              Icons.currency_rupee,
            ),

            buildTextField(
              quantityController,
              "Available Quantity",
              Icons.inventory,
            ),

            buildTextField(
              locationController,
              "Location",
              Icons.location_on,
            ),

            buildTextField(
              descriptionController,
              "Description",
              Icons.description,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: addProduct,

                icon: const Icon(
                  Icons.add_circle,
                ),

                label: const Text(
                  "Add Product",
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