// lib/features/products/presentation/pages/product_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/product.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'full_screen_image_gallery.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  bool _isMerchant = false;
  String _currentUserName = 'Customer';

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  // --- 1. CHECK IF THE VIEWER IS A MERCHANT ---
  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted && doc.exists) {
        final data = doc.data()!;

        // Default to email prefix if no address is found
        String fetchedName = user.email?.split('@')[0] ?? 'Customer';

        // Try to dig into the address map to find their actual full name
        if (data.containsKey('address') && data['address'] != null) {
          fetchedName = data['address']['fullName'] ?? fetchedName;
        } else if (data.containsKey('shippingAddress') && data['shippingAddress'] != null) {
          fetchedName = data['shippingAddress']['fullName'] ?? fetchedName;
        }

        setState(() {
          _isMerchant = data['role'] == 'merchant';
          _currentUserName = fetchedName;
        });
      }
    }
  }

  // --- 2. ADD A REVIEW (CUSTOMER) ---
  void _showAddReviewDialog() {
    int selectedRating = 5;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Write a Review'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(index < selectedRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
                          onPressed: () => setDialogState(() => selectedRating = index + 1),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reviewController,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'What did you think about this product?', border: OutlineInputBorder()),
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () async {
                      if (reviewController.text.trim().isEmpty) return;

                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;

                      // Save the review to a sub-collection inside this specific product
                      await FirebaseFirestore.instance
                          .collection('products')
                          .doc(widget.product.id)
                          .collection('reviews')
                          .add({
                        'userId': user.uid,
                        'userName': _currentUserName,
                        'rating': selectedRating,
                        'text': reviewController.text.trim(),
                        'createdAt': FieldValue.serverTimestamp(),
                        'merchantReply': null, // Empty for now!
                      });

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted!'), backgroundColor: Colors.green));
                      }
                    },
                    child: const Text('Submit'),
                  )
                ],
              );
            }
        );
      },
    );
  }

  // --- 4. EDIT A REVIEW (CUSTOMER) ---
  void _showEditReviewDialog(String reviewId, int currentRating, String currentText) {
    int selectedRating = currentRating;
    final reviewController = TextEditingController(text: currentText); // Pre-fill their old text!

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Edit Your Review'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(index < selectedRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
                          onPressed: () => setDialogState(() => selectedRating = index + 1),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reviewController,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Update your thoughts...', border: OutlineInputBorder()),
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () async {
                      if (reviewController.text.trim().isEmpty) return;

                      // Update the specific review document
                      await FirebaseFirestore.instance
                          .collection('products')
                          .doc(widget.product.id)
                          .collection('reviews')
                          .doc(reviewId)
                          .update({
                        'rating': selectedRating,
                        'text': reviewController.text.trim(),
                        'isEdited': true, // A nice flag to have in the database!
                      });

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review updated! ✏️'), backgroundColor: Colors.blue));
                      }
                    },
                    child: const Text('Update'),
                  )
                ],
              );
            }
        );
      },
    );
  }

  // --- 3. REPLY TO A REVIEW (MERCHANT) ---
  void _showReplyDialog(String reviewId) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reply to Customer'),
          content: TextField(
            controller: replyController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Type your response here...', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (replyController.text.trim().isEmpty) return;

                // Update the specific review with the merchant's reply
                await FirebaseFirestore.instance
                    .collection('products')
                    .doc(widget.product.id)
                    .collection('reviews')
                    .doc(reviewId)
                    .update({
                  'merchantReply': replyController.text.trim(),
                });

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reply posted!'), backgroundColor: Colors.green));
                }
              },
              child: const Text('Post Reply'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(product.brand),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final cartItems = ref.watch(cartProvider);
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
                  ),
                  if (cartItems.isNotEmpty)
                    Positioned(
                      right: 8, top: 8,
                      child: CircleAvatar(
                        radius: 8, backgroundColor: Colors.red,
                        child: Text(cartItems.length.toString(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                      ),
                    ),
                ],
              );
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. PHOTO SLIDER ---
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Hero(
                    tag: 'product_image_${product.id}',
                    child: SizedBox(
                      height: 350, width: double.infinity,
                      child: PageView.builder(
                        itemCount: product.imageUrls.isNotEmpty ? product.imageUrls.length : 1,
                        onPageChanged: (index) => setState(() => _currentImageIndex = index),
                        itemBuilder: (context, index) {
                          if (product.imageUrls.isEmpty) {
                            return Container(color: Colors.grey[300], child: const Icon(Icons.image_not_supported, size: 50));
                          }
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => FullScreenImageGallery(imageUrls: product.imageUrls, initialIndex: index),
                              ));
                            },
                            child: Padding(padding: const EdgeInsets.all(16.0), child: Image.network(product.imageUrls[index], fit: BoxFit.contain)),
                          );
                        },
                      ),
                    ),
                  ),
                  if (product.imageUrls.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        product.imageUrls.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                          width: _currentImageIndex == index ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(color: _currentImageIndex == index ? Theme.of(context).primaryColor : Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // --- 2. PRODUCT DETAILS ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                        child: Row(
                          children: [
                            Text(product.reviewSummary.averageRating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const Icon(Icons.star, color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${product.reviewSummary.totalReviews} Ratings & Reviews', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${product.sellingPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      if (product.originalPrice > product.sellingPrice)
                        Text('₹${product.originalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                      const SizedBox(width: 8),
                      if (product.discountPercentage > 0)
                        Text('${product.discountPercentage.toInt()}% OFF', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // --- 3. DESCRIPTION ---
            Container(
              color: Colors.white, width: double.infinity, padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Product Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(product.description, style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // --- 4. REAL-TIME REVIEWS & RATINGS ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              // We moved the StreamBuilder up so it controls the "Write a Review" button too!
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .doc(product.id)
                    .collection('reviews')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final reviews = snapshot.data?.docs ?? [];
                  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

                  // --- NEW CHECK: Has this user already reviewed the product? ---
                  bool hasReviewed = false;
                  for (var doc in reviews) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['userId'] == currentUserId) {
                      hasReviewed = true;
                      break;
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ratings & Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          // Only show the Write button if they are NOT a merchant AND they HAVEN'T reviewed yet!
                          if (!_isMerchant && !hasReviewed)
                            TextButton.icon(
                              onPressed: _showAddReviewDialog,
                              icon: const Icon(Icons.rate_review),
                              label: const Text('Write a Review'),
                            )
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (reviews.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(child: Text('No reviews yet. Be the first!', style: TextStyle(color: Colors.grey))),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reviews.length,
                          separatorBuilder: (context, index) => const Divider(height: 32),
                          itemBuilder: (context, index) {
                            final doc = reviews[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final rating = data['rating'] ?? 5;
                            final merchantReply = data['merchantReply'];

                            // Check if this specific review belongs to the logged-in user
                            final isMyReview = data['userId'] == currentUserId;

                            // Format the date
                            String dateStr = 'Just now';
                            if (data['createdAt'] != null) {
                              dateStr = DateFormat('MMM dd, yyyy').format((data['createdAt'] as Timestamp).toDate());
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.primaries[index % Colors.primaries.length],
                                      radius: 16,
                                      child: Text(data['userName'].toString().substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(data['userName'] ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.bold)),

                                    const Spacer(),

                                    // --- THE EDIT BUTTON ---
                                    if (isMyReview)
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(), // Makes the button compact
                                        icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                                        onPressed: () => _showEditReviewDialog(doc.id, rating, data['text'] ?? ''),
                                      ),
                                    if (isMyReview) const SizedBox(width: 8),

                                    Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: List.generate(5, (i) => Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 16)),
                                ),
                                const SizedBox(height: 8),
                                Text(data['text'] ?? ''),

                                // --- MERCHANT REPLY BOX ---
                                if (merchantReply != null && merchantReply.toString().isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(top: 12, left: 16),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.store, size: 14, color: Colors.deepPurple),
                                            SizedBox(width: 4),
                                            Text('Response from Merchant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.deepPurple)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(merchantReply, style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
                                      ],
                                    ),
                                  ),

                                // --- REPLY BUTTON (ONLY FOR MERCHANTS) ---
                                if (_isMerchant && (merchantReply == null || merchantReply.toString().isEmpty))
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => _showReplyDialog(doc.id),
                                      child: const Text('Reply to Customer'),
                                    ),
                                  )
                              ],
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),

      // --- 5. BOTTOM BAR ---
      // (Hidden if the user is a merchant so they don't buy their own stuff!)
      bottomNavigationBar: _isMerchant ? null : SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, -2))]),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: Theme.of(context).primaryColor)),
                  onPressed: () {
                    ref.read(cartProvider.notifier).addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Cart!'), backgroundColor: Colors.green));
                  },
                  child: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () {
                    ref.read(cartProvider.notifier).addToCart(product);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                  },
                  child: const Text('Buy Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}