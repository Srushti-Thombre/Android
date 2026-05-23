class MonthlySummaryModel {
  final String id;
  final String userId;
  final String month; // Format: yyyy-MM
  final double totalExpenses;
  final double totalIncome;
  final double savings;
  final double savingsPercentage;
  final String? highestCategory;
  final double? highestCategoryAmount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MonthlySummaryModel({
    required this.id,
    required this.userId,
    required this.month,
    required this.totalExpenses,
    required this.totalIncome,
    required this.savings,
    required this.savingsPercentage,
    this.highestCategory,
    this.highestCategoryAmount,
    required this.createdAt,
    this.updatedAt,
  });

  factory MonthlySummaryModel.fromMap(String id, Map<String, dynamic> map) {
    return MonthlySummaryModel(
      id: id,
      userId: map['userId'] ?? '',
      month: map['month'] ?? '',
      totalExpenses: (map['totalExpenses'] ?? 0).toDouble(),
      totalIncome: (map['totalIncome'] ?? 0).toDouble(),
      savings: (map['savings'] ?? 0).toDouble(),
      savingsPercentage: (map['savingsPercentage'] ?? 0).toDouble(),
      highestCategory: map['highestCategory'],
      highestCategoryAmount: map['highestCategoryAmount'] != null 
          ? (map['highestCategoryAmount'] as num).toDouble() 
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'month': month,
    'totalExpenses': totalExpenses,
    'totalIncome': totalIncome,
    'savings': savings,
    'savingsPercentage': savingsPercentage,
    'highestCategory': highestCategory,
    'highestCategoryAmount': highestCategoryAmount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  String getStatus() {
    if (savingsPercentage <= 0) {
      return 'Budget Exceeded!';
    } else if (savingsPercentage < 20) {
      return 'High Spending';
    } else if (savingsPercentage < 50) {
      return 'Moderate Spending';
    } else {
      return 'Good Savings';
    }
  }

  MonthlySummaryModel copyWith({
    String? id,
    String? userId,
    String? month,
    double? totalExpenses,
    double? totalIncome,
    double? savings,
    double? savingsPercentage,
    String? highestCategory,
    double? highestCategoryAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MonthlySummaryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      month: month ?? this.month,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalIncome: totalIncome ?? this.totalIncome,
      savings: savings ?? this.savings,
      savingsPercentage: savingsPercentage ?? this.savingsPercentage,
      highestCategory: highestCategory ?? this.highestCategory,
      highestCategoryAmount: highestCategoryAmount ?? this.highestCategoryAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
