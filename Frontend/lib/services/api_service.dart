import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

class ApiService {

  // LOGIN
  static Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/v1/auth/login',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "phone_number": phoneNumber,
          "password": password,
        }),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      return {
        "success": false,
        "message": "Login failed",
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  // REGISTER
  static Future<Map<String, dynamic>> register({
    required String phoneNumber,
    required String password,
    required String fullName,
    required String role,
    required String preferredLanguage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/v1/auth/register',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "phone_number": phoneNumber,
          "password": password,
          "full_name": fullName,
          "role": role,
          "preferred_language": preferredLanguage,
        }),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      return {
        "success": false,
        "message": "Registration failed",
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  // GEO LANGUAGE DETECTION
  static Future<Map<String, dynamic>> detectLanguage({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/v1/geo/detect-language',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        "success": false,
        "message": "Location detection failed",
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  // UI TRANSLATIONS
  static Future<Map<String, dynamic>> getTranslations(
    String languageCode,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/v1/i18n/translations?lang=$languageCode',
        ),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        "success": false,
        "message": "Translation fetch failed",
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  // FARM ONBOARDING
  static Future<Map<String, dynamic>> submitFarmOnboarding({
    required String token,
    required Map<String, dynamic> farmData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/v1/onboarding/farm',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(farmData),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      return {
        "success": false,
        "message": "Farm onboarding failed",
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
}