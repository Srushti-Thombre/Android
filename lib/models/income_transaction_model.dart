class IncomeTransactionModel {
  final String id;
  final String userId;
  final String source;
  final double amount;
  final DateTime date;
  final String note;
  final DateTime createdAt;
  final DateTime? updatedAt;

  IncomeTransactionModel({
    required this.id,
    required this.userId,
    required this.source,
    required this.amount,
    required this.date,
    this.note = '',
    required this.createdAt,
    this.updatedAt,
  });

  factory IncomeTransactionModel.fromMap(String id, Map<String, dynamic> map) {
    return IncomeTransactionModel(
      id: id,
      userId: map['userId'] ?? '',
      source: map['source'] ?? 'Income',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.parse(map['date']),
      note: map['note'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'source': source,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  IncomeTransactionModel copyWith({
    String? source,
    double? amount,
    DateTime? date,
    String? note,
    DateTime? updatedAt,
  }) {
    return IncomeTransactionModel(
      id: id,
      userId: userId,
      source: source ?? this.source,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}