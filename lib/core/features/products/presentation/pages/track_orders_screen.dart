import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TrackOrdersScreen extends StatelessWidget {
  const TrackOrdersScreen({super.key});

  // --- UPDATE ORDER STATUS LOGIC ---
  Future<void> _updateOrderStatus(BuildContext context, String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order updated to $newStatus! 🚀'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update order: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Live Orders'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      // --- REAL-TIME FIRESTORE STREAM ---
      // We order by date so the newest orders always pop up at the top!
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('datePlaced', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(
              child: Text('No orders yet. Keep marketing! 📈', style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;
              final orderId = doc.id;

              // Safely format the date
              String formattedDate = 'Unknown Date';
              if (data['datePlaced'] != null) {
                final timestamp = data['datePlaced'] as Timestamp;
                formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
              }

              final status = data['status'] ?? 'placed';
              final total = data['totalAmount'] ?? 0.0;
              final address = data['shippingAddress'] as Map<String, dynamic>? ?? {};

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER: ID & DATE ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('Order ID: ${orderId.substring(0, 8).toUpperCase()}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          _buildStatusBadge(status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(formattedDate, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      const Divider(height: 24),

                      // --- BODY: CUSTOMER & TOTAL ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                            child: Icon(Icons.person, color: Colors.green.shade700),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(address['fullName'] ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 2),
                                Text('${address['flatHouseNumber']}, ${address['areaStreet']}\n${address['townCity']}, ${address['state']} ${address['pincode']}',
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.3)),
                                const SizedBox(height: 4),
                                Text('Phone: ${address['mobileNumber'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                              ],
                            ),
                          ),
                          Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.deepPurple)),
                        ],
                      ),
                      const Divider(height: 24),

                      // --- FOOTER: ACTION BUTTONS ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Update Status:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          DropdownButton<String>(
                            value: status,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
                            items: const [
                              DropdownMenuItem(value: 'placed', child: Text('Placed', style: TextStyle(color: Colors.blue))),
                              DropdownMenuItem(value: 'shipped', child: Text('Shipped', style: TextStyle(color: Colors.orange))),
                              DropdownMenuItem(value: 'delivered', child: Text('Delivered', style: TextStyle(color: Colors.green))),
                              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled', style: TextStyle(color: Colors.red))),
                            ],
                            onChanged: (newStatus) {
                              if (newStatus != null && newStatus != status) {
                                _updateOrderStatus(context, orderId, newStatus);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper widget to make the status look like a professional pill badge
  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'placed': color = Colors.blue; break;
      case 'shipped': color = Colors.orange; break;
      case 'delivered': color = Colors.green; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
    );
  }
}