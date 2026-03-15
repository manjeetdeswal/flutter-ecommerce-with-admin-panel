// lib/features/merchant/presentation/pages/merchant_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Make sure all your screens are imported!
import 'add_product_screen.dart';
import 'manage_products_screen.dart';
import 'track_orders_screen.dart';
import 'store_settings_screen.dart';
// Note: Your app handles the logout routing automatically via AuthGuard!

class MerchantDashboardScreen extends StatelessWidget {
  const MerchantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Merchant Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. RECENT PRODUCTS SECTION ---
            Container(
              color: Colors.deepPurple,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      'Recently Added',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 12),

                  // Real-time Stream from Firestore
                  StreamBuilder<QuerySnapshot>(
                    // We grab the latest 5 products (If you added a timestamp, you could .orderBy() here!)
                    stream: FirebaseFirestore.instance.collection('products').limit(5).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(color: Colors.white)));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Center(
                            child: Text('No products yet. Add your first one below!', style: TextStyle(color: Colors.white70)),
                          ),
                        );
                      }

                      final products = snapshot.data!.docs;

                      return SizedBox(
                        height: 140, // Height of the horizontal list
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final data = products[index].data() as Map<String, dynamic>;

                            // Safely grab the first image
                            String imageUrl = 'https://via.placeholder.com/150';
                            if (data['images'] != null && (data['images'] as List).isNotEmpty) {
                              imageUrl = data['images'][0];
                            }

                            return Container(
                              width: 110,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.network(
                                      imageUrl,
                                      height: 80,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Container(height: 80, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(data['title'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        Text('₹${data['price']}', style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // --- 2. QUICK ACTIONS GRID ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // We wrap the GridView so it plays nicely inside the SingleChildScrollView
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // Disables inner scrolling
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildDashboardCard(
                        context,
                        title: 'Add Product',
                        icon: Icons.add_box,
                        color: Colors.blue,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen())),
                      ),
                      _buildDashboardCard(
                        context,
                        title: 'Manage Products',
                        icon: Icons.inventory,
                        color: Colors.orange,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageProductsScreen())),
                      ),
                      _buildDashboardCard(
                        context,
                        title: 'Track Orders',
                        icon: Icons.local_shipping,
                        color: Colors.green,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TrackOrdersScreen())),
                      ),
                      _buildDashboardCard(
                        context,
                        title: 'Store Settings',
                        icon: Icons.store,
                        color: Colors.grey,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StoreSettingsScreen())),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Same card UI as before, perfectly intact!
  Widget _buildDashboardCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 30, backgroundColor: color.withOpacity(0.1), child: Icon(icon, size: 30, color: color)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}