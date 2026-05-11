class BudgetModel {
  final String id;
  final String userId;
  final String categoryName;
  final double monthlyLimit;
  final double currentSpending;
  final double alertThreshold; // percentage
  final DateTime createdAt;
  final DateTime? updatedAt;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.categoryName,
    required this.monthlyLimit,
    this.currentSpending = 0.0,
    this.alertThreshold = 80.0,
    required this.createdAt,
    this.updatedAt,
  });

  factory BudgetModel.fromMap(String id, Map<String, dynamic> map) {
    return BudgetModel(
      id: id,
      userId: map['userId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      monthlyLimit: (map['monthlyLimit'] ?? 0).toDouble(),
      currentSpending: (map['currentSpending'] ?? 0).toDouble(),
      alertThreshold: (map['alertThreshold'] ?? 80).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'categoryName': categoryName,
    'monthlyLimit': monthlyLimit,
    'currentSpending': currentSpending,
    'alertThreshold': alertThreshold,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  bool isExceeded() => currentSpending > monthlyLimit;

  bool isAlertTriggered() => (currentSpending / monthlyLimit * 100) >= alertThreshold;

  double getSpendingPercentage() => (currentSpending / monthlyLimit * 100);

  BudgetModel copyWith({
    double? monthlyLimit,
    double? currentSpending,
    double? alertThreshold,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id,
      userId: userId,
      categoryName: categoryName,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      currentSpending: currentSpending ?? this.currentSpending,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
