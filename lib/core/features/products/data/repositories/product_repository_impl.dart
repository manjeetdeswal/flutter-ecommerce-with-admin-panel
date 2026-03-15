import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';

import '../../domain/entities/review_summary.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // We don't need the remoteDataSource anymore since we are calling Firebase directly!
  ProductRepositoryImpl();

  @override
  Future<List<Product>> getProducts() async {
    try {
      // 1. Ask Firestore for EVERYTHING in the products collection
      final snapshot = await _firestore.collection('products').get();

      // 2. Loop through the Firestore documents and map them to your complex Product entity
      return snapshot.docs.map((doc) {
        final data = doc.data();

        // Safely parse the images array we created in the Add Product screen
        List<String> images = [];
        if (data['images'] != null) {
          images = List<String>.from(data['images']);
        }

        return Product(
          id: data['id'] ?? doc.id,
          sku: data['sku'] ?? 'SKU-${doc.id.substring(0, 6).toUpperCase()}', // Auto-generate a fake SKU if missing
          name: data['title'] ?? 'Unknown Product',
          description: data['description'] ?? '',
          brand: data['brand'] ?? 'Generic',
          categoryId: data['category'] ?? 'General',
          sellerId: data['sellerId'] ?? 'MainStore',
          originalPrice: (data['price'] ?? 0.0).toDouble(),
          sellingPrice: (data['price'] ?? 0.0).toDouble(), // Same as original until you add a discount feature
          discountPercentage: 0.0,
          stockQuantity: data['stock'] ?? 100,
          isAvailable: (data['stock'] ?? 100) > 0,
          isEligibleForPrime: true, // Let's make everything Prime for now!
          imageUrls: images.isNotEmpty ? images : ['https://via.placeholder.com/400'],
          videoUrl: null,
          variants: [], // Empty list until you build a Variants feature

          // IMPORTANT: If your ReviewSummary class uses different variable names
          // (like 'rating' instead of 'averageRating'), you will need to tweak this line!
          reviewSummary: ReviewSummary(averageRating: 0.0, totalReviews: 0, ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},),

          specifications: {}, // Empty map for now
          createdAt: DateTime.now(), // Fallback dates
          updatedAt: DateTime.now(),
        );
      }).toList();

    } catch (e) {
      throw Exception('Failed to load products from Firebase: $e');
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (!doc.exists) throw Exception('Product not found');

      // If you need this later, you would copy the exact same mapping logic from above here!
      throw UnimplementedError('Mapping logic needed here');
    } catch (e) {
      throw Exception('Could not fetch product with ID: $id');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    throw UnimplementedError();
  }
}