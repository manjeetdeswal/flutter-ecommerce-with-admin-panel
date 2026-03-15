import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/order.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final String formattedDate = dateFormat.format(order.datePlaced);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. ORDER ID & STATUS HEADER ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order ID: ${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      _buildStatusBadge(order.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Placed on $formattedDate', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 2. ITEMS LIST ---
            const Text('Items in this order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)]),
              child: ListView.separated(
                shrinkWrap: true, // Needed inside SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(), // Disables inner scrolling
                itemCount: order.items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.productImageUrl, height: 60, width: 60, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(height: 60, width: 60, color: Colors.grey[300], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('Qty: ${item.quantity}', style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text('\$${(item.pricePerUnit * item.quantity).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // --- 3. SHIPPING ADDRESS ---
            const Text('Shipping Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.shippingAddress['fullName'] ?? 'Unknown Name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("${order.shippingAddress['flatHouseNumber']}, ${order.shippingAddress['areaStreet']}", style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
                  Text("${order.shippingAddress['townCity']}, ${order.shippingAddress['state']} ${order.shippingAddress['pincode']}", style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
                  const SizedBox(height: 8),
                  Text("Phone: ${order.shippingAddress['mobileNumber']}", style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 4. ORDER SUMMARY ---
            const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)]),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount Paid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('\$${order.totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color; String text;
    switch(status){
      case OrderStatus.placed: color = Colors.blue; text = 'Placed'; break;
      case OrderStatus.shipped: color = Colors.orange; text = 'Shipped'; break;
      case OrderStatus.delivered: color = Colors.green; text = 'Delivered'; break;
      case OrderStatus.cancelled: color = Colors.red; text = 'Cancelled'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}