import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/scheme.dart';

class SchemesService {
  /// Fetches active government schemes with optional state, category, or sector filter.
  /// Strictly fails closed: Never returns fabricated scheme cards.
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

    return [];
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

    return null;
  }
}