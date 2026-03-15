import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/review_summary_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;

  ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ProductModel>> getProducts() async {
    // 1. Fetch from the API
    final response = await client.get(
      Uri.parse('https://dummyjson.com/products'),
      headers: {'Content-Type': 'application/json'},
    );

    // PATH A: API is successful (We return the list)
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body)['products'];

      return jsonList.map((json) {
        double price = (json['price'] as num).toDouble();
        double discount = (json['discountPercentage'] as num?)?.toDouble() ?? 0.0;

        // --- THE UI HACK ---
        List<String> parsedImages = List<String>.from(json['images'] ?? []);
        if (parsedImages.length == 1) {
          parsedImages = [parsedImages[0], parsedImages[0], parsedImages[0]];
        }

        return ProductModel(
          id: json['id'].toString(),
          sku: 'SKU-${json['id']}',
          name: json['title'] ?? 'Unknown',
          description: json['description'] ?? '',
          brand: json['brand'] ?? 'Generic',
          categoryId: json['category'] ?? 'general',
          sellerId: 'dummy_seller',
          originalPrice: price + (price * (discount / 100)),
          sellingPrice: price,
          discountPercentage: discount,
          stockQuantity: json['stock'] ?? 0,
          isAvailable: (json['stock'] ?? 0) > 0,
          imageUrls: parsedImages,
          variants: [],
          reviewSummary: ReviewSummaryModel(
            averageRating: (json['rating'] as num?)?.toDouble() ?? 0.0,
            totalReviews: 124,
            ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
          ),
          specifications: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();
    }
    
    else {
      throw Exception('Failed to load products. Status Code: ${response.statusCode}');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    // You can implement this similarly using 'https://dummyjson.com/products/$id'
    throw UnimplementedError();
  }
}