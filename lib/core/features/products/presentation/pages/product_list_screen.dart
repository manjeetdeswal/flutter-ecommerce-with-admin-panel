// lib/features/products/presentation/pages/product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_providers.dart';
// Assume you have a ProductCard widget built
// import '../widgets/product_card.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We "watch" the FutureProvider. The UI will rebuild when the state changes.
    final productsState = ref.watch(productsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // TODO: Navigate to Cart
            },
          )
        ],
      ),
      // The .when method maps the AsyncValue to widgets
      body: productsState.when(
        // 1. LOADING STATE
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        // 2. ERROR STATE
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Oops! Something went wrong:\n$error', textAlign: TextAlign.center),
              ElevatedButton(
                // Refresh the provider to try the API call again!
                onPressed: () => ref.refresh(productsListProvider),
                child: const Text('Retry'),
              )
            ],
          ),
        ),

        // 3. SUCCESS STATE (Data is loaded)
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: Column(
                  children: [
                    Expanded(child: Image.network(product.imageUrls.first)),
                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('\$${product.sellingPrice}'),
                  ],
                ),
              );
              // In reality, use: return ProductCard(product: product);
            },
          );
        },
      ),
    );
  }
}