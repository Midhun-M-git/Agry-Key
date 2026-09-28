import 'dart:convert';
import '../core/api_config.dart';
import '../models/notification.dart';
import 'api_service.dart';

class AlertsService {
  /// Fetches notifications and agricultural alerts for the logged-in user.
  static Future<List<AppNotification>> fetchAlerts({
    bool unreadOnly = false,
    String? alertType,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (unreadOnly) queryParams['unread_only'] = 'true';
      if (alertType != null) queryParams['alert_type'] = alertType;

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await ApiService.requestWithAuth(method: 'GET', uri: uri);

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((item) => AppNotification.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    // Fallback alerts for initial or offline state
    return _getFallbackAlerts();
  }

  /// Marks a specific notification as read.
  static Future<bool> markAsRead(int notificationId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications/mark-read/$notificationId');
      final response = await ApiService.requestWithAuth(method: 'POST', uri: uri);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Updates user alert subscriptions across weather, market, schemes, disease, etc.
  static Future<bool> subscribeToAlerts(List<String> alertTypes) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications/subscribe');
      final response = await ApiService.requestWithAuth(
        method: 'POST',
        uri: uri,
        body: {'alert_types': alertTypes},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static List<AppNotification> _getFallbackAlerts() {
    return [
      AppNotification(
        id: 101,
        title: 'Weather Advisory: Heavy Rain Expected',
        message: 'Monsoon showers anticipated in Palakkad over the next 48 hours. Ensure paddy field drainage channels are clear.',
        alertType: 'WEATHER',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 102,
        title: 'Agmarknet Price Alert: Paddy Up by 4.2%',
        message: 'Palakkad APMC mandi price for Matta Paddy reached ₹2,820/quintal today morning.',
        alertType: 'MARKET',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 103,
        title: 'Government Subsidy Notice: PM-KISAN 17th Instalment',
        message: 'Verify e-KYC and land seeding records before the seasonal deadline to receive DBT credit.',
        alertType: 'SCHEME',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: 104,
        title: 'Pest Advisory: Stem Borer Preventive Measure',
        message: 'KVK recommends installing light traps and monitoring lower tillers for early stem borer detection.',
        alertType: 'DISEASE',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}
