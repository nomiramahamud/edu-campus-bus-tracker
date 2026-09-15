import 'package:flutter/material.dart';
import 'package:bus_app/theme/app_theme.dart';
import 'package:bus_app/services/route_service.dart';
import 'package:bus_app/models/route_model.dart';

/// Read-only guide listing every bus route and its stops.
/// Opened from Profile > Support > Route Guide.
class RouteGuideScreen extends StatelessWidget {
  const RouteGuideScreen({super.key});

  static const _pillColors = [
    AppTheme.accentGreen,
    AppTheme.accentBlue,
    AppTheme.accentYellow,
    AppTheme.accentPurple,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
        title: const Text('Route Guide'),
      ),
      body: StreamBuilder<List<RouteModel>>(
        stream: RouteService().getAllRoutes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Could not load routes.'));
          }

          final routes = snapshot.data ?? <RouteModel>[];

          if (routes.isEmpty) {
            return const Center(
              child: Text(
                'No routes available.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: routes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final route = routes[i];
              final color = _pillColors[i % _pillColors.length];

              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: Theme(
                  // Removes the default ExpansionTile divider lines so it
                  // matches the flat-card look used elsewhere on Profile.
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide.none,
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide.none,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.directions_bus, color: Colors.white, size: 18),
                    ),
                    title: Text(
                      route.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      '${route.stops.length} stops',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    children: [
                      for (int s = 0; s < route.stops.length; s++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${s + 1}',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  // Assumes route.stops is List<String>. If
                                  // your stops are objects (e.g. with a
                                  // .name field), change this to
                                  // route.stops[s].name.
                                  route.stops[s].toString(),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}