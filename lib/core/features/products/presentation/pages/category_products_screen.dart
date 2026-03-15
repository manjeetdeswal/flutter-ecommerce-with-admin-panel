import 'package:ecommerce_app_flutter/core/features/products/presentation/pages/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/review_summary.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryProductsScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // --- THE MAGIC FILTER ---
        // This tells Firestore: "Only give me products where the category matches this exact string!"
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('category', isEqualTo: categoryName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data?.docs ?? [];

          // What to show if the merchant hasn't added anything to this category yet
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No products found in $categoryName yet.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            );
          }

          // Build a beautiful grid of the filtered products
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7, // Adjusts the height of the product cards
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final data = products[index].data() as Map<String, dynamic>;

              // Safely grab the first image
              String imageUrl = 'https://via.placeholder.com/150';
              if (data['images'] != null && (data['images'] as List).isNotEmpty) {
                imageUrl = data['images'][0];
              }

              return InkWell(
                onTap: () {
                  // 1. Safely grab the images array
                  List<String> images = [];
                  if (data['images'] != null) {
                    images = List<String>.from(data['images']);
                  }

                  // 2. Map the raw Firebase data into your complex Product entity
                  final product = Product(
                    id: doc.id,
                    sku: data['sku'] ?? 'SKU-${doc.id.substring(0, 6).toUpperCase()}',
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
                    reviewSummary: ReviewSummary(averageRating: 0.0, totalReviews: 0, ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},),
                    specifications: {},
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  // 3. Push to your Product Details Screen!
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsScreen(product: product),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                          ),
                        ),
                      ),
                      // Product Details
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                data['title'] ?? 'Unknown',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis
                            ),
                            const SizedBox(height: 4),

                            // --- NEW: RATING ROW ---
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  // Safely grab the rating and format it to 1 decimal place (e.g., "4.5" or "0.0")
                                  (data['rating'] ?? 0.0).toDouble().toStringAsFixed(1),
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            Text(
                                '₹${data['price']}',
                                style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 16)
                            ),
                          ],
                        ),
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