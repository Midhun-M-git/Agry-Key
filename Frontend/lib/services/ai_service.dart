import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/advisory.dart';

class AIService {
  /// Calls the backend Triple-Autonomous-Agent Advisory Engine (/api/v1/advisory/generate).
  static Future<AdvisoryResponse> generateAdvisory({
    required int farmerProfileId,
    required String state,
    required String district,
    required double latitude,
    required double longitude,
    required Map<String, dynamic> farmPortfolio,
  }) async {
    try {
      final payload = {
        'farmer_profile_id': farmerProfileId,
        'state': state,
        'district': district,
        'latitude': latitude,
        'longitude': longitude,
        'farm_portfolio': farmPortfolio,
      };

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/advisory/generate');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final finalStrategy = data['final_strategy'] as String? ?? '';

        return AdvisoryResponse(
          primaryRecommendation: finalStrategy,
          alternatives: [],
          synergies: [],
          weatherAlert: null,
          auditPassed: true,
          generatedAt: DateTime.now(),
        );
      }
    } catch (_) {}

    return AdvisoryResponse(
      primaryRecommendation:
          'Unable to generate advisory at this time. Please check your internet connection and try again.',
      alternatives: [],
      synergies: [],
      weatherAlert: null,
      auditPassed: false,
      generatedAt: DateTime.now(),
    );
  }

  /// Interactive AI chat — calls the real /advisory/chat endpoint.
  static Future<String> askQuestion({
    required String question,
    String state = 'Kerala',
    String district = '',
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/advisory/chat');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': question,
          'state': state,
          'district': district,
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['answer'] as String? ??
            'No answer received.';
      }
    } catch (_) {}

    return 'Unable to connect to Agry-Key AI. Please check your internet connection.';
  }

  /// Calls multi-variable financial crop optimization endpoint (/api/v1/advisory/crop-recommendations).
  /// Strictly requires verified user-supplied crop parameters or live database observations.
  static Future<Map<String, dynamic>> getCropRecommendations({
    required String state,
    required String district,
    required double acreage,
    required String soilType,
    required String waterSource,
    double latitude = 0.0,
    double longitude = 0.0,
    List<Map<String, dynamic>>? cropCandidates,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/advisory/crop-recommendations');
      final payload = <String, dynamic>{
        'state': state,
        'district': district,
        'acreage': acreage > 0 ? acreage : 1.0,
        'soil_type': soilType,
        'water_source': waterSource,
        'latitude': latitude,
        'longitude': longitude,
      };
      if (cropCandidates != null && cropCandidates.isNotEmpty) {
        payload['crop_candidates'] = cropCandidates;
      }

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data.containsKey('strategies')) {
          return data;
        }
      }
    } catch (_) {}

    // Strict Fail-Closed: Never fabricate crop financials or ROI percentages
    return {
      "status": "unavailable",
      "reason": "Crop financial optimization is currently unavailable. Live observations or user inputs required.",
      "strategies": {},
    };
  }
}