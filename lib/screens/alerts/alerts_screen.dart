import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AlertsScreen extends StatelessWidget {
  // Mirrors the bell icon's switch state on the Home screen.
  // true  -> show the alerts list (normal behavior)
  // false -> show the empty state, even if alerts exist
  final bool alertsEnabled;

  const AlertsScreen({super.key, this.alertsEnabled = true});

  // TODO: replace with a real stream from an AlertService, same pattern as BusService
  static final List<_AlertData> _alerts = [
    _AlertData(
      type: AlertType.warning,
      title: 'Route R3 Delayed',
      description: 'EDU-03 is running 15 minutes late due to traffic near Agrabad intersection.',
      time: '8 min ago',
      routeBadge: 'R3',
      isUnread: true,
    ),
    _AlertData(
      type: AlertType.info,
      title: 'Friday Schedule Today',
      description: 'Last departure from campus at 6:30 PM for all routes.',
      time: '25 min ago',
      isUnread: true,
    ),
    _AlertData(
      type: AlertType.success,
      title: 'EDU-01 Back on Track',
      description: 'Halishahar route is back on schedule after earlier congestion.',
      time: '1 hr ago',
      routeBadge: 'R1',
      routeColor: AppTheme.accentGreen,
    ),
    _AlertData(
      type: AlertType.info,
      title: 'New Stop Added',
      description: 'A pickup point added at Muradpur intersection for route R2.',
      time: '2 hr ago',
      routeBadge: 'R2',
      routeColor: AppTheme.accentBlue,
    ),
    _AlertData(
      type: AlertType.warning,
      title: 'Patenga Bus Full',
      description: 'EDU-03 is at capacity for the 8:00 AM run. Consider the next departure at 12:00 PM.',
      time: '3 hr ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final visibleAlerts = alertsEnabled ? _alerts : const <_AlertData>[];
    final unreadCount = visibleAlerts.where((a) => a.isUnread).length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alerts',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unreadCount > 0
                            ? '$unreadCount unread notification${unreadCount == 1 ? '' : 's'}'
                            : "You're all caught up",
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_active_outlined, color: AppTheme.accentGreen),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
            ),

            // Alerts List or Empty State
            Expanded(
              child: visibleAlerts.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  for (final alert in visibleAlerts)
                    _buildAlertCard(
                      type: alert.type,
                      title: alert.title,
                      description: alert.description,
                      time: alert.time,
                      routeBadge: alert.routeBadge,
                      routeColor: alert.routeColor,
                      isUnread: alert.isUnread,
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 40,
              color: AppTheme.accentGreen,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No alerts right now',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "We'll notify you when there's\nsomething new on your routes.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required AlertType type,
    required String title,
    required String description,
    required String time,
    String? routeBadge,
    Color? routeColor,
    bool isUnread = false,
  }) {
    Color typeColor;
    IconData typeIcon;

    switch (type) {
      case AlertType.warning:
        typeColor = AppTheme.accentYellow;
        typeIcon = Icons.warning_amber_rounded;
        break;
      case AlertType.info:
        typeColor = AppTheme.accentBlue;
        typeIcon = Icons.info_outline;
        break;
      case AlertType.success:
        typeColor = AppTheme.accentGreen;
        typeIcon = Icons.check_circle_outline;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: typeColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(typeIcon, color: typeColor, size: 20),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    if (routeBadge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (routeColor ?? typeColor).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          routeBadge,
                          style: TextStyle(
                            color: routeColor ?? typeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                )
              ],
            ),
          ),

          // Right Indicators (Unread dot and close button)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentBlue,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 8),
              const SizedBox(height: 8),
              Icon(Icons.close, color: Colors.grey.shade400, size: 16),
            ],
          )
        ],
      ),
    );
  }
}

class _AlertData {
  final AlertType type;
  final String title;
  final String description;
  final String time;
  final String? routeBadge;
  final Color? routeColor;
  final bool isUnread;

  _AlertData({
    required this.type,
    required this.title,
    required this.description,
    required this.time,
    this.routeBadge,
    this.routeColor,
    this.isUnread = false,
  });
}

enum AlertType { warning, info, success }