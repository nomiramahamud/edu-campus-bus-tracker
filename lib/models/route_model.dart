class RouteModel {
  final String routeId;
  final String name;
  final List<String> stops;
  final List<String> activeBusIds;

  RouteModel({
    required this.routeId,
    required this.name,
    this.stops = const [],
    this.activeBusIds = const [],
  });

  factory RouteModel.fromMap(String id, Map<String, dynamic> map) {
    return RouteModel(
      routeId: id,
      name: map['name'] ?? '',
      stops: List<String>.from(map['stops'] ?? []),
      activeBusIds: List<String>.from(map['activeBusIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'stops': stops,
      'activeBusIds': activeBusIds,
    };
  }
}