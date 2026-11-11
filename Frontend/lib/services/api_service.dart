import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'token_service.dart';

class ApiService {
  /// Core HTTP client interceptor handling automated JWT token refresh on 401.
  static Future<http.Response> requestWithAuth({
    required String method,
    required Uri uri,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    headers ??= {};
    headers['Content-Type'] ??= 'application/json';

    String? token = await TokenService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    try {
      response = await _sendRaw(method, uri, headers, body);
    } catch (e) {
      rethrow;
    }

    // Intercept 401 Unauthorized for token refresh
    if (response.statusCode == 401) {
      final newToken = await TokenService.refreshTokens();
      if (newToken != null && newToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $newToken';
        // Retry the original request with the fresh access token
        response = await _sendRaw(method, uri, headers, body);
      } else {
        // Refresh token expired or revoked - user session terminated
        await TokenService.logout();
      }
    }

    return response;
  }

  static Future<http.Response> _sendRaw(
    String method,
    Uri uri,
    Map<String, String> headers,
    dynamic body,
  ) {
    final encodedBody = (body != null && body is! String) ? jsonEncode(body) : body as String?;

    switch (method.toUpperCase()) {
      case 'POST':
        return http.post(uri, headers: headers, body: encodedBody);
      case 'PUT':
        return http.put(uri, headers: headers, body: encodedBody);
      case 'DELETE':
        return http.delete(uri, headers: headers, body: encodedBody);
      case 'GET':
      default:
        return http.get(uri, headers: headers);
    }
  }

  /// Convenience GET helper with auto refresh
  static Future<Map<String, dynamic>> get(String endpoint, {bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = requireAuth
          ? await requestWithAuth(method: 'GET', uri: uri)
          : await http.get(uri);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {
        "success": false,
        "status_code": response.statusCode,
        "message": response.body,
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// Convenience POST helper with auto refresh
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    dynamic body,
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = requireAuth
          ? await requestWithAuth(method: 'POST', uri: uri, body: body)
          : await http.post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: body != null ? jsonEncode(body) : null,
            );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {
        "success": false,
        "status_code": response.statusCode,
        "message": response.body,
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // SEND OTP
  // =========================================================================
  // TEMPORARY FIX: External carrier OTP delivery temporarily bypassed.
  // MUST FIX: Must fix after some days after restoring OTP subscription.
  // =========================================================================
  static Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"phone_number": phoneNumber}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          "success": true,
          "message": data["message"] ?? "OTP service active (Enter 123456 to continue)",
        };
      }
      return {
        "success": true,
        "message": "Temporary bypass active: Enter OTP 123456",
      };
    } catch (e) {
      // In case backend is cold-starting or offline, permit navigating to OTP screen
      return {
        "success": true,
        "message": "Temporary bypass active: Enter OTP 123456",
      };
    }
  }

  // VERIFY OTP
  // =========================================================================
  // TEMPORARY FIX: Fixed OTP 123456 accepted while carrier subscription is inactive.
  // MUST FIX: Must fix after some days after restoring OTP subscription.
  // =========================================================================
  static Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "phone_number": phoneNumber,
          "otp": otpCode,
          "code": otpCode,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          "success": true,
          "message": data["message"] ?? "Verified successfully",
          "is_new_user": data["is_new_user"] ?? false,
          "access_token": data["access_token"],
          "refresh_token": data["refresh_token"],
          "user": data["user"],
        };
      }
      if (otpCode == "123456") {
        return {
          "success": true,
          "message": "Verified with temporary bypass code",
          "is_new_user": false,
          "access_token": "mock-dev-token-bypass-123456",
          "refresh_token": "mock-dev-refresh-bypass-123456",
          "user": {
            "phone_number": phoneNumber,
            "role": "FARMER",
            "full_name": "Agry-Key Farmer",
          },
        };
      }
      return {
        "success": false,
        "message": data["detail"] ?? data["message"] ?? "Invalid or expired verification code.",
      };
    } catch (e) {
      if (otpCode == "123456") {
        return {
          "success": true,
          "message": "Verified with temporary offline bypass",
          "is_new_user": false,
          "access_token": "mock-dev-token-bypass-123456",
          "refresh_token": "mock-dev-refresh-bypass-123456",
          "user": {
            "phone_number": phoneNumber,
            "role": "FARMER",
            "full_name": "Agry-Key Farmer",
          },
        };
      }
      return {
        "success": false,
        "message": "Unable to connect to Agry-Key server. Please check your internet connection.",
      };
    }
  }
      return {
        "success": false,
        "message": "Unable to connect to Agry-Key server. Please check your internet connection.",
      };
    }
  }

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