import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'token_service.dart';

class SoilReportItem {
  final int id;
  final int farmerProfileId;
  final String? plotName;
  final String? shcNumber;
  final double phLevel;
  final double organicCarbonPercent;
  final String nitrogenStatus;
  final String phosphorusStatus;
  final String potassiumStatus;
  final String testingLabName;
  final String? issueDate;

  SoilReportItem({
    required this.id,
    required this.farmerProfileId,
    this.plotName,
    this.shcNumber,
    required this.phLevel,
    required this.organicCarbonPercent,
    required this.nitrogenStatus,
    required this.phosphorusStatus,
    required this.potassiumStatus,
    required this.testingLabName,
    this.issueDate,
  });

  factory SoilReportItem.fromJson(Map<String, dynamic> json) {
    return SoilReportItem(
      id: json['id'] as int? ?? 0,
      farmerProfileId: json['farmer_profile_id'] as int? ?? 0,
      plotName: json['plot_name'] as String?,
      shcNumber: json['shc_number'] as String?,
      phLevel: (json['ph_level'] as num?)?.toDouble() ?? 6.5,
      organicCarbonPercent: (json['organic_carbon_percent'] as num?)?.toDouble() ?? 0.6,
      nitrogenStatus: json['nitrogen_status'] as String? ?? 'MEDIUM',
      phosphorusStatus: json['phosphorus_status'] as String? ?? 'MEDIUM',
      potassiumStatus: json['potassium_status'] as String? ?? 'MEDIUM',
      testingLabName: json['testing_lab_name'] as String? ?? 'District Soil Testing Lab',
      issueDate: json['issue_date'] as String?,
    );
  }
}

class SoilRecommendationItem {
  final String inputName;
  final String purpose;
  final String applicationGuidance;

  SoilRecommendationItem({
    required this.inputName,
    required this.purpose,
    required this.applicationGuidance,
  });

  factory SoilRecommendationItem.fromJson(Map<String, dynamic> json) {
    return SoilRecommendationItem(
      inputName: json['input_name'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      applicationGuidance: json['application_guidance'] as String? ?? '',
    );
  }
}

class SoilHealthData {
  final String district;
  final String soilType;
  final double averagePh;
  final double averageOc;
  final List<SoilRecommendationItem> recommendations;
  final List<SoilReportItem> userReports;
  final List<String> suitableCrops;
  final String? surveyAuthority;

  SoilHealthData({
    required this.district,
    required this.soilType,
    required this.averagePh,
    required this.averageOc,
    required this.recommendations,
    required this.userReports,
    this.suitableCrops = const [],
    this.surveyAuthority,
  });
}

class SoilService {
  static Future<SoilHealthData> getSoilHealth({
    String district = 'Palakkad',
    String soilType = 'RED_LOAMY',
    int? farmerProfileId,
  }) async {
    List<SoilRecommendationItem> recommendations = [];
    List<SoilReportItem> userReports = [];
    List<String> suitableCrops = [];
    String? surveyAuthority;
    double avgPh = 6.5;
    double avgOc = 0.65;

    // 1. Fetch district soil recommendations and survey
    try {
      final recUri = Uri.parse(
        '${ApiConfig.baseUrl}/api/v1/soil/recommendations?district=${Uri.encodeComponent(district)}&soil_type=${Uri.encodeComponent(soilType)}',
      );
      final res = await http.get(recUri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final rawRecs = decoded['recommendations'] as List<dynamic>? ?? [];
        recommendations = rawRecs
            .map((r) => SoilRecommendationItem.fromJson(r as Map<String, dynamic>))
            .toList();

        final survey = decoded['regional_survey'] as Map<String, dynamic>?;
        if (survey != null) {
          surveyAuthority = survey['survey_authority'] as String?;
          final taluks = survey['panchayaths_and_taluks'] as List<dynamic>? ?? [];
          if (taluks.isNotEmpty) {
            final firstTaluk = taluks.first as Map<String, dynamic>;
            avgPh = (firstTaluk['ph_level'] as num?)?.toDouble() ?? 6.5;
            avgOc = (firstTaluk['organic_carbon_percent'] as num?)?.toDouble() ?? 0.65;
            final crops = firstTaluk['suitable_crops'] as List<dynamic>? ?? [];
            suitableCrops = crops.map((c) => c.toString()).toList();
          }
        }
      }
    } catch (_) {}

    // 2. Fetch authenticated user reports if profileId exists
    if (farmerProfileId != null && farmerProfileId > 0) {
      try {
        final token = await TokenService.getAccessToken();
        if (token != null && token.isNotEmpty) {
          final repUri = Uri.parse('${ApiConfig.baseUrl}/api/v1/soil/report?farmer_profile_id=$farmerProfileId');
          final repRes = await http
              .get(repUri, headers: {'Authorization': 'Bearer $token'})
              .timeout(const Duration(seconds: 10));
          if (repRes.statusCode == 200) {
            final decoded = jsonDecode(repRes.body) as Map<String, dynamic>;
            final rawReports = decoded['reports'] as List<dynamic>? ?? [];
            userReports = rawReports
                .map((r) => SoilReportItem.fromJson(r as Map<String, dynamic>))
                .toList();
          }
        }
      } catch (_) {}
    }

    // Default fallback recommendations if offline or empty
    if (recommendations.isEmpty) {
      recommendations = [
        SoilRecommendationItem(
          inputName: "Organic Compost / Farmyard Manure",
          purpose: "Increase soil organic matter and water-holding capacity.",
          applicationGuidance: "Apply 5-10 tonnes/hectare during field preparation before sowing.",
        ),
        SoilRecommendationItem(
          inputName: "Soil-test-based Balanced NPK",
          purpose: "Supply essential nitrogen, phosphorus, and potash tailored to crop stage.",
          applicationGuidance: "Apply nitrogen in 2-3 split doses; incorporate phosphorus as basal dose.",
        ),
      ];
    }

    if (suitableCrops.isEmpty) {
      suitableCrops = ["Paddy", "Banana", "Vegetables", "Pulses", "Coconut"];
    }

    return SoilHealthData(
      district: district,
      soilType: soilType,
      averagePh: avgPh,
      averageOc: avgOc,
      recommendations: recommendations,
      userReports: userReports,
      suitableCrops: suitableCrops,
      surveyAuthority: surveyAuthority,
    );
  }
}
