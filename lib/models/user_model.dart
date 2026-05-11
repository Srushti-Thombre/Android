class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final double monthlyIncome;
  final String currency;
  final double budgetLimit;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.monthlyIncome = 0.0,
    this.currency = '₹',
    this.budgetLimit = 0.0,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      monthlyIncome: (map['monthlyIncome'] ?? 0).toDouble(),
      currency: map['currency'] ?? '₹',
      budgetLimit: (map['budgetLimit'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      lastLoginAt: map['lastLoginAt'] != null ? DateTime.parse(map['lastLoginAt']) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'monthlyIncome': monthlyIncome,
    'currency': currency,
    'budgetLimit': budgetLimit,
    'createdAt': createdAt.toIso8601String(),
    'lastLoginAt': lastLoginAt?.toIso8601String(),
  };

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    double? monthlyIncome,
    String? currency,
    double? budgetLimit,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      currency: currency ?? this.currency,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
