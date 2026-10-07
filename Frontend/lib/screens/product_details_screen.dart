import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chat_farmer_screen.dart';
import 'farmer_profile_screen.dart';
import 'place_order_screen.dart';
import 'request_quote_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic>? product;

  const ProductDetailsScreen({
    super.key,
    this.product,
  });

  Future<void> _makePhoneCall(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    } catch (_) {}

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.phone, color: Colors.green),
              SizedBox(width: 8),
              Text("Direct Producer Contact"),
            ],
          ),
          content: Text("Phone Number: $phone\n\nOfficial Kisan Call Centre: 1800-180-1551"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = product ?? {};

    final String title = item['name'] as String? ??
        item['crop_type'] as String? ??
        item['title'] as String? ??
        'Highland Matta Rice';

    final double price = (item['price_per_unit'] as num?)?.toDouble() ??
        (item['price'] as num?)?.toDouble() ??
        42.0;

    final String unit = item['unit'] as String? ?? 'kg';

    final double quantity = (item['quantity'] as num?)?.toDouble() ??
        (item['available_quantity_kg'] as num?)?.toDouble() ??
        50.0;

    final String farmerName = item['farmer_name'] as String? ??
        item['farmer'] as String? ??
        'Suresh Menon';

    final String farmerPhone = item['farmer_phone'] as String? ??
        item['phone'] as String? ??
        '+91 94471 23456';

    final String location = item['district'] as String? ??
        item['location'] as String? ??
        'Palakkad, Kerala';

    final String grade = item['quality_grade'] as String? ?? 'A';
    final String sector = item['sector'] as String? ?? 'CROPS';

    final String description = item['description'] as String? ??
        'Directly harvested farm produce certified by local agricultural cluster. Strictly zero artificial ripening agents and 100% farm traceability.';

    final int? productId = item['id'] as int?;

    IconData sectorIcon = Icons.agriculture;
    if (sector == 'DAIRY') sectorIcon = Icons.water_drop;
    if (sector == 'AQUACULTURE') sectorIcon = Icons.set_meal;
    if (sector == 'POULTRY') sectorIcon = Icons.egg;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Visual Banner
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade100, Colors.green.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Icon(
                  sectorIcon,
                  size: 90,
                  color: Colors.green.shade800,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Text(
                          "Grade $grade",
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "₹${price.toStringAsFixed(0)} / $unit",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Farmer Producer Card (Clickable to view full Farmer Profile)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: const Icon(Icons.person, color: Colors.green),
                          ),
                          title: Text(
                            farmerName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text("Verified Agricultural Producer"),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FarmerProfileScreen(
                                  farmerData: {
                                    'name': farmerName,
                                    'phone': farmerPhone,
                                    'location': location,
                                    'crops': title,
                                    'rating': 4.9,
                                    'experience': '12+ Years Farming',
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.star, color: Colors.amber),
                          title: const Text("Farmer Rating"),
                          subtitle: const Text("4.9 / 5.0 (Govt Inspected)"),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text("Verified", style: TextStyle(color: Colors.green, fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Lot Specifications Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.location_on, color: Colors.redAccent),
                          title: const Text("Farm Location"),
                          subtitle: Text(location),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.inventory_2, color: Colors.green),
                          title: const Text("Available Harvest Lot"),
                          subtitle: Text("${quantity.toStringAsFixed(0)} $unit available for pickup"),
                        ),
                        const Divider(height: 1),
                        const ListTile(
                          leading: Icon(Icons.local_shipping, color: Colors.teal),
                          title: Text("Logistics Option"),
                          subtitle: Text("Farmgate Pickup or Agry-Key Inter-District Dispatch"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Produce Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Live Contact Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _makePhoneCall(context, farmerPhone),
                          icon: const Icon(Icons.call, size: 18),
                          label: const Text("Call Producer"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatFarmerScreen(
                                  farmerName: farmerName,
                                  farmerPhone: farmerPhone,
                                  productName: title,
                                  farmerLocation: location,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat, size: 18),
                          label: const Text("Chat Now"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green.shade800,
                            side: BorderSide(color: Colors.green.shade700),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Request Quote
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RequestQuoteScreen(
                              productName: title,
                              farmerName: farmerName,
                              currentPrice: price,
                              unit: unit,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.request_quote),
                      label: const Text("Negotiate / Request Bulk Quote"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.teal.shade800,
                        side: BorderSide(color: Colors.teal.shade700),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Place Order Directly
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlaceOrderScreen(
                              productId: productId,
                              productName: title,
                              pricePerKg: price,
                              unit: unit,
                              farmerName: farmerName,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_checkout),
                      label: const Text(
                        "Place Order Now",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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