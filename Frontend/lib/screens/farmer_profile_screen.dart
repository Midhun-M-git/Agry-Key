import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../core/api_config.dart';
import '../core/app_state.dart';
import '../services/api_service.dart';
import 'chat_farmer_screen.dart';
import 'edit_profile_screen.dart';
import 'farmer_products_screen.dart';
import 'settings_screen.dart';

class FarmerProfileScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? farmerData;

  const FarmerProfileScreen({
    super.key,
    this.farmerData,
  });

  @override
  ConsumerState<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends ConsumerState<FarmerProfileScreen> {
  int _activeListingsCount = 0;
  bool _isLoadingListings = false;

  @override
  void initState() {
    super.initState();
    if (widget.farmerData == null) {
      _loadMyListingsCount();
    }
  }

  Future<void> _loadMyListingsCount() async {
    setState(() => _isLoadingListings = true);
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/marketplace/my-listings');
      final res = await ApiService.requestWithAuth(method: 'GET', uri: uri);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        if (mounted) {
          setState(() {
            _activeListingsCount = list.length;
            _isLoadingListings = false;
          });
          return;
        }
      }
    } catch (_) {}

    try {
      final fallbackUri = Uri.parse('${ApiConfig.baseUrl}/api/v1/marketplace/products');
      final res = await http.get(fallbackUri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        if (mounted) {
          setState(() {
            _activeListingsCount = list.length;
            _isLoadingListings = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoadingListings = false);
    }
  }

  Future<void> _callPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    } catch (_) {}

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.phone, color: Colors.green),
            SizedBox(width: 8),
            Text("Farmer Helpline"),
          ],
        ),
        content: Text("Direct Phone: $phone\n\nOfficial Krishi Call Centre: 1800-180-1551"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
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

  Widget statCard(String count, String title, IconData icon) {
    return Expanded(
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
                  fontSize: 18,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);

    final isPeerFarmer = widget.farmerData != null;
    final data = widget.farmerData ?? {};

    final String name = isPeerFarmer
        ? (data['name'] ?? data['farmer_name'] ?? 'Verified Farmer')
        : (AppState.userName.isNotEmpty ? AppState.userName : 'Kisan Member');

    final String phone = isPeerFarmer
        ? (data['phone'] ?? '+91 94471 23456')
        : (AppState.userPhone.isNotEmpty ? AppState.userPhone : 'Official Registered Contact');

    final String location = isPeerFarmer
        ? (data['location'] ?? data['district'] ?? 'Palakkad, Kerala')
        : (AppState.userLocation.isNotEmpty ? AppState.userLocation : 'Palakkad, Kerala');

    final String crops = isPeerFarmer
        ? (data['crops'] ?? data['crop_type'] ?? 'Paddy, Nendran Banana, Spices')
        : (AppState.userCrop.isNotEmpty ? AppState.userCrop : 'Paddy, Coconut, Vegetables');

    final String experience = isPeerFarmer
        ? (data['experience'] ?? '12+ Years Farming')
        : 'Registered Producer';

    final String rating = isPeerFarmer
        ? (data['rating']?.toString() ?? '4.9')
        : '5.0 (Govt Verified)';

    final String productsCount = isPeerFarmer
        ? (data['products']?.toString() ?? data['active_listings']?.toString() ?? '5')
        : (_isLoadingListings ? "..." : _activeListingsCount.toString());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(isPeerFarmer ? "Farmer Profile" : "My Farmer Profile"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (!isPeerFarmer)
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
            // Hero Profile Header
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
                      backgroundColor: Colors.green.shade100,
                      child: Icon(Icons.agriculture, size: 48, color: Colors.green.shade800),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
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
                          "Krishi Bhavan Verified",
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

            // Live Performance Badges
            Row(
              children: [
                statCard(productsCount, isPeerFarmer ? "Lots Offered" : "My Lots", Icons.inventory_2),
                const SizedBox(width: 8),
                statCard(rating, "Quality Rating", Icons.star),
                const SizedBox(width: 8),
                statCard(experience, "Status", Icons.workspace_premium),
              ],
            ),

            const SizedBox(height: 16),

            infoCard(Icons.phone, "Direct Helpline / Phone", phone),
            infoCard(Icons.location_on, "Primary Farming Hub", location),
            infoCard(Icons.eco, "Primary Crops & Produce", crops),

            const SizedBox(height: 20),

            if (isPeerFarmer) ...[
              // Action Buttons for Buyer viewing Farmer
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _callPhone(phone),
                  icon: const Icon(Icons.call),
                  label: const Text("Call Farmer", style: TextStyle(fontSize: 16)),
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
                      MaterialPageRoute(
                        builder: (_) => ChatFarmerScreen(
                          farmerName: name,
                          farmerPhone: phone,
                          farmerLocation: location,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text("Chat with Farmer", style: TextStyle(fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade800,
                    side: BorderSide(color: Colors.green.shade700, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ] else ...[
              // Action Buttons for Farmer viewing Own Profile
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
                  label: const Text("Edit Profile & Farm Info", style: TextStyle(fontSize: 16)),
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
                      MaterialPageRoute(builder: (_) => const FarmerProductsScreen()),
                    );
                  },
                  icon: const Icon(Icons.storefront),
                  label: const Text("Manage My Marketplace Lots", style: TextStyle(fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade800,
                    side: BorderSide(color: Colors.green.shade700, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}