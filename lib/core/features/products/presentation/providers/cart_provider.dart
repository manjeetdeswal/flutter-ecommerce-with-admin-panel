import 'package:riverpod/riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/entities/product_variant.dart';

// The Notifier class manages a List of CartItems
class CartNotifier extends Notifier<List<CartItem>> {

  // Initialize with an empty cart
  @override
  List<CartItem> build() {
    return [];
  }

  // Add an item (or increase quantity if it's already there)
  void addToCart(Product product, [ProductVariant? variant]) {
    // Check if this exact product AND variant is already in the cart
    final existingIndex = state.indexWhere((item) =>
    item.product.id == product.id &&
        item.selectedVariant?.id == variant?.id
    );

    if (existingIndex >= 0) {
      // It exists! Increase the quantity.
      final existingItem = state[existingIndex];

      // We create a new list to trigger a UI rebuild (immutability)
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex)
            existingItem.copyWith(quantity: existingItem.quantity + 1)
          else
            state[i]
      ];
    } else {
      // It's a new item, add it to the list
      state = [...state, CartItem(product: product, selectedVariant: variant)];
    }
  }

  // Remove an item entirely
  void removeFromCart(String productId, [String? variantId]) {
    state = state.where((item) =>
    !(item.product.id == productId && item.selectedVariant?.id == variantId)
    ).toList();
  }

  // Update quantity directly (e.g., user types "5" into a text field)
  void updateQuantity(String productId, String? variantId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(productId, variantId);
      return;
    }

    state = [
      for (final item in state)
        if (item.product.id == productId && item.selectedVariant?.id == variantId)
          item.copyWith(quantity: newQuantity)
        else
          item
    ];
  }

  // Clear the whole cart (used after a successful checkout)
  void clearCart() {
    state = [];
  }
}

// The Provider we will use in our UI to access the CartNotifier
final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartProvider);

  double total = 0.0;
  for (final item in cartItems) {
    // Base price of the product
    double itemPrice = item.product.sellingPrice;

    // Add any extra cost if a variant was selected (e.g., +$50 for 512GB storage)
    if (item.selectedVariant?.priceAdjustment != null) {
      itemPrice += item.selectedVariant!.priceAdjustment!;
    }

    total += (itemPrice * item.quantity);
  }

  return total;
});