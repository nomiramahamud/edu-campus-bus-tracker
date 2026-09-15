import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bus_app/models/user_model.dart';

class UserService {
  final _usersRef = FirebaseFirestore.instance.collection('users');

  Stream<UserModel> getUserStream(String uid) {
    return _usersRef.doc(uid).snapshots().map(
            (doc) => UserModel.fromMap(doc.id, doc.data() ?? {}));
  }

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
}