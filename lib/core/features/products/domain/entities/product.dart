

import 'package:ecommerce_app_flutter/core/features/products/domain/entities/product_variant.dart';
import 'package:ecommerce_app_flutter/core/features/products/domain/entities/review_summary.dart';

class Product {
  // Core Identifiers
  final String id;
  final String sku; // Stock Keeping Unit (crucial for inventory)

  // Basic Info
  final String name;
  final String description;
  final String brand;
  final String categoryId;
  final String sellerId; // Crucial for multi-vendor apps like Amazon/eBay

  // Pricing & Discounts
  final double originalPrice;
  final double sellingPrice; // The price after discounts
  final double discountPercentage;

  // Inventory & Shipping
  final int stockQuantity;
  final bool isAvailable;
  final bool isEligibleForPrime; // Or express/free shipping

  // Media
  final List<String> imageUrls; // Array of images, not just one
  final String? videoUrl; // Optional video demonstration

  // Complex Data
  final List<ProductVariant> variants; // e.g., sizes, colors
  final ReviewSummary reviewSummary;
  final Map<String, String> specifications; // e.g., {"RAM": "8GB", "Storage": "256GB"}

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.description,
    required this.brand,
    required this.categoryId,
    required this.sellerId,
    required this.originalPrice,
    required this.sellingPrice,
    required this.discountPercentage,
    required this.stockQuantity,
    required this.isAvailable,
    this.isEligibleForPrime = false,
    required this.imageUrls,
    this.videoUrl,
    required this.variants,
    required this.reviewSummary,
    required this.specifications,
    required this.createdAt,
    required this.updatedAt,
  });
}