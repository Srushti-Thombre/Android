import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<void> checkAuthState() async {
    _setLoading(true);
    _clearError();
    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        // Load user from SQLite
        final userData = await _dbHelper.getUserById(firebaseUser.uid);
        if (userData != null) {
          _currentUser = UserModel.fromMap(firebaseUser.uid, userData);
        } else {
          // Create user in database if not exists
          final userModel = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName ?? 'User',
            createdAt: DateTime.now(),
          );
          
          await _dbHelper.insertOrUpdateUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName ?? 'User',
            photoUrl: firebaseUser.photoURL,
            createdAt: DateTime.now(),
          );
          
          _currentUser = userModel;
        }
      }
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error checking auth state: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Store user in SQLite
      if (_currentUser != null) {
        await _dbHelper.insertOrUpdateUser(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          displayName: _currentUser!.displayName,
          photoUrl: _currentUser!.photoUrl,
          monthlyIncome: _currentUser!.monthlyIncome,
          currency: _currentUser!.currency,
          budgetLimit: _currentUser!.budgetLimit,
          createdAt: _currentUser!.createdAt,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error during signup: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authService.login(
        email: email,
        password: password,
      );

      // Store/update user in SQLite
      if (_currentUser != null) {
        await _dbHelper.insertOrUpdateUser(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          displayName: _currentUser!.displayName,
          photoUrl: _currentUser!.photoUrl,
          monthlyIncome: _currentUser!.monthlyIncome,
          currency: _currentUser!.currency,
          budgetLimit: _currentUser!.budgetLimit,
          createdAt: _currentUser!.createdAt,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error during login: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> logout() async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.logout();
      _currentUser = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error during logout: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error resetting password: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          displayName: displayName,
          photoUrl: photoUrl,
        );

        // Update in SQLite
        await _dbHelper.updateUser(
          uid: _currentUser!.uid,
          displayName: displayName,
          photoUrl: photoUrl,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error updating profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
