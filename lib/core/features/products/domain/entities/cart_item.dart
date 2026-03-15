import 'package:ecommerce_app_flutter/core/features/products/domain/entities/product.dart';
import 'package:ecommerce_app_flutter/core/features/products/domain/entities/product_variant.dart';




class CartItem {
  final Product product;
  final ProductVariant? selectedVariant;
  final int quantity;

  CartItem({
    required this.product,
    this.selectedVariant,
    this.quantity = 1,
  });

  // A copyWith method is crucial for state management!
  // It allows us to update the quantity without mutating the original object.
  CartItem copyWith({
    Product? product,
    ProductVariant? selectedVariant,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      quantity: quantity ?? this.quantity,
    );
  }
}