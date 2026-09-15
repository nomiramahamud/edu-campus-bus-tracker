import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../theme/app_theme.dart';
import 'package:bus_app/services/location_service.dart';
import 'package:bus_app/services/bus_service.dart';
import 'package:bus_app/models/bus_model.dart';
import 'package:bus_app/models/route_model.dart';

class TrackerScreen extends StatefulWidget {
  final String? focusBusId;

  const TrackerScreen({super.key, this.focusBusId});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final LocationService _locationService = LocationService();
  final BusService _busService = BusService();
  GoogleMapController? _mapController;

  // Tracks the last busId we already animated to, so we don't
  // re-animate on every rebuild/stream tick.
  String? _lastFocusedBusId;

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(22.3569, 91.7832),
    zoom: 13,
  );

  static const List<double> _markerHues = [
    BitmapDescriptor.hueGreen,
    BitmapDescriptor.hueAzure,
    BitmapDescriptor.hueYellow,
    BitmapDescriptor.hueViolet,
  ];

  // Same palette/order Home uses, so a given bus renders in the same
  // color on both screens.
  static const List<Color> _routeColors = [
    AppTheme.accentGreen,
    AppTheme.accentBlue,
    AppTheme.accentYellow,
    AppTheme.accentPurple,
  ];

  @override
  void didUpdateWidget(covariant TrackerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // a new bus was tapped on Home while already on this screen —
    // allow re-focusing even if it's the same id as before
    if (widget.focusBusId != oldWidget.focusBusId) {
      _lastFocusedBusId = null;
    }
  }

  void _maybeFocusOnBus(Map<String, dynamic> locations) {
    final targetId = widget.focusBusId;
    if (targetId == null || targetId == _lastFocusedBusId) return;
    if (_mapController == null) return;

    final locRaw = locations[targetId];
    if (locRaw == null) return; // that bus has no live location yet

    final loc = Map<String, dynamic>.from(locRaw as Map);
    final lat = (loc['lat'] as num?)?.toDouble();
    final lng = (loc['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return;

    _lastFocusedBusId = targetId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: 16),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<BusModel>>(
        stream: _busService.getActiveBuses(),
        builder: (context, busSnapshot) {
          final buses = busSnapshot.data ?? <BusModel>[];

          return StreamBuilder<List<RouteModel>>(
            stream: _busService.getAllRoutes(),
            builder: (context, routeSnapshot) {
              final routesById = <String, RouteModel>{
                for (final r in routeSnapshot.data ?? <RouteModel>[]) r.routeId: r,
              };

              return StreamBuilder<Map<String, dynamic>>(
                stream: _locationService.streamAllBusLocations(),
                builder: (context, locationSnapshot) {
                  if (locationSnapshot.hasError) {
                    debugPrint('=== TRACKER LOCATIONS ERROR ===');
                    debugPrint('${locationSnapshot.error}');
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Could not load live locations.\n${locationSnapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    );
                  }

                  final locations = locationSnapshot.data ?? <String, dynamic>{};
                  final markers = _buildMarkers(buses, routesById, locations);

                  // try to focus on the requested bus every time new
                  // location data arrives, until it succeeds once
                  _maybeFocusOnBus(locations);

                  return Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: _initialCamera,
                        markers: markers,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        onMapCreated: (controller) {
                          _mapController = controller;
                          _maybeFocusOnBus(locations);
                        },
                      ),

                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('Halishahar', AppTheme.accentGreen),
                                const SizedBox(width: 8),
                                _buildFilterChip('Agrabad', AppTheme.accentBlue),
                                const SizedBox(width: 8),
                                _buildFilterChip('Patenga', AppTheme.accentYellow),
                                const SizedBox(width: 8),
                                _buildFilterChip('LIVE', Colors.green, isLive: true),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.bottomCenter,
                        child: _buildBottomSheet(buses, locations, routesById),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Set<Marker> _buildMarkers(
      List<BusModel> buses,
      Map<String, RouteModel> routesById,
      Map<String, dynamic> locations,
      ) {
    final markers = <Marker>{};

    for (int i = 0; i < buses.length; i++) {
      final bus = buses[i];
      final locRaw = locations[bus.busId];
      if (locRaw == null) continue;

      final loc = Map<String, dynamic>.from(locRaw as Map);
      final lat = (loc['lat'] as num?)?.toDouble();
      final lng = (loc['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;

      final route = routesById[bus.routeId];
      final hue = _markerHues[i % _markerHues.length];

      markers.add(
        Marker(
          markerId: MarkerId(bus.busId),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: bus.busId,
            snippet: route?.name.isNotEmpty == true
                ? '${route!.name} · ${bus.driverName}'
                : bus.driverName,
          ),
        ),
      );
    }

    return markers;
  }

  Widget _buildFilterChip(String label, Color color, {bool isLive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(
      List<BusModel> buses,
      Map<String, dynamic> locations,
      Map<String, RouteModel> routesById,
      ) {
    final trackedBuses = buses.where((b) => locations[b.busId] != null).toList();

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'See all buses',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.keyboard_arrow_up, color: AppTheme.textSecondary),
              ],
            ),
            const SizedBox(height: 20),

            // Section header — same label/style as Home's Live Buses section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'LIVE BUSES',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (trackedBuses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No buses are broadcasting live location yet.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              )
            else
              Column(
                children: [
                  for (int i = 0; i < trackedBuses.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _buildBusCard(
                      bus: trackedBuses[i],
                      route: routesById[trackedBuses[i].routeId],
                      routeColor: _routeColors[i % _routeColors.length],
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Mirrors HomeScreen._buildBusCard exactly, so a bus looks identical
  // whether you're looking at it from Home or Tracker. Tap re-centers
  // the map on this bus instead of navigating away.
  Widget _buildBusCard({
    required BusModel bus,
    required RouteModel? route,
    required Color routeColor,
  }) {
    final destination = route?.name.isNotEmpty == true ? route!.name : 'Unknown route';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          _lastFocusedBusId = null; // allow re-focusing on manual tap too
        });
        _maybeFocusOnBusById(bus.busId);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
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

  // used when tapping a card directly inside the bottom sheet
  Future<void> _maybeFocusOnBusById(String busId) async {
    final snapshot = await _locationService.streamAllBusLocations().first;
    final locRaw = snapshot[busId];
    if (locRaw == null || _mapController == null) return;

    final loc = Map<String, dynamic>.from(locRaw as Map);
    final lat = (loc['lat'] as num?)?.toDouble();
    final lng = (loc['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return;

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 16),
      ),
    );
  }
}