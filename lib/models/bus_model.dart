class BusModel {
  final String busId;
  final String routeId;
  final String driverName;
  final int capacity;
  final bool isActive;

  BusModel({
    required this.busId,
    required this.routeId,
    this.driverName = '',
    this.capacity = 40,
    this.isActive = true,
  });

  factory BusModel.fromMap(String id, Map<String, dynamic> map) {
    return BusModel(
      busId: id,
      routeId: map['routeId'] ?? '',
      driverName: map['driverName'] ?? '',
      capacity: map['capacity'] ?? 40,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'routeId': routeId,
      'driverName': driverName,
      'capacity': capacity,
      'isActive': isActive,
    };
  }
}