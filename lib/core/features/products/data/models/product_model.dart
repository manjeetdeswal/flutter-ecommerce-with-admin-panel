
import '../../domain/entities/product.dart';
import 'product_variant_model.dart';
import 'review_summary_model.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.sku,
    required super.name,
    required super.description,
    required super.brand,
    required super.categoryId,
    required super.sellerId,
    required super.originalPrice,
    required super.sellingPrice,
    required super.discountPercentage,
    required super.stockQuantity,
    required super.isAvailable,
    super.isEligibleForPrime,
    required super.imageUrls,
    super.videoUrl,
    required super.variants,
    required super.reviewSummary,
    required super.specifications,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      brand: json['brand'] as String,
      categoryId: json['categoryId'] as String,
      sellerId: json['sellerId'] as String,
      originalPrice: (json['originalPrice'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      stockQuantity: json['stockQuantity'] as int,
      isAvailable: json['isAvailable'] as bool,
      isEligibleForPrime: json['isEligibleForPrime'] as bool? ?? false,

      // Parse lists safely
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      videoUrl: json['videoUrl'] as String?,

      // Parse nested objects using their own fromJson methods
      variants: (json['variants'] as List<dynamic>?)
          ?.map((v) => ProductVariantModel.fromJson(v as Map<String, dynamic>))
          .toList() ?? [],

      reviewSummary: ReviewSummaryModel.fromJson(
          json['reviewSummary'] as Map<String, dynamic>),

      specifications: Map<String, String>.from(json['specifications'] ?? {}),

      // Parse Dates (Assuming standard ISO-8601 strings from a REST API)
      // Note: If using Firebase Firestore directly, you'd check for Timestamp objects here.
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'description': description,
      'brand': brand,
      'categoryId': categoryId,
      'sellerId': sellerId,
      'originalPrice': originalPrice,
      'sellingPrice': sellingPrice,
      'discountPercentage': discountPercentage,
      'stockQuantity': stockQuantity,
      'isAvailable': isAvailable,
      'isEligibleForPrime': isEligibleForPrime,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,

      // Convert nested objects back to JSON
      'variants': variants.map((v) => (v as ProductVariantModel).toJson()).toList(),
      'reviewSummary': (reviewSummary as ReviewSummaryModel).toJson(),
      'specifications': specifications,

      // Convert Dates to standard strings
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}