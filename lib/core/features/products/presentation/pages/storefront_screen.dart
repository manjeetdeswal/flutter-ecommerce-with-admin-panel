import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/product_providers.dart';
import '../widgets/product_card.dart';
class StorefrontScreen extends ConsumerWidget {
  const StorefrontScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(filteredProductsProvider);
    final activeCategory = ref.watch(selectedCategoryProvider);

    // --- 1. CHECK IF SEARCHING ---
    // We grab the text and check if it has any letters in it
    final String searchText = ref.watch(searchQueryProvider);
    final bool isSearching = searchText.trim().isNotEmpty;

    final List<Map<String, dynamic>> categories = [
      {'name': 'Mobiles', 'icon': Icons.smartphone, 'color': Colors.blue},
      {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Colors.pink},
      {'name': 'Electronics', 'icon': Icons.laptop_mac, 'color': Colors.grey},
      {'name': 'Home', 'icon': Icons.chair, 'color': Colors.orange},
      {'name': 'Beauty', 'icon': Icons.face_retouching_natural, 'color': Colors.purple},
      {'name': 'Appliances', 'icon': Icons.kitchen, 'color': Colors.teal},
      {'name': 'Toys', 'icon': Icons.toys, 'color': Colors.red},
      {'name': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.green},
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. The Search Bar (Always Visible)
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
            title: Container(
              height: 40,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: TextField(
                // 1. Removed TextAlign.center so the cursor starts naturally on the left!
                onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
                decoration: const InputDecoration(
                  hintText: 'Search for products, brands...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),

                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8,),
                ),
              ),
            ),
          ),


          // These Slivers will completely vanish from the screen if isSearching is true!

          if (!isSearching)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 170,
                child: PageView(
                  controller: PageController(viewportFraction: 0.9),
                  children: [
                    _buildPromoBanner(title: 'BIG BILLION SALE\nUp to 50% OFF', color1: Colors.orange.shade400, color2: Colors.deepOrange.shade600),
                    _buildPromoBanner(title: 'WINTER COLLECTION\nFlat 30% OFF', color1: Colors.blue.shade400, color2: Colors.indigo.shade600),
                    _buildPromoBanner(title: 'TECH BLOWOUT\nNew Arrivals', color1: Colors.purple.shade400, color2: Colors.deepPurple.shade600),
                  ],
                ),
              ),
            ),

          if (!isSearching)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          final current = ref.read(selectedCategoryProvider);
                          if (current == category['name']) {
                            ref.read(selectedCategoryProvider.notifier).state = null;
                          } else {
                            ref.read(selectedCategoryProvider.notifier).state = category['name'] as String;
                          }
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: activeCategory == category['name']
                                  ? category['color'] as Color
                                  : (category['color'] as Color).withOpacity(0.1),
                              child: Icon(
                                category['icon'] as IconData,
                                color: activeCategory == category['name'] ? Colors.white : category['color'] as Color,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(category['name'] as String, style: TextStyle(fontSize: 12, fontWeight: activeCategory == category['name'] ? FontWeight.bold : FontWeight.normal)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Dynamic Title: Changes based on whether you are searching or not!
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                  isSearching ? 'Search Results' : 'Recommended For You',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              ),
            ),
          ),

          // 3. The Dynamic Product Grid (Always Visible)
          productsState.when(
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
            data: (products) {
              if (products.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: Text('No products found.', style: TextStyle(color: Colors.grey, fontSize: 16))),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.55,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) => ProductCard(product: products[index]), childCount: products.length),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildPromoBanner({required String title, required Color color1, required Color color2}) {
    return Container(
      margin: const EdgeInsets.only(right: 12, top: 16, bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: [color1, color2], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: color1.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Center(
        child: Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.2, height: 1.3)),
      ),
    );
  }
}