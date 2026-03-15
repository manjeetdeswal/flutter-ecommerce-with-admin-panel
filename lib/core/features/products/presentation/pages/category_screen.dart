import 'package:flutter/material.dart';

import 'category_products_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // A dummy list of categories to display
    // The complete list matching your Add Product screen!
    final List<Map<String, dynamic>> categories = [
      {'name': 'Mobiles', 'icon': Icons.smartphone, 'color': Colors.blue},
      {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Colors.pink},
      {'name': 'Electronics', 'icon': Icons.laptop_mac, 'color': Colors.grey},
      {'name': 'Home', 'icon': Icons.chair, 'color': Colors.orange},
      {'name': 'Beauty', 'icon': Icons.face_retouching_natural, 'color': Colors.purple},
      {'name': 'Appliances', 'icon': Icons.kitchen, 'color': Colors.teal},
      {'name': 'Toys', 'icon': Icons.toys, 'color': Colors.red},
      {'name': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.green},
      {'name': 'Groceries', 'icon': Icons.local_grocery_store, 'color': Colors.lightGreen},
      {'name': 'Furniture', 'icon': Icons.weekend, 'color': Colors.brown},
      {'name': 'Books', 'icon': Icons.menu_book, 'color': Colors.indigo},
      {'name': 'Jewelry', 'icon': Icons.diamond, 'color': Colors.amber},
      {'name': 'Watches', 'icon': Icons.watch, 'color': Colors.blueGrey},
      {'name': 'Shoes', 'icon': Icons.snowshoeing, 'color': Colors.deepOrange},
      {'name': 'Automotive', 'icon': Icons.directions_car, 'color': Colors.black87},
      {'name': 'Health', 'icon': Icons.health_and_safety, 'color': Colors.redAccent},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('All Categories'),
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 items across
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85, // Makes the cards slightly taller than wide
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryProductsScreen(categoryName: category['name'] as String),
                ),
              );  },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: (category['color'] as Color).withOpacity(0.1),
                    child: Icon(category['icon'] as IconData, size: 30, color: category['color'] as Color),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}