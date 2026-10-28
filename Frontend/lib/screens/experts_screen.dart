import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../core/api_config.dart';
import '../core/app_state.dart';
import '../utils/localization.dart';

class ExpertsScreen extends StatefulWidget {
  const ExpertsScreen({super.key});

  @override
  State<ExpertsScreen> createState() => _ExpertsScreenState();
}

class _ExpertsScreenState extends State<ExpertsScreen> {
  List<Map<String, dynamic>> _experts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchExperts();
  }

  Future<void> _fetchExperts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (AppState.district.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = L10n.get(
            "Please select your district to view local agricultural officers.",
            "പ്രാദേശിക കൃഷി ഓഫീസർമാരെ കാണാൻ ദയവായി നിങ്ങളുടെ ജില്ല തിരഞ്ഞെടുക്കുക.",
            "स्थानीय कृषि अधिकारियों को देखने के लिए कृपया अपना जिला चुनें।",
            "உள்ளூர் வேளாண்மை அதிகாரிகளைப் பார்க்க உங்கள் மாவட்டத்தைத் தேர்ந்தெடுக்கவும்.",
          );
        });
        return;
      }
      final district = AppState.district;
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/services/experts?district=${Uri.encodeComponent(district)}');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as List<dynamic>;
        if (!mounted) return;
        setState(() {
          _experts = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load contacts: ${response.statusCode}");
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = L10n.get(
          "Could not fetch agricultural contacts. Please check your connection.",
          "വിവരങ്ങൾ ലഭ്യമായില്ല. ദയവായി ഇന്റർനെറ്റ് കണക്ഷൻ പരിശോധിക്കുക.",
          "कृषि संपर्क लोड नहीं हो सके। कृपया अपना कनेक्शन जांचें।",
          "வேளாண்மை தொடர்புகளைப் பெற முடியவில்லை. இணைப்பைச் சரிபார்க்கவும்.",
        );
        _experts = [];
      });
    }
  }

  Future<void> _callNumber(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  IconData _getIconForCategory(String? cat) {
    switch (cat?.toUpperCase()) {
      case 'HELPLINE':
        return Icons.support_agent;
      case 'VETERINARY':
        return Icons.local_hospital;
      case 'SOIL_LAB':
      case 'KVK':
        return Icons.science;
      case 'KRISHI_BHAVAN':
      case 'GOVERNMENT':
      default:
        return Icons.account_balance;
    }
  }

  Widget expertCard(Map<String, dynamic> exp) {
    final title = exp["title"] ?? "Agricultural Officer";
    final name = exp["name"] ?? "";
    final location = exp["location"] ?? "";
    final phone = exp["phone"] ?? "";
    final category = exp["category"] as String?;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              radius: 22,
              child: Icon(_getIconForCategory(category), color: Colors.green.shade800),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (name.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(name, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  ],
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(location, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              tooltip: "Call Helpline",
              onPressed: () => _callNumber(phone),
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
            "Nearby Experts & Helplines",
            "വിദഗ്ധരും ഹെൽപ്പ്‌ലൈനുകളും",
            "विशेषज्ञ एवं हेल्पलाइन",
            "நிபுணர்கள் மற்றும் உதவி எண்கள்",
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchExperts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : RefreshIndicator(
              onRefresh: _fetchExperts,
              color: Colors.green,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Official Government Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.green, size: 26),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Verified State & Central Government Agricultural Helplines and Krishi Bhavan extension officers.",
                            style: TextStyle(color: Colors.green.shade900, fontSize: 13, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._experts.map((e) => expertCard(e)),
                ],
              ),
            ),
    );
  }
}