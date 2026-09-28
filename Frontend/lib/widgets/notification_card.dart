import 'package:flutter/material.dart';
import '../models/notification.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  IconData _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'WEATHER':
        return Icons.cloud_outlined;
      case 'MARKET':
        return Icons.trending_up;
      case 'SCHEME':
        return Icons.account_balance_outlined;
      case 'DISEASE':
        return Icons.healing_outlined;
      case 'ORDER':
        return Icons.shopping_bag_outlined;
      case 'ALERT':
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toUpperCase()) {
      case 'WEATHER':
        return Colors.blue;
      case 'MARKET':
        return Colors.green;
      case 'SCHEME':
        return Colors.purple;
      case 'DISEASE':
        return Colors.red;
      case 'ORDER':
        return Colors.teal;
      case 'ALERT':
      default:
        return Colors.amber.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getColorForType(notification.alertType);

    return Dismissible(
      key: Key('notif_${notification.id}'),
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        color: Colors.red.shade400,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : Colors.green.shade50.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead ? Colors.grey.shade200 : Colors.green.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: typeColor.withOpacity(0.12),
            child: Icon(_getIconForType(notification.alertType), color: typeColor, size: 22),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (notification.createdAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatDate(notification.createdAt!),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ],
          ),
          trailing: !notification.isRead
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
