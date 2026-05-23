import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../services/database_helper.dart';
import 'package:uuid/uuid.dart';

class ExpenseProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<ExpenseModel> _currentUserExpenses = [];
  Map<String, double> _categoryBreakdown = {};
  double _totalExpenses = 0.0;
  String? _error;
  DateTime _selectedMonth = DateTime.now();
  String? _currentUserId;
  bool _isLoading = false;

  // Getters
  List<ExpenseModel> get expenses => List.unmodifiable(_currentUserExpenses);
  Map<String, double> get categoryBreakdown =>
      Map.unmodifiable(_categoryBreakdown);
  double get totalExpenses => _totalExpenses;
  String? get error => _error;
  DateTime get selectedMonth => _selectedMonth;
  bool get isLoading => _isLoading;

  /// Initialize provider for a specific user
  Future<void> initializeUser(String userId) async {
    _currentUserId = userId;
    await _loadUserExpenses();
  }

  /// Load expenses for current user and month from SQLite
  Future<void> _loadUserExpenses() async {
    if (_currentUserId == null) return;

    _setLoading(true);
    _clearError();

    try {
      final results = await _dbHelper.getExpensesForUserAndMonth(
        _currentUserId!,
        _selectedMonth.year,
        _selectedMonth.month,
      );

      _currentUserExpenses = results
          .map((map) => ExpenseModel.fromMap(map['id'] as String, map))
          .toList();

      // Sort by date (newest first)
      _currentUserExpenses.sort((a, b) => b.date.compareTo(a.date));

      _calculateTotals();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error loading expenses: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new expense to SQLite
  Future<void> addExpense({
    required String userId,
    required String category,
    required double amount,
    required DateTime date,
    String note = '',
    String? receiptUrl,
  }) async {
    if (userId != _currentUserId) {
      _currentUserId = userId;
    }

    _clearError();

    try {
      final expenseId = const Uuid().v4();

      await _dbHelper.insertExpense(
        id: expenseId,
        userId: userId,
        category: category,
        amount: amount,
        date: date,
        note: note,
        receiptUrl: receiptUrl,
      );

      // Reload expenses for current month
      await _loadUserExpenses();
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error adding expense: $e');
      rethrow;
    }
  }

  /// Update an existing expense in SQLite
  Future<void> updateExpense({
    required String expenseId,
    String? category,
    double? amount,
    DateTime? date,
    String? note,
    String? receiptUrl,
  }) async {
    if (_currentUserId == null) return;

    _clearError();

    try {
      await _dbHelper.updateExpense(
        id: expenseId,
        category: category,
        amount: amount,
        date: date,
        note: note,
        receiptUrl: receiptUrl,
      );

      // Reload expenses
      await _loadUserExpenses();
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error updating expense: $e');
      rethrow;
    }
  }

  /// Delete an expense from SQLite
  Future<void> deleteExpense(String expenseId) async {
    if (_currentUserId == null) return;

    _clearError();

    try {
      await _dbHelper.deleteExpense(expenseId);

      // Reload expenses
      await _loadUserExpenses();
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error deleting expense: $e');
      rethrow;
    }
  }

  /// Change selected month and reload expenses
  Future<void> setSelectedMonth(DateTime month) async {
    _selectedMonth = DateTime(month.year, month.month, 1);
    await _loadUserExpenses();
  }

  /// Get all expenses for a user (not filtered by month)
  Future<List<ExpenseModel>> getAllUserExpenses(String userId) async {
    try {
      final results = await _dbHelper.getExpensesForUser(userId);
      return results
          .map((map) => ExpenseModel.fromMap(map['id'] as String, map))
          .toList();
    } catch (e) {
      debugPrint('Error getting all expenses: $e');
      return [];
    }
  }

  /// Get category breakdown for specific date range
  Future<Map<String, double>> getCategoryBreakdown(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _dbHelper.getCategoryBreakdownForUser(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      debugPrint('Error getting category breakdown: $e');
      return {};
    }
  }

  /// Get total expenses for specific date range
  Future<double> getTotalExpenses(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _dbHelper.getTotalExpensesForUser(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      debugPrint('Error getting total expenses: $e');
      return 0.0;
    }
  }

  /// Calculate totals and category breakdown for current loaded expenses
  void _calculateTotals() {
    _categoryBreakdown.clear();
    _totalExpenses = 0.0;

    for (final expense in _currentUserExpenses) {
      _totalExpenses += expense.amount;
      _categoryBreakdown[expense.category] =
          (_categoryBreakdown[expense.category] ?? 0.0) + expense.amount;
    }
  }

  /// Get expense by ID
  Future<ExpenseModel?> getExpenseById(String id) async {
    try {
      final result = await _dbHelper.getExpenseById(id);
      if (result != null) {
        return ExpenseModel.fromMap(result['id'] as String, result);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting expense by ID: $e');
      return null;
    }
  }

  /// Clear all data (useful for logout)
  void clearData() {
    _currentUserId = null;
    _currentUserExpenses.clear();
    _categoryBreakdown.clear();
    _totalExpenses = 0.0;
    _error = null;
    _isLoading = false;
    notifyListeners();
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
