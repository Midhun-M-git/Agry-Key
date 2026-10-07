import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../core/app_state.dart';
import '../services/orders_service.dart';
import 'buyer_orders_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class BuyerProfileScreen extends ConsumerStatefulWidget {
  const BuyerProfileScreen({super.key});

  @override
  ConsumerState<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends ConsumerState<BuyerProfileScreen> {
  int _orderCount = 0;
  int _farmerCount = 0;
  List<String> _recentCrops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileStats();
  }

  Future<void> _fetchProfileStats() async {
    setState(() => _isLoading = true);

    try {
      final orders = await OrdersService.getOrders();
      _orderCount = orders.length;
      final cropNames = <String>{};
      for (var o in orders) {
        if (o.productName.isNotEmpty) {
          cropNames.add(o.productName);
        }
      }
      if (cropNames.isNotEmpty) {
        _recentCrops = cropNames.take(4).toList();
      }
    } catch (_) {}

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/services/farmers');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          _farmerCount = decoded.length;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Widget infoCard(IconData icon, String title, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.green.shade700),
        ),
        title: Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
    );
  }

  Widget statCard(String count, String title, IconData icon, VoidCallback? onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                Icon(icon, color: Colors.green.shade700, size: 28),
                const SizedBox(height: 6),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);

    final String userName =
        AppState.userName.isEmpty ? "Direct Agricultural Buyer" : AppState.userName;
    final String location =
        AppState.userLocation.isEmpty ? "South India Ag-Trade Zone" : AppState.userLocation;
    final String phone =
        AppState.userPhone.isEmpty ? "Registered Business Mobile" : AppState.userPhone;

    final cropsDisplay = _recentCrops.isNotEmpty
        ? _recentCrops.join(", ")
        : "Direct Farm Sourced Lots";

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Buyer Profile"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.green.shade50,
                      child: Icon(Icons.business_center, size: 44, color: Colors.green.shade800),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          "Direct Marketplace Buyer",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Live Stat Cards
            Row(
              children: [
                statCard(
                  _isLoading ? "..." : "$_orderCount",
                  "My Orders",
                  Icons.shopping_bag,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BuyerOrdersScreen()),
                    );
                  },
                ),
                const SizedBox(width: 8),
                statCard(
                  _isLoading ? "..." : "$_farmerCount+",
                  "Sourcing Hubs",
                  Icons.agriculture,
                  null,
                ),
                const SizedBox(width: 8),
                statCard(
                  "0%",
                  "Intermediary Cut",
                  Icons.handshake,
                  null,
                ),
              ],
            ),

            const SizedBox(height: 16),

            infoCard(Icons.person, "Trade Name", userName),
            infoCard(Icons.phone, "Registered Phone", phone),
            infoCard(Icons.location_on, "Trade Hub / District", location),
            infoCard(Icons.category, "Produce Sourced", cropsDisplay),
            infoCard(Icons.verified_user, "Settlement Mechanism", "Digital Escrow & UPI Direct"),

            const SizedBox(height: 20),

            // Fully Functional Action Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile & Business Info", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    MaterialPageRoute(builder: (_) => const BuyerOrdersScreen()),
                  );
                },
                icon: const Icon(Icons.local_shipping),
                label: const Text("Track Active Shipments", style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade800,
                  side: BorderSide(color: Colors.green.shade700, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}