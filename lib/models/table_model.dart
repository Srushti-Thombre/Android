class TableModel {
  final String id;
  final String userId;
  final int tableNumber;
  final bool isOpen;
  final double totalAmount;
  final double taxAmount;
  final double subtotal;
  final List<OrderModel> orders;
  final DateTime createdAt;
  final DateTime? closedAt;
  final DateTime? updatedAt;

  TableModel({
    required this.id,
    required this.userId,
    required this.tableNumber,
    this.isOpen = true,
    this.totalAmount = 0.0,
    this.taxAmount = 0.0,
    this.subtotal = 0.0,
    this.orders = const [],
    required this.createdAt,
    this.closedAt,
    this.updatedAt,
  });

  factory TableModel.fromMap(String id, Map<String, dynamic> map) {
    return TableModel(
      id: id,
      userId: map['userId'] ?? '',
      tableNumber: map['tableNumber'] ?? 0,
      isOpen: map['isOpen'] ?? true,
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      taxAmount: (map['taxAmount'] ?? 0).toDouble(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      orders:
          (map['orders'] as List<dynamic>?)
              ?.map((o) => OrderModel.fromMap(o as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      closedAt: map['closedAt'] != null
          ? DateTime.parse(map['closedAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'tableNumber': tableNumber,
    'isOpen': isOpen,
    'totalAmount': totalAmount,
    'taxAmount': taxAmount,
    'subtotal': subtotal,
    'orders': orders.map((o) => o.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'closedAt': closedAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  TableModel copyWith({
    String? id,
    String? userId,
    int? tableNumber,
    bool? isOpen,
    double? totalAmount,
    double? taxAmount,
    double? subtotal,
    List<OrderModel>? orders,
    DateTime? createdAt,
    DateTime? closedAt,
    DateTime? updatedAt,
  }) {
    return TableModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tableNumber: tableNumber ?? this.tableNumber,
      isOpen: isOpen ?? this.isOpen,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      subtotal: subtotal ?? this.subtotal,
      orders: orders ?? this.orders,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class OrderModel {
  final String id;
  final String itemName;
  final double itemPrice;
  final int quantity;
  final double totalPrice;
  final DateTime addedAt;
  final String? notes;

  OrderModel({
    required this.id,
    required this.itemName,
    required this.itemPrice,
    required this.quantity,
    this.totalPrice = 0.0,
    required this.addedAt,
    this.notes,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      itemName: map['itemName'] ?? '',
      itemPrice: (map['itemPrice'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      addedAt: DateTime.parse(map['addedAt']),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'itemName': itemName,
    'itemPrice': itemPrice,
    'quantity': quantity,
    'totalPrice': totalPrice,
    'addedAt': addedAt.toIso8601String(),
    'notes': notes,
  };

  OrderModel copyWith({
    String? id,
    String? itemName,
    double? itemPrice,
    int? quantity,
    double? totalPrice,
    DateTime? addedAt,
    String? notes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      itemPrice: itemPrice ?? this.itemPrice,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      addedAt: addedAt ?? this.addedAt,
      notes: notes ?? this.notes,
    );
  }
}
