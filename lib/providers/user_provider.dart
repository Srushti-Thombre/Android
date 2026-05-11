import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

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
      _user = await _authService.getCurrentUser();
    } catch (e) {
      _setError(e.toString());
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
      if (displayName != null) {
        await _authService.updateProfile(displayName: displayName);
      }

      if (_user != null) {
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
