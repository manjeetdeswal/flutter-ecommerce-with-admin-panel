import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { placed, shipped, delivered, cancelled }

class OrderItem {
  final String productId;
  final String productName;
  final String productImageUrl;
  final int quantity;
  final double pricePerUnit;

  OrderItem({
    required this.productId, required this.productName, required this.productImageUrl,
    required this.quantity, required this.pricePerUnit,
  });

  // Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
    };
  }

  // Read from Firestore Map
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImageUrl: map['productImageUrl'] ?? '',
      quantity: map['quantity']?.toInt() ?? 1,
      pricePerUnit: map['pricePerUnit']?.toDouble() ?? 0.0,
    );
  }
}

class Order {
  final String id;
  final String userId; // We need to know who bought it!
  final DateTime datePlaced;
  final double totalAmount;
  final OrderStatus status;
  final List<OrderItem> items;
  final Map<String, dynamic> shippingAddress; // Store a snapshot of where it's going

  Order({
    required this.id, required this.userId, required this.datePlaced,
    required this.totalAmount, required this.status, required this.items,
    required this.shippingAddress,
  });

  // Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'datePlaced': Timestamp.fromDate(datePlaced), // Firestore uses Timestamps
      'totalAmount': totalAmount,
      'status': status.name, // Converts enum to string (e.g., 'placed')
      'items': items.map((x) => x.toMap()).toList(),
      'shippingAddress': shippingAddress,
    };
  }

  // Read from Firestore Map
  factory Order.fromMap(Map<String, dynamic> map, String documentId) {
    // Safely parse the enum status
    OrderStatus parsedStatus = OrderStatus.placed;
    try {
      parsedStatus = OrderStatus.values.byName(map['status'] ?? 'placed');
    } catch (e) {
      // fallback if string doesn't match
    }

    return Order(
      id: documentId,
      userId: map['userId'] ?? '',
      datePlaced: (map['datePlaced'] as Timestamp).toDate(),
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      status: parsedStatus,
      items: List<OrderItem>.from(
          (map['items'] as List).map((x) => OrderItem.fromMap(x))
      ),
      shippingAddress: map['shippingAddress'] ?? {},
    );
  }
}