import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../utils/localization.dart';
import 'buyer_profile_screen.dart';
import 'place_order_screen.dart';
import 'product_details_screen.dart';

class BuyerScreen extends StatefulWidget {
  const BuyerScreen({super.key});

  @override
  State<BuyerScreen> createState() => _BuyerScreenState();
}

class _BuyerScreenState extends State<BuyerScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = "ALL";

  final List<String> _categories = ["ALL", "CROPS", "DAIRY", "POULTRY", "AQUACULTURE"];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final queryParams = <String, String>{};
      if (_selectedCategory != "ALL") {
        queryParams['sector'] = _selectedCategory;
      }
      final search = _searchController.text.trim();
      if (search.isNotEmpty) {
        queryParams['crop_type'] = search;
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/marketplace/products')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          _products = (decoded as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load products: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Could not reach marketplace service. Check your connection.";
      });
    }
  }

  Widget categoryChip(String text) {
    final isSelected = _selectedCategory.toUpperCase() == text.toUpperCase();
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = text;
        });
        _fetchProducts();
      },
      child: Chip(
        label: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.green.shade900,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        backgroundColor: isSelected ? Colors.green : Colors.green.shade50,
      ),
    );
  }

  Widget statCard(IconData icon, String count, String title) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: Colors.green, size: 28),
              const SizedBox(height: 5),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget productCard(Map<String, dynamic> item) {
    final id = item['id'] as int? ?? 0;
    final name = item['name'] ?? item['crop_type'] ?? 'Produce';
    final seller = item['farmer_name'] ?? 'Verified Producer';
    final qty = "${item['quantity'] ?? item['quantity_available'] ?? 0} ${item['unit'] ?? 'kg'}";
    final location = item['district'] ?? 'Kerala';
    final price = "₹${item['price_per_unit'] ?? 0}/${item['unit'] ?? 'kg'}";
    final sector = item['sector'] ?? 'CROP';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.green.shade100,
                    child: Icon(
                      sector == 'DAIRY'
                          ? Icons.local_drink
                          : (sector == 'POULTRY' ? Icons.egg : Icons.agriculture),
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Farmer: $seller",
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                        ),
                        Text(
                          "Location: $location",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        qty,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsScreen(product: item),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text("Details"),
                    style: TextButton.styleFrom(foregroundColor: Colors.green.shade700),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlaceOrderScreen(
                            productId: id.toString(),
                            productName: name,
                            price: (item['price_per_unit'] as num?)?.toDouble() ?? 0.0,
                            unit: item['unit'] ?? 'kg',
                            farmerId: (item['farmer_id'] as int?) ?? 1,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_bag, size: 16),
                    label: const Text("Order Now"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Buyer Marketplace"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Produce",
            onPressed: _fetchProducts,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BuyerProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Welcome Header
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.shopping_basket, color: Colors.green, size: 28),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Direct Farmer Sourcing",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Verified produce with zero middlemen commission",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Live Stats Bar
            Row(
              children: [
                statCard(Icons.shopping_bag, "${_products.length}", "Available Lots"),
                statCard(Icons.verified, "100%", "Verified Farmers"),
              ],
            ),
            const SizedBox(height: 12),

            // Search Bar
            TextField(
              controller: _searchController,
              onSubmitted: (_) => _fetchProducts(),
              decoration: InputDecoration(
                hintText: "Search crops, vegetables, dairy...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _fetchProducts,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Categories Filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories
                    .map((cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: categoryChip(cat),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Produce List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.wifi_off, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(_errorMessage!, style: TextStyle(color: Colors.grey.shade600)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _fetchProducts,
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text("Retry", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        )
                      : _products.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    "No produce listings found matching your search.",
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      _selectedCategory = "ALL";
                                      _fetchProducts();
                                    },
                                    child: const Text("View All Produce"),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchProducts,
                              color: Colors.green,
                              child: ListView.builder(
                                itemCount: _products.length,
                                itemBuilder: (context, index) => productCard(_products[index]),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}