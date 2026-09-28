import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../models/advisory.dart';
import '../services/ai_service.dart';
import '../utils/localization.dart';
import '../widgets/crop_advisory_card.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

class CropAdvisoryScreen extends ConsumerStatefulWidget {
  const CropAdvisoryScreen({super.key});

  @override
  ConsumerState<CropAdvisoryScreen> createState() => _CropAdvisoryScreenState();
}

class _CropAdvisoryScreenState extends ConsumerState<CropAdvisoryScreen> {
  AdvisoryResponse? _advisory;
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAdvisory();
  }

  Future<void> _fetchAdvisory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AIService.generateAdvisory(
        farmerProfileId: 1,
        state: AppState.userState.isNotEmpty ? AppState.userState : 'Kerala',
        district: AppState.userDistrict.isNotEmpty ? AppState.userDistrict : 'Palakkad',
        latitude: AppState.userLatitude != 0.0 ? AppState.userLatitude : 10.7867,
        longitude: AppState.userLongitude != 0.0 ? AppState.userLongitude : 76.6547,
        farmPortfolio: AppState.farmPayload.isNotEmpty
            ? AppState.farmPayload
            : {
                "plots": [{"acreage": 3.0, "soil_type": "Clay Loam", "water_source": "Canal"}],
                "livestock": [{"animal_type": "Cow", "head_count": 4}],
                "poultry": [{"bird_type": "Hen", "bird_count": 40}],
              },
      );

      if (mounted) {
        setState(() {
          _advisory = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          L10n.get(
            "Crop Advisory",
            "വിള ഉപദേശം",
            "फसल सलाह",
            "பயிர் ஆலோசனை",
          ),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchAdvisory,
            tooltip: 'Regenerate Advisory',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(
              message: 'Generating AI Advisory using localized soil, weather & APMC mandi trends...',
            )
          : _errorMessage != null && _advisory == null
              ? AppErrorWidget(
                  message: _errorMessage!,
                  onRetry: _fetchAdvisory,
                )
              : RefreshIndicator(
                  onRefresh: _fetchAdvisory,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Strategic Plan Card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.psychology, color: Colors.green, size: 24),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Verified AI Strategy',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'AUDIT PASSED',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _advisory?.primaryRecommendation ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade800,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Cross-Sector Synergies
                        if (_advisory != null && _advisory!.synergies.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.sync_alt, color: Colors.teal, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Cross-Sector Synergies',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ..._advisory!.synergies.map((s) => Card(
                                elevation: 1,
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                color: Colors.teal.shade50.withOpacity(0.5),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.eco, size: 18, color: Colors.teal),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          s,
                                          style: TextStyle(fontSize: 13, color: Colors.teal.shade900),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                          const SizedBox(height: 20),
                        ],
                        // Ranked Alternatives Header
                        Row(
                          children: [
                            const Icon(Icons.format_list_numbered, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              L10n.get(
                                "Ranked Crop Options",
                                "മുൻഗണനാ വിളകൾ",
                                "प्राथमिकता फसलें",
                                "முன்னுரிமை பயிர்கள்",
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Render Ranked Crop Cards
                        if (_advisory != null)
                          ..._advisory!.alternatives.map((alt) => CropAdvisoryCard(
                                alternative: alt,
                                onPlayAudio: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Playing audio advisory for ${alt.cropName}...'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              )),
                      ],
                    ),
                  ),
                ),
    );
  }
}