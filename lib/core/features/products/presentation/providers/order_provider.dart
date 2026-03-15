import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/order.dart';

class OrderNotifier extends StateNotifier<List<Order>> {
  OrderNotifier() : super([]) {
    fetchMyOrders();
  }

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // 1. FETCH ORDERS FOR THIS USER
  Future<void> fetchMyOrders() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Query the 'orders' collection where the userId matches the logged-in user
      // and order them by newest first!
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('datePlaced', descending: true)
          .get();

      final orders = snapshot.docs.map((doc) {
        return Order.fromMap(doc.data(), doc.id);
      }).toList();

      state = orders;
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  // 2. PLACE A NEW ORDER
  Future<bool> placeOrder(Order newOrder) async {
    try {
      // Create a new document in the 'orders' collection
      await _firestore.collection('orders').doc(newOrder.id).set(newOrder.toMap());

      // Refresh the local list so the UI updates
      await fetchMyOrders();
      return true; // Success!
    } catch (e) {
      print("Error placing order: $e");
      return false; // Failed
    }
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<Order>>((ref) {
  return OrderNotifier();
});