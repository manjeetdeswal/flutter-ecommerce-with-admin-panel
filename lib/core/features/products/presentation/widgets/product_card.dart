import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
// import '../../../cart/presentation/providers/cart_provider.dart'; // We'll move adding to cart to the details screen
import '../pages/product_details_screen.dart';

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rating = product.reviewSummary.averageRating;
    final reviews = product.reviewSummary.totalReviews;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      // INKWELL GOES HERE: Right inside the Card, wrapping the Column
      child: InkWell(
        onTap: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product),
            ),
          );

        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TOP HALF: Image & Badges ---
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Hero(
                    tag: 'product_image_${product.id}',
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(8.0),
                      child: product.imageUrls.isNotEmpty
                          ? Image.network(product.imageUrls.first, fit: BoxFit.contain)
                          : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  ),
                  if (product.discountPercentage > 0)
                    Positioned(
                      top: 0, left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)),
                        ),
                        child: Text(
                          '${product.discountPercentage.toInt()}% OFF',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4, right: 4,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                    ),
                  )
                ],
              ),
            ),

            // --- BOTTOM HALF: Details & Pricing ---
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.brand.toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.2)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            children: [
                              Text(rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              const Icon(Icons.star, color: Colors.white, size: 10),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('($reviews)', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\₹${product.sellingPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        if (product.originalPrice > product.sellingPrice)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: Text('\₹${product.originalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, decoration: TextDecoration.lineThrough)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text('Free Delivery', style: TextStyle(fontSize: 10, color: Colors.teal, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}