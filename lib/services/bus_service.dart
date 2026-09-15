import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bus_app/models/bus_model.dart';
import 'package:bus_app/models/route_model.dart';

class BusService {
  final _busesRef = FirebaseFirestore.instance.collection('buses');
  final _routesRef = FirebaseFirestore.instance.collection('routes');

  // Stream of all active buses (for the "Live Buses" list on Home)
  Stream<List<BusModel>> getActiveBuses() {
    return _busesRef
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => BusModel.fromMap(doc.id, doc.data()))
        .toList());
  }

  Stream<List<RouteModel>> getAllRoutes() {
    return _routesRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => RouteModel.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<RouteModel?> getRouteById(String routeId) async {
    final doc = await _routesRef.doc(routeId).get();
    if (!doc.exists) return null;
    return RouteModel.fromMap(doc.id, doc.data()!);
  }

  Future<BusModel?> getBusById(String busId) async {
    final doc = await _busesRef.doc(busId).get();
    if (!doc.exists) return null;
    return BusModel.fromMap(doc.id, doc.data()!);
  }

  // Quick counts for the home screen stat cards
  Future<int> getActiveBusCount() async {
    final snapshot = await _busesRef.where('isActive', isEqualTo: true).get();
    return snapshot.docs.length;
  }
}