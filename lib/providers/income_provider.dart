import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/income_transaction_model.dart';
import '../services/database_helper.dart';

class IncomeProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<IncomeTransactionModel> _transactions = [];
  double _totalIncome = 0.0;
  DateTime _selectedMonth = DateTime.now();
  String? _currentUserId;
  bool _isLoading = false;
  String? _error;

  List<IncomeTransactionModel> get transactions => List.unmodifiable(_transactions);
  double get totalIncome => _totalIncome;
  DateTime get selectedMonth => _selectedMonth;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initializeUser(String userId) async {
    _currentUserId = userId;
    await _loadUserIncomeTransactions();
  }

  Future<void> _loadUserIncomeTransactions() async {
    if (_currentUserId == null) return;

    _setLoading(true);
    _clearError();

    try {
      final results = await _dbHelper.getIncomeTransactionsForUserAndMonth(
        _currentUserId!,
        _selectedMonth.year,
        _selectedMonth.month,
      );

      _transactions = results
          .map((map) => IncomeTransactionModel.fromMap(map['id'] as String, map))
          .toList();

      _transactions.sort((a, b) => b.date.compareTo(a.date));
      _calculateTotals();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error loading income transactions: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addIncomeTransaction({
    required String userId,
    required String source,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    _currentUserId ??= userId;
    _clearError();

    try {
      await _dbHelper.insertIncomeTransaction(
        id: const Uuid().v4(),
        userId: userId,
        source: source,
        amount: amount,
        date: date,
        note: note,
      );

      await _loadUserIncomeTransactions();
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error adding income transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteIncomeTransaction(String transactionId) async {
    if (_currentUserId == null) return;

    _clearError();

    try {
      await _dbHelper.deleteIncomeTransaction(transactionId);
      await _loadUserIncomeTransactions();
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error deleting income transaction: $e');
      rethrow;
    }
  }

  Future<void> setSelectedMonth(DateTime month) async {
    _selectedMonth = DateTime(month.year, month.month, 1);
    await _loadUserIncomeTransactions();
  }

  Future<List<IncomeTransactionModel>> getAllUserIncomeTransactions(String userId) async {
    try {
      final results = await _dbHelper.getIncomeTransactionsForUser(userId);
      return results
          .map((map) => IncomeTransactionModel.fromMap(map['id'] as String, map))
          .toList();
    } catch (e) {
      debugPrint('Error getting all income transactions: $e');
      return [];
    }
  }

  Future<double> getTotalIncome(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _dbHelper.getTotalIncomeForUser(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      debugPrint('Error getting total income: $e');
      return 0.0;
    }
  }

  void clearData() {
    _currentUserId = null;
    _transactions.clear();
    _totalIncome = 0.0;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void _calculateTotals() {
    _totalIncome = 0.0;
    for (final transaction in _transactions) {
      _totalIncome += transaction.amount;
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