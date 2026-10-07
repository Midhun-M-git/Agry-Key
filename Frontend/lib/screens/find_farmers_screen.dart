import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../utils/localization.dart';
import '../widgets/voice_text_field.dart';
import 'chat_farmer_screen.dart';

class FindFarmersScreen extends StatefulWidget {
  const FindFarmersScreen({super.key});

  @override
  State<FindFarmersScreen> createState() => _FindFarmersScreenState();
}

class _FindFarmersScreenState extends State<FindFarmersScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> _farmers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFarmers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFarmers([String? query]) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final q = query ?? searchController.text.trim();
      var uriString = '${ApiConfig.baseUrl}/api/v1/services/farmers';
      if (q.isNotEmpty) {
        uriString += '?crop=${Uri.encodeComponent(q)}';
      }

      final response = await http.get(Uri.parse(uriString)).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as List<dynamic>;
        if (!mounted) return;
        setState(() {
          _farmers = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load farmers (${response.statusCode})");
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Could not fetch farmer directory. Check your connection.";
      });
    }
  }

  Widget farmerCard(Map<String, dynamic> f) {
    final name = f['farmer_name'] ?? 'Registered Producer';
    final crop = f['crop'] ?? 'Agricultural Produce';
    final location = "${f['village']?.isNotEmpty == true ? "${f['village']}, " : ""}${f['district'] ?? 'Kerala'}";
    final phone = f['phone_masked'] ?? 'Verified Contact';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  radius: 22,
                  child: const Icon(Icons.person, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.verified, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text("AgriStack Verified", style: TextStyle(color: Colors.blue.shade700, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.grass, color: Colors.green, size: 18),
                const SizedBox(width: 6),
                Text(crop, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text(location, style: TextStyle(color: Colors.grey.shade700))),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.grey, size: 16),
                const SizedBox(width: 6),
                Text(phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatFarmerScreen(
                            farmerName: name,
                            farmerPhone: phone,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text("Message Farmer"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: Text(
          L10n.get(
            "Find Farmers",
            "കർഷകരെ കണ്ടെത്തുക",
            "किसानों को खोजें",
            "விவசாயிகளை கண்டறியுங்கள்",
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchFarmers(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            VoiceTextField(
              controller: searchController,
              hintText: L10n.get(
                "Search farmer, crop or location...",
                "കർഷകൻ, വിള അല്ലെങ്കിൽ സ്ഥലം തിരയുക...",
                "किसान, फसल या स्थान खोजें...",
                "விவசாயி, பயிர் அல்லது இடத்தை தேடுங்கள்...",
              ),
              onChanged: (val) {
                if (val.isEmpty) _fetchFarmers();
              },
            ),
            const SizedBox(height: 14),
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
                                onPressed: () => _fetchFarmers(),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text("Retry", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        )
                      : _farmers.isEmpty
                          ? Center(
                              child: Text(
                                "No registered farmers found for this query.",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => _fetchFarmers(),
                              color: Colors.green,
                              child: ListView.builder(
                                itemCount: _farmers.length,
                                itemBuilder: (ctx, i) => farmerCard(_farmers[i]),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}