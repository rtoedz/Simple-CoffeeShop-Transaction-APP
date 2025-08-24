import 'product.dart';

class TransactionItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;

  TransactionItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  }) : subtotal = price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] ?? 0,
    );
  }
}

class TransactionModel {
  final String? id;
  final List<TransactionItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String paymentMethod;
  final double amountPaid;
  final double change;
  final String cashierId;
  final String cashierName;
  final DateTime timestamp;
  final String status;
  final String? notes;

  TransactionModel({
    this.id,
    required this.items,
    required this.subtotal,
    this.tax = 0.0,
    this.discount = 0.0,
    required this.total,
    required this.paymentMethod,
    required this.amountPaid,
    required this.change,
    required this.cashierId,
    required this.cashierName,
    DateTime? timestamp,
    this.status = 'completed',
    this.notes,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'paymentMethod': paymentMethod,
      'amountPaid': amountPaid,
      'change': change,
      'cashierId': cashierId,
      'cashierName': cashierName,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      items: (map['items'] as List<dynamic>)
          .map((item) => TransactionItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      subtotal: (map['subtotal'] as num).toDouble(),
      tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      amountPaid: (map['amountPaid'] as num).toDouble(),
      change: (map['change'] as num).toDouble(),
      cashierId: map['cashierId'] ?? '',
      cashierName: map['cashierName'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : DateTime.now(),
      status: map['status'] ?? 'completed',
      notes: map['notes'],
    );
  }

  TransactionModel copyWith({
    String? id,
    List<TransactionItem>? items,
    double? subtotal,
    double? tax,
    double? discount,
    double? total,
    String? paymentMethod,
    double? amountPaid,
    double? change,
    String? cashierId,
    String? cashierName,
    DateTime? timestamp,
    String? status,
    String? notes,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountPaid: amountPaid ?? this.amountPaid,
      change: change ?? this.change,
      cashierId: cashierId ?? this.cashierId,
      cashierName: cashierName ?? this.cashierName,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, total: $total, items: ${items.length}, timestamp: $timestamp)';
  }
}