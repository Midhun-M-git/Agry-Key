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

    // Not authenticated or network unavailable — return empty list
    return _getEmptyAlerts();
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

  // No fallback data — alerts must come from the real backend.
  // Returns empty list if not authenticated or network unavailable.
  static List<AppNotification> _getEmptyAlerts() => [];
}
