import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import 'database_helper.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    try {
      //final doc = await _firestore.collection(usersCollection).doc(user.uid).get();
      //if (doc.exists) {
      //  return UserModel.fromMap(user.uid, doc.data() as Map<String, dynamic>);
      //}
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw FirebaseAuthException(code: 'user-not-found');

      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      //await _firestore.collection(usersCollection).doc(user.uid).set(userModel.toMap());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'user-not-found');
      }

      // Fetch existing user from database to preserve createdAt
      try {
        final dbHelper = DatabaseHelper();
        final existingUser = await dbHelper.getUserById(user.uid);
        final createdAt =
            existingUser != null && existingUser['createdAt'] != null
            ? DateTime.parse(existingUser['createdAt'])
            : DateTime.now();

        return UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'User',
          createdAt: createdAt,
        );
      } catch (e) {
        // Fallback if database query fails
        return UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'User',
          createdAt: DateTime.now(),
        );
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw FirebaseAuthException(code: 'user-not-found');

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      final updateData = <String, dynamic>{};
      if (displayName != null) updateData['displayName'] = displayName;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      updateData['updatedAt'] = DateTime.now().toIso8601String();

      if (updateData.isNotEmpty) {
        //await _firestore.collection(usersCollection).doc(user.uid).update(updateData);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak';
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'invalid-email':
        return 'The email address is invalid';
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-disabled':
        return 'This user account has been disabled';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection';
      default:
        return e.message ?? 'An error occurred';
    }
  }
}
