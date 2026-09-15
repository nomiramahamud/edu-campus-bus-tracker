import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:bus_app/services/bus_service.dart';
import 'package:bus_app/services/schedule_service.dart';
import 'package:bus_app/models/bus_model.dart';
import 'package:bus_app/models/route_model.dart';
import 'package:bus_app/models/schedule_model.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onSeeMap;
  final void Function(String busId)? onBusTap;
  // Mirrors the same Push Notifications switch shown on the Profile
  // screen (comes from the logged-in user's Firestore doc via MainScreen).
  // Drives whether the bell icon looks "on" and, together with
  // [onSeeAlerts], what the Alerts tab shows once you get there.
  final bool notificationsEnabled;
  // Called when the bell icon is tapped. MainScreen wires this to switch
  // the bottom nav bar over to the Alerts tab, so this always lands on
  // the same AlertsScreen instance the tab bar shows -- not a separate
  // pushed page that could fall out of sync with the switch.
  final VoidCallback? onSeeAlerts;

  const HomeScreen({
    super.key,
    this.onSeeMap,
    this.onBusTap,
    this.notificationsEnabled = true,
    this.onSeeAlerts,
  });

  static const List<Color> _routeColors = [
    AppTheme.accentGreen,
    AppTheme.accentBlue,
    AppTheme.accentYellow,
    AppTheme.accentPurple,
  ];

  @override
  Widget build(BuildContext context) {
    final busService = BusService();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: StreamBuilder<List<RouteModel>>(
        stream: busService.getAllRoutes(),
        builder: (context, routeSnapshot) {
          final routesById = <String, RouteModel>{
            for (final r in routeSnapshot.data ?? <RouteModel>[]) r.routeId: r,
          };

          return StreamBuilder<List<BusModel>>(
            stream: busService.getActiveBuses(),
            builder: (context, busSnapshot) {
              if (busSnapshot.hasError) {
                debugPrint('=== HOME BUSES STREAM ERROR ===');
                debugPrint('${busSnapshot.error}');
              }

              final buses = busSnapshot.data ?? <BusModel>[];
              final isLoading =
                  busSnapshot.connectionState == ConnectionState.waiting;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, buses.length),
                    const SizedBox(height: 20),
                    _buildLiveBusesSection(
                      buses: buses,
                      routesById: routesById,
                      isLoading: isLoading,
                      hasError: busSnapshot.hasError,
                    ),
                    const SizedBox(height: 20),
                    _buildNextDeparturesSection(),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int activeBusCount) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi EDUvian 👋',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Find your bus,\nChattogram.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: notificationsEnabled
                      ? AppTheme.accentGreen.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    notificationsEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_off_outlined,
                    color: notificationsEnabled ? AppTheme.accentGreen : Colors.white,
                  ),
                  tooltip: notificationsEnabled ? 'Alerts on' : 'Alerts off',
                  onPressed: onSeeAlerts,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard(
                'Active',
                '$activeBusCount',
                Icons.directions_bus,
                AppTheme.accentGreen,
              ),
              const SizedBox(width: 12),
              _buildStatCard('On Time', '92%', Icons.trending_up, AppTheme.accentBlue),
              const SizedBox(width: 12),
              _buildStatCard('Riders', '1.2k', Icons.near_me, AppTheme.accentPurple),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveBusesSection({
    required List<BusModel> buses,
    required Map<String, RouteModel> routesById,
    required bool isLoading,
    required bool hasError,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LIVE BUSES',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              TextButton(
                onPressed: onSeeMap,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accentGreen,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  children: [
                    Text('See map'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (hasError)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Could not load live buses.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            )
          else if (buses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No active buses right now.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              )
            else
              Column(
                children: [
                  for (int i = 0; i < buses.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _buildBusCard(
                      bus: buses[i],
                      route: routesById[buses[i].routeId],
                      routeColor: _routeColors[i % _routeColors.length],
                    ),
                  ]
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildBusCard({
    required BusModel bus,
    required RouteModel? route,
    required Color routeColor,
  }) {
    final destination = route?.name.isNotEmpty == true ? route!.name : 'Unknown route';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onBusTap?.call(bus.busId),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: routeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.directions_bus, color: routeColor, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    bus.busId,
                    style: TextStyle(
                      color: routeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, color: AppTheme.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        bus.driverName.isNotEmpty ? bus.driverName : 'Driver TBD',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${bus.capacity} seats',
                  style: const TextStyle(
                    color: AppTheme.accentGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: AppTheme.accentGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // ---- NEXT DEPARTURES (replaces the old EDU Bus Pass promo card) ----
  //
  // Pulls the same schedule stream the Schedule screen uses, picks the
  // 2 soonest departures relative to the current time-of-day, and shows
  // them as compact cards. If fewer than 2 remain for today, wraps
  // around to the earliest departures of the (next) day so the section
  // never looks empty in the evening.

  Widget _buildNextDeparturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NEXT DEPARTURES',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<ScheduleModel>>(
            stream: ScheduleService().getSchedules(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                debugPrint('=== HOME DEPARTURES STREAM ERROR ===');
                debugPrint('${snapshot.error}');
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Could not load departures.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              final all = snapshot.data ?? <ScheduleModel>[];
              final upNext = _nextDepartures(all, count: 2);

              if (upNext.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No upcoming departures.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  for (int i = 0; i < upNext.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _buildDepartureCard(upNext[i]),
                  ]
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Returns the [count] soonest schedules by time-of-day, starting from
  // now. Wraps around to the start of the list (earliest times) if not
  // enough departures remain later today.
  List<ScheduleModel> _nextDepartures(List<ScheduleModel> all, {int count = 2}) {
    if (all.isEmpty) return const [];

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;

    final withMinutes = <MapEntry<int, ScheduleModel>>[];
    for (final s in all) {
      final minutes = _minutesSinceMidnight(s.time);
      if (minutes != null) withMinutes.add(MapEntry(minutes, s));
    }
    withMinutes.sort((a, b) => a.key.compareTo(b.key));

    final upcoming = withMinutes.where((e) => e.key >= nowMinutes).toList();
    final result = <ScheduleModel>[];
    result.addAll(upcoming.take(count).map((e) => e.value));

    // Not enough left today -- wrap around to tomorrow's earliest ones.
    if (result.length < count) {
      final remaining = count - result.length;
      final alreadyUsed = result.toSet();
      for (final e in withMinutes) {
        if (result.length >= count) break;
        if (!alreadyUsed.contains(e.value)) result.add(e.value);
      }
      // (loop naturally stops once count is reached or list is exhausted)
      if (remaining < 0) {} // no-op, keeps analyzer quiet about unused var
    }

    return result.take(count).toList();
  }

  int? _minutesSinceMidnight(String raw) {
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

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

  Color _routeColorFor(String routeId) {
    switch (routeId) {
      case 'towards':
        return AppTheme.accentGreen;
      case 'from':
        return AppTheme.accentBlue;
      case 'laguna':
        return AppTheme.accentYellow;
      default:
        return AppTheme.accentPurple;
    }
  }

  Widget _buildDepartureCard(ScheduleModel s) {
    final routeColor = _routeColorFor(s.routeId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: routeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule, color: routeColor, size: 18),
                const SizedBox(height: 4),
                Text(
                  _formatTime(s.time),
                  style: TextStyle(
                    color: routeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.routeName.isNotEmpty ? s.routeName : 'Unknown route',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.directions_bus_outlined,
                        color: AppTheme.textSecondary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      s.busName.isNotEmpty ? s.busName : 'Bus TBD',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: s.isDelayed
                  ? AppTheme.accentYellow.withValues(alpha: 0.1)
                  : AppTheme.accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
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
        ],
      ),
    );
  }
}