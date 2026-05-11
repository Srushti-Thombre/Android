class MonthlySummaryModel {
  final String id;
  final String userId;
  final String month; // YYYY-MM format
  final double totalIncome;
  final double totalExpenses;
  final Map<String, double> categoryBreakdown;
  final double savings;
  final double expenseRatio;
  final String budgetStatus; // ontrack, warning, exceeded
  final DateTime generatedAt;

  MonthlySummaryModel({
    required this.id,
    required this.userId,
    required this.month,
    required this.totalIncome,
    required this.totalExpenses,
    required this.categoryBreakdown,
    required this.savings,
    required this.expenseRatio,
    required this.budgetStatus,
    required this.generatedAt,
  });

  factory MonthlySummaryModel.fromMap(String id, Map<String, dynamic> map) {
    final breakdown = Map<String, double>.from(
      (map['categoryBreakdown'] as Map?)?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {},
    );

    return MonthlySummaryModel(
      id: id,
      userId: map['userId'] ?? '',
      month: map['month'] ?? '',
      totalIncome: (map['totalIncome'] ?? 0).toDouble(),
      totalExpenses: (map['totalExpenses'] ?? 0).toDouble(),
      categoryBreakdown: breakdown,
      savings: (map['savings'] ?? 0).toDouble(),
      expenseRatio: (map['expenseRatio'] ?? 0).toDouble(),
      budgetStatus: map['budgetStatus'] ?? 'ontrack',
      generatedAt: DateTime.parse(map['generatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'month': month,
    'totalIncome': totalIncome,
    'totalExpenses': totalExpenses,
    'categoryBreakdown': categoryBreakdown,
    'savings': savings,
    'expenseRatio': expenseRatio,
    'budgetStatus': budgetStatus,
    'generatedAt': generatedAt.toIso8601String(),
  };

  String getStatus() {
    if (expenseRatio > 100) {
      return 'Budget Exceeded!';
    } else if (expenseRatio > 80) {
      return 'High Spending';
    } else if (expenseRatio > 50) {
      return 'Moderate Spending';
    } else {
      return 'Good Savings';
    }
  }

  MonthlySummaryModel copyWith({
    double? totalIncome,
    double? totalExpenses,
    Map<String, double>? categoryBreakdown,
    double? savings,
    double? expenseRatio,
    String? budgetStatus,
  }) {
    return MonthlySummaryModel(
      id: id,
      userId: userId,
      month: month,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      savings: savings ?? this.savings,
      expenseRatio: expenseRatio ?? this.expenseRatio,
      budgetStatus: budgetStatus ?? this.budgetStatus,
      generatedAt: generatedAt,
    );
  }
}
