// lib/features/merchant/presentation/pages/add_product_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? productToEdit;
  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  // --- DYNAMIC IMAGE FIELDS ---
  // List of text controllers for manual URLs
  final List<TextEditingController> _urlControllers = [];

  // List of physical files picked from the phone
  final List<File> _pickedImages = [];
  final ImagePicker _picker = ImagePicker();

  String _selectedCategory = 'Mobiles';
  final List<String> _categories = [
    'Mobiles', 'Fashion', 'Electronics', 'Home', 'Beauty',
    'Appliances', 'Toys', 'Sports', 'Groceries', 'Furniture',
    'Books', 'Jewelry', 'Watches', 'Shoes', 'Automotive', 'Health'
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      final p = widget.productToEdit!;
      _nameController.text = p['title'] ?? '';
      _brandController.text = p['brand'] ?? '';
      _descController.text = p['description'] ?? '';
      _priceController.text = (p['price'] ?? 0.0).toString();

      if (p['category'] != null && _categories.contains(p['category'])) {
        _selectedCategory = p['category'];
      }

      // Load existing images into separate text boxes!
      if (p['images'] != null) {
        for (String url in p['images']) {
          _urlControllers.add(TextEditingController(text: url));
        }
      }
    }

    // Always start with at least one empty text box if there are none
    if (_urlControllers.isEmpty) {
      _urlControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descController.dispose();
    _priceController.dispose();
    for (var controller in _urlControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- GALLERY PICKER LOGIC ---
  Future<void> _pickImagesFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        for (var image in images) {
          _pickedImages.add(File(image.path));
        }
      });
    }
  }

  // --- CLOUD STORAGE UPLOAD LOGIC ---
  Future<List<String>> _uploadLocalImages(String productId) async {
    List<String> uploadedUrls = [];
    for (int i = 0; i < _pickedImages.length; i++) {
      File imageFile = _pickedImages[i];
      // Create a unique path in Firebase Storage
      final ref = FirebaseStorage.instance.ref().child('product_images/$productId/img_$i.jpg');

      // Upload the file
      await ref.putFile(imageFile);

      // Ask Storage for the public URL we just created
      final url = await ref.getDownloadURL();
      uploadedUrls.add(url);
    }
    return uploadedUrls;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final String productId = widget.productToEdit != null
          ? widget.productToEdit!['id']
          : const Uuid().v4();

      // 1. Gather all the manually typed URLs
      List<String> finalImageUrls = _urlControllers
          .map((c) => c.text.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      // 2. Upload any local phone photos to Cloud Storage and get their new URLs
      if (_pickedImages.isNotEmpty) {
        final uploadedUrls = await _uploadLocalImages(productId);
        finalImageUrls.addAll(uploadedUrls); // Combine them!
      }

      final productData = {
        'id': productId,
        'title': _nameController.text.trim(),
        'brand': _brandController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'category': _selectedCategory,
        'images': finalImageUrls,
        'stock': widget.productToEdit != null ? widget.productToEdit!['stock'] : 100,
        'rating': widget.productToEdit != null ? widget.productToEdit!['rating'] : 0.0,
      };

      if (widget.productToEdit != null) {
        await FirebaseFirestore.instance.collection('products').doc(productId).update(productData);
      } else {
        await FirebaseFirestore.instance.collection('products').doc(productId).set(productData);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.productToEdit != null ? 'Product updated! ✏️' : 'Product added successfully! 🎉'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);

    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save product: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.productToEdit != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Basic Details'),
              _buildTextField(controller: _nameController, label: 'Product Name', icon: Icons.shopping_bag),
              const SizedBox(height: 12),
              _buildTextField(controller: _brandController, label: 'Brand', icon: Icons.branding_watermark),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Pricing'),
              _buildTextField(controller: _priceController, label: 'Price (₹)', icon: Icons.currency_rupee, isNumber: true),
              const SizedBox(height: 24),

              // --- DYNAMIC IMAGES SECTION ---
              _buildSectionTitle('Product Images'),

              // 1. Gallery Upload Button
              ElevatedButton.icon(
                onPressed: _pickImagesFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Select Photos from Device'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade50, foregroundColor: Colors.blue.shade700, elevation: 0),
              ),

              // Preview local images if any were picked
              if (_pickedImages.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _pickedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(image: FileImage(_pickedImages[index]), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: -10, right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => setState(() => _pickedImages.removeAt(index)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Text('Or paste image URLs:', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),

              // 2. Dynamic Text Fields
              ...List.generate(_urlControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _urlControllers[index],
                          label: 'Image URL ${index + 1}',
                          icon: Icons.link,
                        ),
                      ),
                      if (_urlControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => setState(() => _urlControllers.removeAt(index)),
                        ),
                    ],
                  ),
                );
              }),

              TextButton.icon(
                onPressed: () => setState(() => _urlControllers.add(TextEditingController())),
                icon: const Icon(Icons.add),
                label: const Text('Add another URL'),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Description'),
              _buildTextField(controller: _descController, label: 'Product Description', icon: Icons.description, maxLines: 4),
              const SizedBox(height: 32),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSaving ? null : _saveProduct,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditing ? 'Update Product' : 'Save Product', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 12, left: 4), child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])));
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon), filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Please enter $label';
        if (isNumber && double.tryParse(value) == null) return 'Please enter a valid number';
        return null;
      },
    );
  }
}