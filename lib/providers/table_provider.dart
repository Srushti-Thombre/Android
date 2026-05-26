import 'package:flutter/foundation.dart';
import '../models/table_model.dart';
import '../services/database_helper.dart';
import 'package:uuid/uuid.dart';

class TableProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<TableModel> _allTables = [];
  double _grandTotal = 0.0;
  String? _error;
  String? _currentUserId;
  bool _isLoading = false;

  // Getters
  List<TableModel> get tables => List.unmodifiable(_allTables);
  List<TableModel> get openTables =>
      List.unmodifiable(_allTables.where((t) => t.isOpen).toList());
  List<TableModel> get closedTables =>
      List.unmodifiable(_allTables.where((t) => !t.isOpen).toList());
  double get grandTotal => _grandTotal;
  String? get error => _error;
  bool get isLoading => _isLoading;

  /// Initialize provider for a specific user
  Future<void> initializeUser(String userId) async {
    _currentUserId = userId;
    await _loadUserTables();
  }

  /// Load tables for current user from SQLite
  Future<void> _loadUserTables() async {
    if (_currentUserId == null) return;

    _setLoading(true);
    _clearError();

    try {
      final results = await _dbHelper.getTablesForUser(_currentUserId!);

      _allTables = results
          .map((map) => TableModel.fromMap(map['id'] as String, map))
          .toList();

      // Sort by table number
      _allTables.sort((a, b) => a.tableNumber.compareTo(b.tableNumber));

      _calculateTotals();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error loading tables: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new table
  Future<void> createTable(String userId, int tableNumber) async {
    if (userId != _currentUserId) {
      _currentUserId = userId;
    }

    _clearError();

    try {
      final tableId = const Uuid().v4();

      await _dbHelper.insertTable(
        id: tableId,
        userId: userId,
        tableNumber: tableNumber,
      );

      await _loadUserTables();
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error creating table: $e');
      rethrow;
    }
  }

  /// Add order to a table
  Future<void> addOrder({
    required String tableId,
    required String itemName,
    required double itemPrice,
    required int quantity,
    String? notes,
    double taxPercent = 5.0,
  }) async {
    _clearError();

    try {
      final orderId = const Uuid().v4();
      final totalPrice = itemPrice * quantity;

      await _dbHelper.insertOrder(
        id: orderId,
        tableId: tableId,
        itemName: itemName,
        itemPrice: itemPrice,
        quantity: quantity,
        totalPrice: totalPrice,
        notes: notes,
        taxPercent: taxPercent,
      );

      await _loadUserTables();
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error adding order: $e');
      rethrow;
    }
  }

  /// Remove order from table
  Future<void> removeOrder(String tableId, String orderId) async {
    _clearError();

    try {
      await _dbHelper.deleteOrder(tableId, orderId);
      await _loadUserTables();
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error removing order: $e');
      rethrow;
    }
  }

  /// Update order quantity
  Future<void> updateOrderQuantity(
    String tableId,
    String orderId,
    int newQuantity,
  ) async {
    _clearError();

    try {
      await _dbHelper.updateOrderQuantity(tableId, orderId, newQuantity);
      await _loadUserTables();
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error updating order: $e');
      rethrow;
    }
  }

  /// Close table (complete billing)
  Future<void> closeTable(String tableId) async {
    _clearError();

    try {
      await _dbHelper.updateTableStatus(tableId, false);
      await _loadUserTables();
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error closing table: $e');
      rethrow;
    }
  }

  /// Reopen table (customer comes back)
  Future<void> reopenTable(String tableId) async {
    _clearError();

    try {
      await _dbHelper.updateTableStatus(tableId, true);
      await _loadUserTables();
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error reopening table: $e');
      rethrow;
    }
  }

  /// Delete table
  Future<void> deleteTable(String tableId) async {
    _clearError();

    try {
      await _dbHelper.deleteTable(tableId);
      await _loadUserTables();
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error deleting table: $e');
      rethrow;
    }
  }

  /// Get table by ID
  TableModel? getTableById(String tableId) {
    try {
      return _allTables.firstWhere((t) => t.id == tableId);
    } catch (e) {
      return null;
    }
  }

  /// Calculate totals for all open tables
  void _calculateTotals() {
    _grandTotal = 0.0;
    for (final table in openTables) {
      _grandTotal += table.totalAmount;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }
}
