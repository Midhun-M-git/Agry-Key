import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../utils/localization.dart';
import 'chat_farmer_screen.dart';
import 'place_order_screen.dart';

class CropDetailsScreen extends ConsumerWidget {
  final Map<String, dynamic>? cropData;

  const CropDetailsScreen({super.key, this.cropData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppState.watchAll(ref);

    final item = cropData ?? {};

    final String name = item['name'] as String? ??
        item['crop_type'] as String? ??
        'Highland Matta Rice';

    final double price = (item['price_per_unit'] as num?)?.toDouble() ??
        (item['price'] as num?)?.toDouble() ??
        42.0;

    final String unit = item['unit'] as String? ?? 'kg';

    final double quantity = (item['quantity'] as num?)?.toDouble() ??
        (item['available_quantity_kg'] as num?)?.toDouble() ??
        50.0;

    final String farmer = item['farmer_name'] as String? ??
        item['farmer'] as String? ??
        'Suresh Menon';

    final String farmerPhone = item['farmer_phone'] as String? ??
        item['phone'] as String? ??
        '+91 94471 23456';

    final String location = item['district'] as String? ??
        item['location'] as String? ??
        'Palakkad, Kerala';

    final String rating = item['rating']?.toString() ?? '4.9 / 5 (Inspected)';
    final int lowAiPrice = (price * 0.96).round();
    final int highAiPrice = (price * 1.04).round();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: Text(
          L10n.get(
            "Crop Details",
            "വിള വിവരങ്ങൾ",
            "फसल विवरण",
            "பயிர் விவரங்கள்",
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade200, Colors.green.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: Icon(Icons.agriculture, size: 90, color: Colors.green),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "₹${price.toStringAsFixed(0)} / $unit",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.inventory, color: Colors.green),
                    title: Text(
                      L10n.get(
                        "Available Quantity",
                        "ലഭ്യമായ അളവ്",
                        "उपलब्ध मात्रा",
                        "கிடைக்கும் அளவு",
                      ),
                    ),
                    subtitle: Text("${quantity.toStringAsFixed(0)} $unit"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.green),
                    title: Text(
                      L10n.get(
                        "Farmer",
                        "കർഷകൻ",
                        "किसान",
                        "விவசாயி",
                      ),
                    ),
                    subtitle: Text(farmer),
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.red),
                    title: Text(
                      L10n.get(
                        "Location",
                        "സ്ഥലം",
                        "स्थान",
                        "இடம்",
                      ),
                    ),
                    subtitle: Text(location),
                  ),
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.orange),
                    title: Text(
                      L10n.get(
                        "Rating",
                        "റേറ്റിംഗ്",
                        "रेटिंग",
                        "மதிப்பீடு",
                      ),
                    ),
                    subtitle: Text(rating),
                  ),
                  const Divider(),
                  Text(
                    L10n.get(
                      "Quality Information",
                      "ഗുണനിലവാര വിവരം",
                      "गुणवत्ता जानकारी",
                      "தரத் தகவல்",
                    ),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const ListTile(
                    leading: Icon(Icons.eco, color: Colors.green),
                    title: Text("Organic Certified & Residue-Free"),
                  ),
                  const ListTile(
                    leading: Icon(Icons.verified, color: Colors.teal),
                    title: Text("Krishi Bhavan Grade A Standard"),
                  ),
                  const SizedBox(height: 15),
                  Card(
                    color: Colors.green.shade50,
                    child: ListTile(
                      leading: const Icon(Icons.smart_toy, color: Colors.green),
                      title: const Text("AI Suggested Market Range"),
                      subtitle: Text("₹$lowAiPrice - ₹$highAiPrice / $unit (Zero middleman pricing)"),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlaceOrderScreen(
                              productId: item['id'],
                              productName: name,
                              pricePerKg: price,
                              unit: unit,
                              farmerName: farmer,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: Text(
                        L10n.get(
                          "Add To Cart / Place Order",
                          "ഓർഡർ ചെയ്യുക",
                          "ऑर्डर करें",
                          "ஆர்டர் செய்",
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatFarmerScreen(
                              farmerName: farmer,
                              farmerPhone: farmerPhone,
                              productName: name,
                              farmerLocation: location,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat),
                      label: Text(
                        L10n.get(
                          "Contact Farmer",
                          "കർഷകനെ ബന്ധപ്പെടുക",
                          "किसान से संपर्क करें",
                          "விவசாயியை தொடர்பு கொள்ளவும்",
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green.shade800,
                        side: BorderSide(color: Colors.green.shade700),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}