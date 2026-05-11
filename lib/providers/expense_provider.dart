import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  // In-memory storage for expenses
  final Map<String, List<ExpenseModel>> _userExpenses = {};

  List<ExpenseModel> _currentUserExpenses = [];
  Map<String, double> _categoryBreakdown = {};
  double _totalExpenses = 0.0;
  String? _error;
  DateTime _selectedMonth = DateTime.now();
  String? _currentUserId;

  // Getters
  List<ExpenseModel> get expenses => List.unmodifiable(_currentUserExpenses);
  Map<String, double> get categoryBreakdown => Map.unmodifiable(_categoryBreakdown);
  double get totalExpenses => _totalExpenses;
  String? get error => _error;
  DateTime get selectedMonth => _selectedMonth;
  bool get isLoading => false; // Always false for in-memory operations

  /// Initialize provider for a specific user
  void initializeUser(String userId) {
    _currentUserId = userId;
    if (!_userExpenses.containsKey(userId)) {
      _userExpenses[userId] = [];
    }
    _loadUserExpenses();
  }

  /// Load expenses for current user and month
  void _loadUserExpenses() {
    if (_currentUserId == null) return;

    _currentUserExpenses = _userExpenses[_currentUserId]!
        .where((expense) =>
            expense.date.year == _selectedMonth.year &&
            expense.date.month == _selectedMonth.month)
        .toList();

    // Sort by date (newest first)
    _currentUserExpenses.sort((a, b) => b.date.compareTo(a.date));

    _calculateTotals();
    notifyListeners();
  }

  /// Add a new expense (instantly)
  void addExpense({
    required String userId,
    required String category,
    required double amount,
    required DateTime date,
    String note = '',
  }) {
    if (userId != _currentUserId) {
      _currentUserId = userId;
      if (!_userExpenses.containsKey(userId)) {
        _userExpenses[userId] = [];
      }
    }

    final expense = ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      category: category,
      amount: amount,
      date: date,
      note: note,
      createdAt: DateTime.now(),
    );

    _userExpenses[userId]!.add(expense);
    _loadUserExpenses();
  }

  /// Update an existing expense
  void updateExpense({
    required String expenseId,
    String? category,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    if (_currentUserId == null) return;

    final expenses = _userExpenses[_currentUserId]!;
    final index = expenses.indexWhere((e) => e.id == expenseId);

    if (index != -1) {
      expenses[index] = expenses[index].copyWith(
        category: category,
        amount: amount,
        date: date,
        note: note,
        updatedAt: DateTime.now(),
      );
      _loadUserExpenses();
    }
  }

  /// Delete an expense
  void deleteExpense(String expenseId) {
    if (_currentUserId == null) return;

    _userExpenses[_currentUserId]!.removeWhere((e) => e.id == expenseId);
    _loadUserExpenses();
  }

  /// Change selected month and reload expenses
  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month, 1);
    _loadUserExpenses();
  }

  /// Calculate totals and category breakdown synchronously
  void _calculateTotals() {
    _categoryBreakdown.clear();
    _totalExpenses = 0.0;

    for (final expense in _currentUserExpenses) {
      _totalExpenses += expense.amount;
      _categoryBreakdown[expense.category] =
          (_categoryBreakdown[expense.category] ?? 0.0) + expense.amount;
    }
  }

  /// Clear all data (useful for logout)
  void clearData() {
    _currentUserId = null;
    _currentUserExpenses.clear();
    _categoryBreakdown.clear();
    _totalExpenses = 0.0;
    _error = null;
    notifyListeners();
  }
}
