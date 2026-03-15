// lib/features/home/presentation/pages/order_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/order.dart';
import '../providers/order_provider.dart';
import 'order_details_screen.dart';

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // 4. Add WidgetRef
    // 5. Watch the live data from Firestore!
    final orders = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Orders'),
        elevation: 0,
      ),
      // 6. Handle the empty state so the app doesn't look broken if they have no orders
      body: orders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No orders placed yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: orders.length, // Uses the real list length
        itemBuilder: (context, index) {
          final order = orders[index]; // Grabs the real order from Firebase
          return OrderCard(order: order);
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Format the date neatly
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final String formattedDate = dateFormat.format(order.datePlaced);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER: ID and Date (Overflow Fixed!) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Wrapped in Expanded to prevent pushing the date off-screen
                  Expanded(
                    child: Text(
                      "Order ID: ${order.id}",
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis, // Adds "..." if it's too long
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 2. The date stays intact on the right
                  Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const Divider(height: 24),

              // --- ITEM THUMBNAILS & SUMMARY ---
              Row(
                children: [
                  // Item thumbnails list (Horizontal scroll if many items)
                  SizedBox(
                    height: 50,
                    width: order.items.length > 2 ? 100 : order.items.length * 50.0,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: order.items.length,
                        itemBuilder: (context, itemIndex) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  order.items[itemIndex].productImageUrl,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 50, width: 50, color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
                                  ),
                                )
                            ),
                          );
                        }
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Summary text
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "${order.items.length} ${order.items.length == 1 ? 'Item' : 'Items'}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.items.map((e) => "${e.productName} (x${e.quantity})").join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          )
                        ],
                      )
                  )
                ],
              ),
              const SizedBox(height: 16),

              // --- FOOTER: Total and Status Badge ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "Total: \$${order.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  _buildStatusBadge(order.status),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build a colorful status badge
  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    String text;

    switch(status){
      case OrderStatus.placed:
        color = Colors.blue;
        text = 'Placed';
        break;
      case OrderStatus.shipped:
        color = Colors.orange;
        text = 'Shipped';
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        text = 'Delivered';
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6)
      ),
      child: Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)
      ),
    );
  }
}