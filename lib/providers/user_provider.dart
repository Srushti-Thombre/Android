import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserProfile() async {
    _setLoading(true);
    _clearError();
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // Load user from SQLite
        final userData = await _dbHelper.getUserById(currentUser.uid);
        if (userData != null) {
          _user = UserModel.fromMap(currentUser.uid, userData);
        } else {
          // Create user if not exists
          _user = UserModel(
            uid: currentUser.uid,
            email: currentUser.email ?? '',
            displayName: currentUser.displayName ?? 'User',
            photoUrl: currentUser.photoURL,
            createdAt: DateTime.now(),
          );
          
          await _dbHelper.insertOrUpdateUser(
            uid: currentUser.uid,
            email: currentUser.email ?? '',
            displayName: currentUser.displayName ?? 'User',
            photoUrl: currentUser.photoURL,
            createdAt: DateTime.now(),
          );
        }
      }
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error loading user profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserProfile({
    String? displayName,
    double? monthlyIncome,
    double? budgetLimit,
    String? currency,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      // Update Firebase Auth profile if displayName is provided
      if (displayName != null) {
        await _authService.updateProfile(displayName: displayName);
      }

      // Update SQLite
      if (_user != null) {
        await _dbHelper.updateUser(
          uid: _user!.uid,
          displayName: displayName,
          monthlyIncome: monthlyIncome,
          budgetLimit: budgetLimit,
          currency: currency,
        );

        _user = _user!.copyWith(
          displayName: displayName,
          monthlyIncome: monthlyIncome,
          budgetLimit: budgetLimit,
          currency: currency,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error updating user profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearUser() {
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearData() {
    clearUser();
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
