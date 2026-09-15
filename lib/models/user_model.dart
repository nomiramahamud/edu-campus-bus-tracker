// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String studentId;
  final String department;
  final String year;
  final int totalTrips;
  final int tripsThisWeek;
  final bool notificationsEnabled;
  final String homeStop;
  final List<String> savedRouteIds;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.studentId,
    required this.department,
    required this.year,
    required this.totalTrips,
    required this.tripsThisWeek,
    required this.notificationsEnabled,
    required this.homeStop,
    required this.savedRouteIds,
  });

  /// Derived, not stored — matches the comment in UserService about
  /// savedRoutesCount being deprecated in favor of this.
  int get savedRoutesCount => savedRouteIds.length;

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      studentId: data['studentId'] ?? '',
      department: data['department'] ?? '',
      year: data['year'] ?? '',
      totalTrips: data['totalTrips'] ?? 0,
      tripsThisWeek: data['tripsThisWeek'] ?? 0,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      homeStop: data['homeStop'] ?? '',
      savedRouteIds: List<String>.from(data['savedRouteIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'studentId': studentId,
      'department': department,
      'year': year,
      'totalTrips': totalTrips,
      'tripsThisWeek': tripsThisWeek,
      'notificationsEnabled': notificationsEnabled,
      'homeStop': homeStop,
      'savedRouteIds': savedRouteIds,
    };
  }
}