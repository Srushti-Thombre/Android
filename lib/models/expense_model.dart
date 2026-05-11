class ExpenseModel {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final DateTime date;
  final String note;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? receiptUrl;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.date,
    this.note = '',
    required this.createdAt,
    this.updatedAt,
    this.receiptUrl,
  });

  factory ExpenseModel.fromMap(String id, Map<String, dynamic> map) {
    return ExpenseModel(
      id: id,
      userId: map['userId'] ?? '',
      category: map['category'] ?? 'Other',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.parse(map['date']),
      note: map['note'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      receiptUrl: map['receiptUrl'],
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'category': category,
    'amount': amount,
    'date': date.toIso8601String(),
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'receiptUrl': receiptUrl,
  };

  ExpenseModel copyWith({
    String? category,
    double? amount,
    DateTime? date,
    String? note,
    DateTime? updatedAt,
    String? receiptUrl,
  }) {
    return ExpenseModel(
      id: id,
      userId: userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      receiptUrl: receiptUrl ?? this.receiptUrl,
    );
  }
}
