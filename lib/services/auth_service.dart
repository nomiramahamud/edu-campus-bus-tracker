import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Thrown when a signup attempt uses a student ID that's already
/// tied to another account.
class StudentIdAlreadyInUseException implements Exception {
  final String message;
  StudentIdAlreadyInUseException([
    this.message = 'This student ID is already registered.',
  ]);

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Fields collected directly from the signup form: name, email,
  // studentId, department, year.
  //
  // totalTrips, notificationsEnabled, homeStop, and savedRouteIds are
  // NOT collected at signup — they're managed later from the Profile
  // screen (toggling notifications, setting a home stop, saving
  // routes, completing trips). They're still written here with sane
  // defaults so the users/{uid} document is complete the instant the
  // account is created. Without this, UserService.getUserStream()
  // would hit a doc missing those fields and throw, since it now
  // requires the doc to exist and be fully formed rather than
  // silently defaulting on read.
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String studentId,
    required String department,
    required String year,
  }) async {
    final normalizedStudentId = studentId.trim();

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) return null;

    try {
      // Reserve the studentId and write the profile doc in ONE
      // transaction. Firestore transactions serialize on the document
      // they read (studentIds/{studentId}), so if two signups race for
      // the same ID at the same instant, only one commits — the other
      // retries, sees the doc now exists, and throws below. This is
      // what actually makes "one account per student ID" hold up under
      // concurrency, not just a plain query-then-write (which has a
      // race window).
      await _firestore.runTransaction((transaction) async {
        final studentIdRef =
        _firestore.collection('studentIds').doc(normalizedStudentId);
        final studentIdSnap = await transaction.get(studentIdRef);

        if (studentIdSnap.exists) {
          throw StudentIdAlreadyInUseException();
        }

        transaction.set(studentIdRef, {
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.set(_firestore.collection('users').doc(user.uid), {
          // Collected at signup
          'name': name,
          'email': email,
          'studentId': normalizedStudentId,
          'department': department,
          'year': year,
          // Managed later via the Profile screen — written here only
          // as defaults so the document is never missing a field.
          'totalTrips': 0,
          'tripsThisWeek': 0,
          'notificationsEnabled': true,
          'homeStop': '',
          'savedRouteIds': <String>[],
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      // Something failed after the Auth account already exists — most
      // likely the studentId was taken. Undo the Auth account so we
      // don't leave a login with no profile behind it, then let the
      // caller know why.
      // ignore: avoid_print
      print('❌ Signup transaction failed, rolling back auth user: $e');
      await user.delete().catchError((_) {});
      rethrow;
    }

    return user;
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}