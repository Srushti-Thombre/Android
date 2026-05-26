import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite persistence is not supported on web. Run the Windows desktop app instead.',
      );
    }

    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final databasesPath = await databaseFactory.getDatabasesPath();
    final path = join(databasesPath, 'finance_tracker.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE income_transactions(
          id TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          source TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          note TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT,
          FOREIGN KEY (userId) REFERENCES users(uid) ON DELETE CASCADE
        )
        ''');

      await db.execute(
        'CREATE INDEX idx_income_transactions_userId ON income_transactions(userId)',
      );

      await db.execute(
        'CREATE INDEX idx_income_transactions_date ON income_transactions(date)',
      );
    }

    if (oldVersion < 3) {
      // Create tables for hotel management
      await db.execute('''
        CREATE TABLE hotel_tables(
          id TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          tableNumber INTEGER NOT NULL,
          isOpen INTEGER DEFAULT 1,
          totalAmount REAL DEFAULT 0,
          taxAmount REAL DEFAULT 0,
          subtotal REAL DEFAULT 0,
          createdAt TEXT NOT NULL,
          closedAt TEXT,
          updatedAt TEXT,
          FOREIGN KEY (userId) REFERENCES users(uid) ON DELETE CASCADE,
          UNIQUE(userId, tableNumber)
        )
        ''');

      await db.execute('''
        CREATE TABLE table_orders(
          id TEXT PRIMARY KEY,
          tableId TEXT NOT NULL,
          itemName TEXT NOT NULL,
          itemPrice REAL NOT NULL,
          quantity INTEGER NOT NULL,
          totalPrice REAL NOT NULL,
          notes TEXT,
          addedAt TEXT NOT NULL,
          FOREIGN KEY (tableId) REFERENCES hotel_tables(id) ON DELETE CASCADE
        )
        ''');

      await db.execute(
        'CREATE INDEX idx_hotel_tables_userId ON hotel_tables(userId)',
      );

      await db.execute(
        'CREATE INDEX idx_table_orders_tableId ON table_orders(tableId)',
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        uid TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        displayName TEXT NOT NULL,
        photoUrl TEXT,
        monthlyIncome REAL DEFAULT 0,
        currency TEXT DEFAULT '₹',
        budgetLimit REAL DEFAULT 0,
        createdAt TEXT NOT NULL,
        lastLoginAt TEXT
      )
      ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        receiptUrl TEXT,
        FOREIGN KEY (userId) REFERENCES users(uid) ON DELETE CASCADE
      )
      ''');

    // Income transactions table
    await db.execute('''
      CREATE TABLE income_transactions(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        source TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        FOREIGN KEY (userId) REFERENCES users(uid) ON DELETE CASCADE
      )
      ''');

    // Create index on userId for faster queries
    await db.execute('CREATE INDEX idx_expenses_userId ON expenses(userId)');

    // Create index on date for faster queries
    await db.execute('CREATE INDEX idx_expenses_date ON expenses(date)');

    await db.execute(
      'CREATE INDEX idx_income_transactions_userId ON income_transactions(userId)',
    );

    await db.execute(
      'CREATE INDEX idx_income_transactions_date ON income_transactions(date)',
    );

    // Monthly reports table (for caching)
    await db.execute('''
      CREATE TABLE monthly_reports(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        month TEXT NOT NULL,
        totalExpenses REAL DEFAULT 0,
        totalIncome REAL DEFAULT 0,
        savings REAL DEFAULT 0,
        savingsPercentage REAL DEFAULT 0,
        highestCategory TEXT,
        highestCategoryAmount REAL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        FOREIGN KEY (userId) REFERENCES users(uid) ON DELETE CASCADE,
        UNIQUE(userId, month)
      )
      ''');

    // Create index on userId and month for faster queries
    await db.execute(
      'CREATE INDEX idx_monthly_reports_userId_month ON monthly_reports(userId, month)',
    );

    // Hotel Tables for restaurant/hotel management
    await db.execute('''
      CREATE TABLE hotel_tables(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        tableNumber INTEGER NOT NULL,
        isOpen INTEGER DEFAULT 1,
        totalAmount REAL DEFAULT 0,
        taxAmount REAL DEFAULT 0,
        subtotal REAL DEFAULT 0,
        createdAt TEXT NOT NULL,
        closedAt TEXT,
        updatedAt TEXT,
        FOREIGN KEY (userId) REFERENCES users(uid) ON DELETE CASCADE,
        UNIQUE(userId, tableNumber)
      )
      ''');

    await db.execute('''
      CREATE TABLE table_orders(
        id TEXT PRIMARY KEY,
        tableId TEXT NOT NULL,
        itemName TEXT NOT NULL,
        itemPrice REAL NOT NULL,
        quantity INTEGER NOT NULL,
        totalPrice REAL NOT NULL,
        notes TEXT,
        addedAt TEXT NOT NULL,
        FOREIGN KEY (tableId) REFERENCES hotel_tables(id) ON DELETE CASCADE
      )
      ''');

    await db.execute(
      'CREATE INDEX idx_hotel_tables_userId ON hotel_tables(userId)',
    );

    await db.execute(
      'CREATE INDEX idx_table_orders_tableId ON table_orders(tableId)',
    );
  }

  // ===================== USER OPERATIONS =====================

  Future<void> insertOrUpdateUser({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
    double monthlyIncome = 0,
    String currency = '₹',
    double budgetLimit = 0,
    required DateTime createdAt,
  }) async {
    final db = await database;
    await db.insert('users', {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'monthlyIncome': monthlyIncome,
      'currency': currency,
      'budgetLimit': budgetLimit,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUserById(String uid) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateUser({
    required String uid,
    String? displayName,
    String? photoUrl,
    double? monthlyIncome,
    String? currency,
    double? budgetLimit,
  }) async {
    final db = await database;
    final updates = <String, dynamic>{};

    if (displayName != null) updates['displayName'] = displayName;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (monthlyIncome != null) updates['monthlyIncome'] = monthlyIncome;
    if (currency != null) updates['currency'] = currency;
    if (budgetLimit != null) updates['budgetLimit'] = budgetLimit;
    updates['lastLoginAt'] = DateTime.now().toIso8601String();

    await db.update('users', updates, where: 'uid = ?', whereArgs: [uid]);
  }

  // ===================== EXPENSE OPERATIONS =====================

  Future<void> insertExpense({
    required String id,
    required String userId,
    required String category,
    required double amount,
    required DateTime date,
    String note = '',
    String? receiptUrl,
  }) async {
    final db = await database;
    await db.insert('expenses', {
      'id': id,
      'userId': userId,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': DateTime.now().toIso8601String(),
      'receiptUrl': receiptUrl,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateExpense({
    required String id,
    String? category,
    double? amount,
    DateTime? date,
    String? note,
    String? receiptUrl,
  }) async {
    final db = await database;
    final updates = <String, dynamic>{};

    if (category != null) updates['category'] = category;
    if (amount != null) updates['amount'] = amount;
    if (date != null) updates['date'] = date.toIso8601String();
    if (note != null) updates['note'] = note;
    if (receiptUrl != null) updates['receiptUrl'] = receiptUrl;
    updates['updatedAt'] = DateTime.now().toIso8601String();

    await db.update('expenses', updates, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getExpensesForUser(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    final query = StringBuffer('SELECT * FROM expenses WHERE userId = ?');
    final args = <dynamic>[userId];

    if (startDate != null) {
      query.write(' AND date >= ?');
      args.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      query.write(' AND date <= ?');
      args.add(_endOfDay(endDate).toIso8601String());
    }

    query.write(' ORDER BY date DESC');

    return await db.rawQuery(query.toString(), args);
  }

  Future<List<Map<String, dynamic>>> getExpensesForUserAndMonth(
    String userId,
    int year,
    int month,
  ) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = _endOfDay(DateTime(year, month + 1, 0));

    return await db.query(
      'expenses',
      where: 'userId = ? AND date >= ? AND date <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
  }

  Future<Map<String, dynamic>?> getExpenseById(String id) async {
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<double> getTotalExpensesForUser(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    final query = StringBuffer(
      'SELECT SUM(amount) as total FROM expenses WHERE userId = ?',
    );
    final args = <dynamic>[userId];

    if (startDate != null) {
      query.write(' AND date >= ?');
      args.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      query.write(' AND date <= ?');
      args.add(_endOfDay(endDate).toIso8601String());
    }

    final result = await db.rawQuery(query.toString(), args);
    final total = result.isNotEmpty && result.first['total'] != null
        ? (result.first['total'] as num).toDouble()
        : 0.0;
    return total;
  }

  Future<Map<String, double>> getCategoryBreakdownForUser(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    final query = StringBuffer(
      'SELECT category, SUM(amount) as total FROM expenses WHERE userId = ?',
    );
    final args = <dynamic>[userId];

    if (startDate != null) {
      query.write(' AND date >= ?');
      args.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      query.write(' AND date <= ?');
      args.add(_endOfDay(endDate).toIso8601String());
    }

    query.write(' GROUP BY category ORDER BY total DESC');

    final results = await db.rawQuery(query.toString(), args);
    final breakdown = <String, double>{};

    for (final row in results) {
      final category = row['category'] as String? ?? 'Other';
      final total = row['total'] as num? ?? 0;
      breakdown[category] = total.toDouble();
    }

    return breakdown;
  }

  Future<int> getExpenseCountForUser(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM expenses WHERE userId = ?',
      [userId],
    );
    return result.isNotEmpty ? (result.first['count'] as int?) ?? 0 : 0;
  }

  // ===================== INCOME OPERATIONS =====================

  Future<void> insertIncomeTransaction({
    required String id,
    required String userId,
    required String source,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    final db = await database;
    await db.insert('income_transactions', {
      'id': id,
      'userId': userId,
      'source': source,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteIncomeTransaction(String id) async {
    final db = await database;
    await db.delete('income_transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getIncomeTransactionsForUser(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    final query = StringBuffer(
      'SELECT * FROM income_transactions WHERE userId = ?',
    );
    final args = <dynamic>[userId];

    if (startDate != null) {
      query.write(' AND date >= ?');
      args.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      query.write(' AND date <= ?');
      args.add(endDate.toIso8601String());
    }

    query.write(' ORDER BY date DESC');

    return await db.rawQuery(query.toString(), args);
  }

  Future<List<Map<String, dynamic>>> getIncomeTransactionsForUserAndMonth(
    String userId,
    int year,
    int month,
  ) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = _endOfDay(DateTime(year, month + 1, 0));

    return await db.query(
      'income_transactions',
      where: 'userId = ? AND date >= ? AND date <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
  }

  Future<double> getTotalIncomeForUser(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    final query = StringBuffer(
      'SELECT SUM(amount) as total FROM income_transactions WHERE userId = ?',
    );
    final args = <dynamic>[userId];

    if (startDate != null) {
      query.write(' AND date >= ?');
      args.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      query.write(' AND date <= ?');
      args.add(_endOfDay(endDate).toIso8601String());
    }

    final result = await db.rawQuery(query.toString(), args);
    final total = result.isNotEmpty && result.first['total'] != null
        ? (result.first['total'] as num).toDouble()
        : 0.0;
    return total;
  }

  Future<int> getIncomeTransactionCountForUser(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM income_transactions WHERE userId = ?',
      [userId],
    );
    return result.isNotEmpty ? (result.first['count'] as int?) ?? 0 : 0;
  }

  // ===================== MONTHLY REPORT OPERATIONS =====================

  Future<void> insertOrUpdateMonthlyReport({
    required String id,
    required String userId,
    required String month, // Format: yyyy-MM
    required double totalExpenses,
    required double totalIncome,
    required double savings,
    required double savingsPercentage,
    String? highestCategory,
    double? highestCategoryAmount,
  }) async {
    final db = await database;
    await db.insert('monthly_reports', {
      'id': id,
      'userId': userId,
      'month': month,
      'totalExpenses': totalExpenses,
      'totalIncome': totalIncome,
      'savings': savings,
      'savingsPercentage': savingsPercentage,
      'highestCategory': highestCategory,
      'highestCategoryAmount': highestCategoryAmount,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getMonthlyReport(
    String userId,
    String month, // Format: yyyy-MM
  ) async {
    final db = await database;
    final result = await db.query(
      'monthly_reports',
      where: 'userId = ? AND month = ?',
      whereArgs: [userId, month],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getMonthlyReportsForUser(
    String userId, {
    int limit = 12,
  }) async {
    final db = await database;
    return await db.query(
      'monthly_reports',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'month DESC',
      limit: limit,
    );
  }

  // ===================== MAINTENANCE OPERATIONS =====================

  Future<void> deleteAllUserData(String userId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('expenses', where: 'userId = ?', whereArgs: [userId]);
      await txn.delete(
        'monthly_reports',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      await txn.delete('users', where: 'uid = ?', whereArgs: [userId]);
    });
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('expenses');
      await txn.delete('monthly_reports');
      await txn.delete('users');
    });
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // ===================== HOTEL TABLE OPERATIONS =====================

  Future<void> insertTable({
    required String id,
    required String userId,
    required int tableNumber,
  }) async {
    final db = await database;
    await db.insert('hotel_tables', {
      'id': id,
      'userId': userId,
      'tableNumber': tableNumber,
      'isOpen': 1,
      'totalAmount': 0.0,
      'taxAmount': 0.0,
      'subtotal': 0.0,
      'createdAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertOrder({
    required String id,
    required String tableId,
    required String itemName,
    required double itemPrice,
    required int quantity,
    required double totalPrice,
    String? notes,
    double taxPercent = 5.0,
  }) async {
    final db = await database;

    // Insert the order
    await db.insert('table_orders', {
      'id': id,
      'tableId': tableId,
      'itemName': itemName,
      'itemPrice': itemPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'notes': notes,
      'addedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Update table totals
    await _updateTableTotals(tableId, taxPercent);
  }

  Future<void> deleteOrder(String tableId, String orderId) async {
    final db = await database;

    // Delete the order
    await db.delete('table_orders', where: 'id = ?', whereArgs: [orderId]);

    // Update table totals
    await _updateTableTotals(tableId);
  }

  Future<void> updateOrderQuantity(
    String tableId,
    String orderId,
    int newQuantity,
  ) async {
    final db = await database;

    // Get the order to recalculate total price
    final result = await db.query(
      'table_orders',
      where: 'id = ?',
      whereArgs: [orderId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final order = result.first;
      final itemPrice = (order['itemPrice'] as num).toDouble();
      final newTotalPrice = itemPrice * newQuantity;

      await db.update(
        'table_orders',
        {'quantity': newQuantity, 'totalPrice': newTotalPrice},
        where: 'id = ?',
        whereArgs: [orderId],
      );

      // Update table totals
      await _updateTableTotals(tableId);
    }
  }

  Future<void> _updateTableTotals(
    String tableId, [
    double taxPercent = 5.0,
  ]) async {
    final db = await database;

    // Get all orders for this table
    final orders = await db.query(
      'table_orders',
      where: 'tableId = ?',
      whereArgs: [tableId],
    );

    // Calculate totals
    double subtotal = 0.0;
    for (final order in orders) {
      subtotal += (order['totalPrice'] as num).toDouble();
    }

    final taxAmount = subtotal * (taxPercent / 100);
    final totalAmount = subtotal + taxAmount;

    // Update table
    await db.update(
      'hotel_tables',
      {
        'subtotal': subtotal,
        'taxAmount': taxAmount,
        'totalAmount': totalAmount,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [tableId],
    );
  }

  Future<void> deleteTable(String tableId) async {
    final db = await database;

    // Delete all orders for this table first
    await db.delete('table_orders', where: 'tableId = ?', whereArgs: [tableId]);

    // Delete the table
    await db.delete('hotel_tables', where: 'id = ?', whereArgs: [tableId]);
  }

  Future<void> updateTableStatus(String tableId, bool isOpen) async {
    final db = await database;
    await db.update(
      'hotel_tables',
      {
        'isOpen': isOpen ? 1 : 0,
        'closedAt': isOpen ? null : DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [tableId],
    );
  }

  Future<List<Map<String, dynamic>>> getTablesForUser(String userId) async {
    final db = await database;

    final tables = await db.query(
      'hotel_tables',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'tableNumber ASC',
    );

    // Fetch orders for each table
    for (final table in tables) {
      final orders = await db.query(
        'table_orders',
        where: 'tableId = ?',
        whereArgs: [table['id']],
      );
      table['orders'] = orders;
    }

    return tables;
  }

  Future<Map<String, dynamic>?> getTableById(String tableId) async {
    final db = await database;

    final result = await db.query(
      'hotel_tables',
      where: 'id = ?',
      whereArgs: [tableId],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final table = result.first;

    // Fetch orders for this table
    final orders = await db.query(
      'table_orders',
      where: 'tableId = ?',
      whereArgs: [tableId],
    );

    table['orders'] = orders;
    return table;
  }

  Future<List<Map<String, dynamic>>> getOrdersForTable(String tableId) async {
    final db = await database;
    return await db.query(
      'table_orders',
      where: 'tableId = ?',
      whereArgs: [tableId],
      orderBy: 'addedAt DESC',
    );
  }

  DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
}
