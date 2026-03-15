import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../providers/cart_provider.dart';
import 'account_screen.dart';
import 'cart_screen.dart';
import 'category_screen.dart';
import 'storefront_screen.dart'; // We will build this next!

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cart_provider.dart';
import 'account_screen.dart';
import 'cart_screen.dart';
import 'category_screen.dart';
import 'storefront_screen.dart';


final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainScreen extends ConsumerWidget { // Changed to ConsumerWidget!
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Watch the current tab index
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final cartItemCount = ref.watch(cartProvider).length;

    final List<Widget> screens = [
      const StorefrontScreen(),
      const CategoryScreen(),
      const CartScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex, // Uses the provider's index
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        // 3. Update the provider when a user taps a bottom icon
        onDestinationSelected: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          const NavigationDestination(icon: Icon(Icons.category_outlined), selectedIcon: Icon(Icons.category), label: 'Categories'),
          NavigationDestination(
            icon: Badge(
              label: Text(cartItemCount.toString()),
              isLabelVisible: cartItemCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              label: Text(cartItemCount.toString()),
              isLabelVisible: cartItemCount > 0,
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}