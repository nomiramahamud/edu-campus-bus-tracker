import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bus_app/models/user_model.dart';

class UserService {
  final _usersRef = FirebaseFirestore.instance.collection('users');

  // Live stream of the user's profile (used by ProfileScreen's StreamBuilder)
  //
  // FIX: previously this mapped doc.data() ?? {} straight into
  // UserModel.fromMap, so a missing/deleted user document silently
  // produced a model full of defaults (empty name, 0 trips, etc.)
  // instead of surfacing an error. Now a missing document throws,
  // which flows into the StreamBuilder's `snapshot.hasError` branch
  // in ProfileScreen so the problem is visible instead of hidden.
  Stream<UserModel> getUserStream(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        throw StateError(
          'User profile not found for uid: $uid. '
              'The Firestore users/$uid document is missing.',
        );
      }
      return UserModel.fromMap(doc.id, doc.data()!);
    });
  }

  // One-time fetch (useful outside of streaming contexts)
  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _usersRef.doc(uid).update(data);
  }

  Future<void> toggleNotifications(String uid, bool enabled) async {
    await _usersRef.doc(uid).update({'notificationsEnabled': enabled});
  }

  Future<void> updateHomeStop(String uid, String homeStop) async {
    await _usersRef.doc(uid).update({'homeStop': homeStop});
  }

  /// Adds a route to the user's saved list. Uses arrayUnion so it's safe
  /// to call even if the route is already saved — no duplicates.
  Future<void> addSavedRoute(String uid, String routeId) async {
    await _usersRef.doc(uid).update({
      'savedRouteIds': FieldValue.arrayUnion([routeId]),
    });
  }

  /// Removes a route from the user's saved list.
  Future<void> removeSavedRoute(String uid, String routeId) async {
    await _usersRef.doc(uid).update({
      'savedRouteIds': FieldValue.arrayRemove([routeId]),
    });
  }

  /// Call this from the Tracker screen's "End Trip" action.
  Future<void> incrementTripCompleted(String uid) async {
    await _usersRef.doc(uid).update({
      'totalTrips': FieldValue.increment(1),
    });
  }

  /// Creates a user profile document if one doesn't already exist.
  /// Useful as a one-off repair tool for accounts (like ones created
  /// before the current signUp() flow) whose users/{uid} doc is missing.
  Future<void> ensureUserDocExists({
    required String uid,
    required String name,
    required String email,
    required String studentId,
  }) async {
    final doc = await _usersRef.doc(uid).get();
    if (doc.exists) return;

    await _usersRef.doc(uid).set({
      'name': name,
      'email': email,
      'department': '',
      'year': '',
      'studentId': studentId,
      'totalTrips': 0,
      'tripsThisWeek': 0,
      'notificationsEnabled': true,
      'homeStop': '',
      'savedRouteIds': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Deprecated: savedRoutesCount is now derived from savedRouteIds.length
  // directly in UserModel, so nothing needs to call this anymore. Left in
  // place only in case older code still references it — safe to delete
  // once you've confirmed nothing does.
  Future<void> incrementSavedRoutesCount(String uid, int delta) async {
    await _usersRef.doc(uid).update({
      'savedRoutesCount': FieldValue.increment(delta),
    });
  }
}