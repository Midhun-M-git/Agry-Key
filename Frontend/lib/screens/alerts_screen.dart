import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/alerts_service.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/notification_card.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<AppNotification> _alerts = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await AlertsService.fetchAlerts(alertType: _selectedCategory);
      if (mounted) {
        setState(() {
          _alerts = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markRead(AppNotification alert) async {
    if (alert.isRead) return;
    await AlertsService.markAsRead(alert.id);
    setState(() {
      final index = _alerts.indexWhere((a) => a.id == alert.id);
      if (index != -1) {
        _alerts[index] = AppNotification(
          id: alert.id,
          title: alert.title,
          message: alert.message,
          alertType: alert.alertType,
          isRead: true,
          createdAt: alert.createdAt,
          targetRoute: alert.targetRoute,
          metadata: alert.metadata,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),
      appBar: AppBar(
        title: const Text(
          "Farmer Alerts",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAlerts,
            tooltip: 'Refresh Alerts',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('All', null),
                _buildFilterChip('Weather', 'WEATHER'),
                _buildFilterChip('Market', 'MARKET'),
                _buildFilterChip('Schemes', 'SCHEME'),
                _buildFilterChip('Pest & Disease', 'DISEASE'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'Loading farmer alerts...')
                : _errorMessage != null && _alerts.isEmpty
                    ? AppErrorWidget(
                        message: _errorMessage!,
                        onRetry: _loadAlerts,
                      )
                    : _alerts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  'No alerts found',
                                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadAlerts,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: _alerts.length,
                              itemBuilder: (context, index) {
                                final alert = _alerts[index];
                                return NotificationCard(
                                  notification: alert,
                                  onTap: () => _markRead(alert),
                                  onDismiss: () {
                                    setState(() {
                                      _alerts.removeAt(index);
                                    });
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.green.shade100,
        checkmarkColor: Colors.green.shade900,
        labelStyle: TextStyle(
          color: isSelected ? Colors.green.shade900 : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) {
          setState(() {
            _selectedCategory = category;
          });
          _loadAlerts();
        },
      ),
    );
  }
}