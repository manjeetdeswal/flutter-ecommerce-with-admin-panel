import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../providers/dependency_providers.dart';
import '../../domain/entities/product.dart';

// --- 1. THE ORIGINAL API PROVIDER ---
// Changed <List<ProductModel>> to <List<Product>>
final productsListProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getProducts();
});

// --- 2. SEARCH & CATEGORY STATE PROVIDERS ---
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// --- 3. THE MAGIC FILTER ---
// Changed <List<ProductModel>> to <List<Product>>
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {

  final productsState = ref.watch(productsListProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(selectedCategoryProvider)?.toLowerCase();

  return productsState.whenData((products) {
    return products.where((product) {

      final matchesSearch = product.name.toLowerCase().contains(searchQuery) ||
          product.brand.toLowerCase().contains(searchQuery);

      final matchesCategory = selectedCategory == null ||
          product.categoryId.toLowerCase().contains(selectedCategory) ||
          selectedCategory.contains(product.categoryId.toLowerCase());

      return matchesSearch && matchesCategory;

    }).toList();
  });
});