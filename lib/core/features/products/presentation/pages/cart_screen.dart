import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import 'checkout_screen.dart';
import 'main_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the cart items and the total price
    final cartItems = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        // A quick button to clear the whole cart
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear Cart',
              onPressed: () {
                ref.read(cartProvider.notifier).clearCart();
              },
            )
        ],
      ),

      // 2. Handle the Empty State gracefully
      body: cartItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Your cart is empty!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven\'t added anything yet.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => {ref.read(bottomNavIndexProvider.notifier).state = 0}, // Go back to products
              child: const Text('Start Shopping'),
            )
          ],
        ),
      )

      // 3. Build the List of Cart Items
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          final product = item.product;

          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: product.imageUrls.isNotEmpty
                        ? Image.network(
                      product.imageUrls.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80, height: 80, color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                        : Container( // Safely handle products with 0 images
                      width: 80, height: 80, color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Product Details & Quantity Controls
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\₹${product.sellingPrice.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),

                        // Quantity Adjuster (+ / -)
                        Row(
                          children: [
                            _QuantityButton(
                              icon: Icons.remove,
                              onPressed: () {
                                ref.read(cartProvider.notifier).updateQuantity(
                                  product.id,
                                  item.selectedVariant?.id,
                                  item.quantity - 1,
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            _QuantityButton(
                              icon: Icons.add,
                              onPressed: () {
                                ref.read(cartProvider.notifier).updateQuantity(
                                  product.id,
                                  item.selectedVariant?.id,
                                  item.quantity + 1,
                                );
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      ref.read(cartProvider.notifier).removeFromCart(
                          product.id, item.selectedVariant?.id);
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),

      // 4. Bottom Checkout Bar
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -4),
                blurRadius: 10,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total:', style: TextStyle(color: Colors.grey)),
                  Text(
                    '\₹${cartTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // Push the Checkout Screen we built earlier!
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckoutScreen(),
                    ),
                  );
                },
                child: const Text('Checkout'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// A helper widget to make the + and - buttons look clean
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}