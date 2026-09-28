import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/scheme.dart';

class SchemesService {
  /// Fetches active government schemes with optional state, category, or sector filter.
  static Future<List<GovernmentScheme>> fetchSchemes({
    String? state,
    String? category,
    String? sector,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (state != null && state.isNotEmpty) queryParams['state'] = state;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (sector != null && sector.isNotEmpty) queryParams['sector'] = sector;

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/schemes').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((item) => GovernmentScheme.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    // Fallback bundled schemes
    return _getFallbackSchemes();
  }

  /// Fetches detailed scheme data including full eligibility criteria and application steps.
  static Future<GovernmentScheme?> getSchemeDetail(int schemeId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/schemes/$schemeId');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return GovernmentScheme.fromJson(data);
      }
    } catch (_) {}

    final all = _getFallbackSchemes();
    return all.firstWhere((s) => s.id == schemeId, orElse: () => all.first);
  }

  static List<GovernmentScheme> _getFallbackSchemes() {
    return [
      GovernmentScheme(
        id: 1,
        code: 'PM-KISAN',
        name: 'Pradhan Mantri Kisan Samman Nidhi',
        level: 'CENTRAL',
        category: 'INCOME_SUPPORT',
        sector: 'ALL',
        description: 'Direct financial assistance of ₹6,000 per year in three equal instalments to landholding farmers.',
        benefits: [
          '₹6,000 per year directly to bank account',
          'DBT transfer ensures zero middlemen commission',
        ],
        eligibility: [
          'Eligible landholding farmer families',
          'Valid Aadhaar and active bank account seeded with Aadhaar',
        ],
        applicationProcess: [
          'Register on PM-KISAN portal or via local Krishi Bhavan',
          'Complete mandatory e-KYC verification',
        ],
        documents: ['Aadhaar Card', 'Land Ownership Records (Pattadar Passbook)', 'Bank Passbook'],
        officialUrl: 'https://pmkisan.gov.in/',
      ),
      GovernmentScheme(
        id: 2,
        code: 'PMFBY',
        name: 'Pradhan Mantri Fasal Bima Yojana',
        level: 'CENTRAL',
        category: 'CROP_INSURANCE',
        sector: 'CROP',
        description: 'Comprehensive financial support against non-preventable natural risks from pre-sowing to post-harvest.',
        benefits: [
          'Subsidized premium: 2% for Kharif, 1.5% for Rabi crops',
          'Full insured sum payout on catastrophic crop damage',
        ],
        eligibility: [
          'Farmers growing notified crops in notified areas',
          'Sharecroppers and tenant farmers are also eligible',
        ],
        applicationProcess: [
          'Enroll before the seasonal cut-off date through bank or CSC',
          'Report crop loss within 72 hours of damage on NCIP portal',
        ],
        documents: ['Aadhaar', 'Land Record / Tenancy Agreement', 'Sowing Certificate'],
        officialUrl: 'https://pmfby.gov.in/',
      ),
      GovernmentScheme(
        id: 3,
        code: 'KLS-SUBSIDY',
        name: 'Kerala Subhiksha Keralam Integrated Farming Support',
        level: 'STATE',
        state: 'Kerala',
        category: 'SUBSIDY',
        sector: 'ALL',
        description: 'State government incentive for multi-sector integrated farming combining paddy, dairy, poultry, and aquaculture.',
        benefits: [
          'Up to 50% capital subsidy on livestock shed and pond excavation',
          'Zero-interest crop loans for certified eco-friendly cultivation',
        ],
        eligibility: [
          'Farmers with land in Kerala practicing at least two agriculture sectors',
          'Registration with local Krishi Bhavan',
        ],
        applicationProcess: [
          'Submit integrated farm plan at local Krishi Bhavan',
          'Physical inspection by Agricultural Officer',
        ],
        documents: ['Aadhaar', 'Tax Paid Land Receipt', 'Krishi Bhavan Registration Number'],
        officialUrl: 'https://keralaagriculture.gov.in/',
      ),
    ];
  }
}