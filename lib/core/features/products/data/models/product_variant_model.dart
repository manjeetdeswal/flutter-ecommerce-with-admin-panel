// lib/features/products/data/models/product_variant_model.dart

import '../../domain/entities/product_variant.dart';

class ProductVariantModel extends ProductVariant {
  ProductVariantModel({
    required super.id,
    required super.name,
    required super.value,
    super.priceAdjustment,
    required super.variantStock,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      value: json['value'] as String,
      // Handle potential nulls or integer-to-double conversions safely
      priceAdjustment: (json['priceAdjustment'] as num?)?.toDouble(),
      variantStock: json['variantStock'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'priceAdjustment': priceAdjustment,
      'variantStock': variantStock,
    };
  }
}

