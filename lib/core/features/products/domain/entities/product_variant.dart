
class ProductVariant {
  final String id;
  final String name; // e.g., "Color" or "Size"
  final String value; // e.g., "Matte Black" or "XL"
  final double? priceAdjustment; // e.g., +$50 for 512GB storage vs 256GB
  final int variantStock;

  ProductVariant({
    required this.id,
    required this.name,
    required this.value,
    this.priceAdjustment,
    required this.variantStock,
  });
}

