import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:bus_app/services/schedule_service.dart';
import 'package:bus_app/models/schedule_model.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _selectedFilter = 'All';

  // Filters now match the two directions in the real timetable, plus
  // the Laguna shuttle, instead of the old Halishahar/Agrabad/Patenga
  // labels which don't exist in the real data.
  static const List<String> _filters = [
    'All',
    'Towards University',
    'From University',
    'Laguna Service',
  ];

  // Maps a filter chip label to the routeId stored on each schedule doc.
  static const Map<String, String> _filterToRouteId = {
    'Towards University': 'towards',
    'From University': 'from',
    'Laguna Service': 'laguna',
  };

  static const Map<String, String> _periodLabels = {
    'morning': 'MORNING',
    'mid_morning': 'MID-MORNING',
    'afternoon': 'AFTERNOON',
    'evening': 'EVENING',
    'laguna': 'LAGUNA SERVICE (ALL DAY)',
  };

  static const List<String> _periodOrder = [
    'morning',
    'mid_morning',
    'afternoon',
    'evening',
    'laguna',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'Schedule',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  for (int i = 0; i < _filters.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _selectedFilter = _filters[i]),
                      child: _buildFilterChip(
                        _filters[i],
                        _colorForFilter(_filters[i]),
                        isSelected: _selectedFilter == _filters[i],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<ScheduleModel>>(
                stream: ScheduleService().getSchedules(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    debugPrint('=== SCHEDULE STREAM ERROR ===');
                    debugPrint('${snapshot.error}');
                    return Center(
                      child: Text(
                        'Could not load schedule.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    );
                  }

                  final all = snapshot.data ?? <ScheduleModel>[];
                  final filtered = _selectedFilter == 'All'
                      ? all
                      : all
                      .where((s) =>
                  s.routeId == _filterToRouteId[_selectedFilter])
                      .toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No schedules found.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    );
                  }

                  // Group by period, preserving fixed period order
                  final grouped = <String, List<ScheduleModel>>{};
                  for (final s in filtered) {
                    grouped.putIfAbsent(s.period, () => []).add(s);
                  }

                  final orderedPeriods = _periodOrder.where(grouped.containsKey).toList();
                  // Include any period not in our known list at the end (fallback safety)
                  for (final p in grouped.keys) {
                    if (!orderedPeriods.contains(p)) orderedPeriods.add(p);
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      for (final period in orderedPeriods) ...[
                        _buildSectionHeader(_periodLabels[period] ?? period.toUpperCase()),
                        for (final s in grouped[period]!)
                          _buildScheduleCard(s),
                        const SizedBox(height: 10),
                      ],
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Color? _colorForFilter(String label) {
    switch (label) {
      case 'Towards University':
        return AppTheme.accentGreen;
      case 'From University':
        return AppTheme.accentBlue;
      case 'Laguna Service':
        return AppTheme.accentYellow;
      default:
        return null;
    }
  }

  // Schedule docs store time as 24-hour "HH:mm" (so Firestore's
  // orderBy('time') sorts correctly across the AM/PM boundary).
  // This converts it back to a friendly 12-hour label for display.
  String _formatTime(String raw) {
    final parts = raw.split(':');
    if (parts.length != 2) return raw;
    final hour = int.tryParse(parts[0]);
    final minute = parts[1];
    if (hour == null) return raw;
    final period = hour >= 12 ? 'PM' : 'AM';
    var displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;
    return '$displayHour:$minute $period';
  }

  Widget _buildFilterChip(String label, Color? color, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isSelected)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          if (color != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleModel s) {
    final routeColor = s.routeId == 'towards'
        ? AppTheme.accentGreen
        : s.routeId == 'from'
        ? AppTheme.accentBlue
        : s.routeId == 'laguna'
        ? AppTheme.accentYellow
        : AppTheme.accentPurple;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: routeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(s.time),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                width: 1,
                color: Colors.grey.shade200,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    s.routeName.isNotEmpty ? s.routeName : 'Unknown route',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.busName,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: s.isDelayed
                      ? AppTheme.accentYellow.withValues(alpha: 0.1)
                      : AppTheme.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  s.isDelayed ? 'Delayed' : 'On Time',
                  style: TextStyle(
                    color: s.isDelayed ? AppTheme.accentYellow : AppTheme.accentGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}