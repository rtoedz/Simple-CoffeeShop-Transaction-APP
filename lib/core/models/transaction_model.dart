class TransactionModel {
  final String id;
  final String userId;
  final List<TransactionItem> items;
  final double totalAmount;
  final double taxAmount;
  final double discountAmount;
  final double finalAmount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    required this.finalAmount,
    required this.paymentMethod,
    this.status = 'completed',
    required this.createdAt,
    this.updatedAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((item) => TransactionItem.fromMap(item))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      taxAmount: (map['taxAmount'] ?? 0.0).toDouble(),
      discountAmount: (map['discountAmount'] ?? 0.0).toDouble(),
      finalAmount: (map['finalAmount'] ?? 0.0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'cash',
      status: map['status'] ?? 'completed',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    List<TransactionItem>? items,
    double? totalAmount,
    double? taxAmount,
    double? discountAmount,
    double? finalAmount,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TransactionItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;
  final String? notes;

  TransactionItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.notes,
  });

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
      'notes': notes,
    };
  }

  TransactionItem copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    double? subtotal,
    String? notes,
  }) {
    return TransactionItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
      notes: notes ?? this.notes,
    );
  }
}