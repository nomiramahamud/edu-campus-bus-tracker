import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bus_app/models/route_model.dart';

class RouteService {
  final _routesRef = FirebaseFirestore.instance.collection('routes');

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

  // Get user's saved routes (subcollection under users/{uid}/savedRoutes)
  Stream<List<RouteModel>> getSavedRoutes(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('savedRoutes')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RouteModel.fromMap(doc.id, doc.data()))
        .toList());
  }

  // Save a route to user's savedRoutes
  Future<void> saveRoute(String uid, RouteModel route) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('savedRoutes')
        .doc(route.routeId)
        .set(route.toMap());
  }

  // Remove a saved route
  Future<void> removeSavedRoute(String uid, String routeId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('savedRoutes')
        .doc(routeId)
        .delete();
  }
}