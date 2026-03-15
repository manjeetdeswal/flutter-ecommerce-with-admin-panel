import 'package:ecommerce_app_flutter/core/features/products/presentation/pages/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/review_summary.dart';
import 'add_product_screen.dart';

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  // --- DELETE LOGIC ---
  Future<void> _deleteProduct(BuildContext context, String productId) async {
    // 1. Show a safety confirmation dialog first!
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text('Are you sure you want to permanently delete this product from your store?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );

    // 2. If they clicked Delete, wipe it from Firestore
    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('products').doc(productId).delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Manage Products'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      // --- REAL-TIME FIRESTORE STREAM ---
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            return const Center(
              child: Text('No products found. Add some from the dashboard!', style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = products[index];
              final data = doc.data() as Map<String, dynamic>;
              final productId = doc.id;

              // Safely grab the first image
              String imageUrl = 'https://via.placeholder.com/150';
              if (data['images'] != null && (data['images'] as List).isNotEmpty) {
                imageUrl = data['images'][0];
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: ListTile(
                  onTap:() {
// 1. Safely grab the images array
                    List<String> images = [];
                    if (data['images'] != null) {
                      images = List<String>.from(data['images']);
                    }

                    // 2. Map the raw Firebase data into your Product entity
                    final product = Product(
                      id: productId,
                      sku: data['sku'] ?? 'SKU-${productId.substring(0, 6).toUpperCase()}',
                      name: data['title'] ?? 'Unknown Product',
                      description: data['description'] ?? '',
                      brand: data['brand'] ?? 'Generic',
                      categoryId: data['category'] ?? 'General',
                      sellerId: data['sellerId'] ?? 'MainStore',
                      originalPrice: (data['price'] ?? 0.0).toDouble(),
                      sellingPrice: (data['price'] ?? 0.0).toDouble(),
                      discountPercentage: 0.0,
                      stockQuantity: data['stock'] ?? 100,
                      isAvailable: (data['stock'] ?? 100) > 0,
                      isEligibleForPrime: true,
                      imageUrls: images.isNotEmpty ? images : ['https://via.placeholder.com/400'],
                      videoUrl: null,
                      variants: [],
                      reviewSummary: ReviewSummary(averageRating: 0.0, totalReviews: 0,ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},),
                      specifications: {},
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    // 3. Push to the Product Details Screen!
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(product: product),
                      ),
                    );
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(width: 50, height: 50, color: Colors.grey[300], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                    ),
                  ),
                  title: Text(data['title'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('₹${data['price']} • Stock: ${data['stock'] ?? 0}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Make sure the ID is explicitly attached to the data map so the edit screen can find it!
                          data['id'] = productId;

                          // Push to the AddProductScreen, but hand it the existing data!
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddProductScreen(productToEdit: data),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(context, productId),
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
}