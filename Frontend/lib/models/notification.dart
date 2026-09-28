class AppNotification {
  final int id;
  final String title;
  final String message;
  final String alertType;
  final bool isRead;
  final DateTime? createdAt;
  final String? targetRoute;
  final Map<String, dynamic>? metadata;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.alertType = 'INFO',
    this.isRead = false,
    this.createdAt,
    this.targetRoute,
    this.metadata,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      alertType: json['alert_type'] as String? ?? 'INFO',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      targetRoute: json['target_route'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'alert_type': alertType,
      'is_read': isRead,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (targetRoute != null) 'target_route': targetRoute,
      if (metadata != null) 'metadata': metadata,
    };
  }
}
