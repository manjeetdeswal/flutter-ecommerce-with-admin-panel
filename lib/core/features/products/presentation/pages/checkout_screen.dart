// lib/features/home/presentation/pages/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../providers/cart_provider.dart';
import '../providers/address_provider.dart';
import '../providers/order_provider.dart';
import '../../domain/entities/order.dart';
import 'main_screen.dart';
import 'address_management_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  // Payment State
  String _selectedPaymentMethod = 'upi';
  late Razorpay _razorpay;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    // Attach Razorpay event listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // --- RAZORPAY LISTENERS ---

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment worked! Now save the order to Firestore
    _saveOrderToFirebase(paymentId: response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}'), backgroundColor: Colors.red),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet Selected: ${response.walletName}')),
    );
  }

  // --- FIRESTORE SAVING LOGIC ---

  Future<void> _saveOrderToFirebase({String? paymentId}) async {
    final cartItems = ref.read(cartProvider);
    final cartTotal = ref.read(cartTotalProvider);
    final addresses = ref.read(addressProvider);
    final user = FirebaseAuth.instance.currentUser;

    final defaultAddresses = addresses.where((a) => a.isDefault).toList();
    if (defaultAddresses.isEmpty || user == null) return;

    final deliveryAddress = defaultAddresses.first;

    // Convert CartItems to OrderItems
    final orderItems = cartItems.map((item) {
      return OrderItem(
        productId: item.product.id,
        productName: item.product.name,
        productImageUrl: item.product.imageUrls.isNotEmpty ? item.product.imageUrls.first : '',
        quantity: item.quantity,
        pricePerUnit: item.product.sellingPrice,
      );
    }).toList();

    // Create the Order Object
    final newOrder = Order(
      id: const Uuid().v4().substring(0, 12).toUpperCase(),
      userId: user.uid,
      datePlaced: DateTime.now(),
      // Add tax & shipping to final Firestore amount just like your UI shows
      totalAmount: cartTotal + 5.00 + (cartTotal * 0.18),
      status: OrderStatus.placed,
      items: orderItems,
      shippingAddress: deliveryAddress.toMap(),
    );

    // Save to Firestore!
    final success = await ref.read(orderProvider.notifier).placeOrder(newOrder);

    setState(() => _isProcessing = false);

    if (success) {
      ref.read(cartProvider.notifier).clearCart(); // Empty the cart
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully! 🎉'), backgroundColor: Colors.green),
      );

      // Send them to the Home Screen
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save order to database.'), backgroundColor: Colors.red),
      );
    }
  }

  // --- BUTTON CLICK LOGIC ---

  Future<void> _processOrder(double totalAmount) async {
    // Validation: Check for address
    final addresses = ref.read(addressProvider);
    if (addresses.where((a) => a.isDefault).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a delivery address!'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isProcessing = true);

    if (_selectedPaymentMethod == 'cod') {
      // If COD, skip Razorpay and go straight to Firestore
      await _saveOrderToFirebase(paymentId: 'COD');
    } else {
      // If UPI or Card, trigger Razorpay
      try {
        final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('createRazorpayOrder');
        final response = await callable.call(<String, dynamic>{
          'amount': totalAmount,
          'receiptId': 'receipt_${DateTime.now().millisecondsSinceEpoch}',
        });

        final String backendOrderId = response.data['orderId'];
        _openRazorpayCheckout(totalAmount, backendOrderId);
      } catch (e) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to initialize payment: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _openRazorpayCheckout(double totalAmount, String backendOrderId) {
    int amountInPaise = (totalAmount * 100).toInt();
    final user = FirebaseAuth.instance.currentUser;

    var options = {
      'key': 'rzp_test_YourPublicKeyHere', // REMEMBER TO PUT YOUR TEST KEY HERE!
      'amount': amountInPaise,
      'name': 'My E-Commerce App',
      'description': 'Order Payment',
      'order_id': backendOrderId,
      'timeout': 300,
      'prefill': {
        'contact': '9876543210',
        'email': user?.email ?? 'user@example.com'
      },
      'external': { 'wallets': ['paytm'] }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessing = false);
      debugPrint('Error opening Razorpay: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartTotal = ref.watch(cartTotalProvider);
    final addresses = ref.watch(addressProvider);

    final defaultAddresses = addresses.where((a) => a.isDefault).toList();
    final defaultAddress = defaultAddresses.isNotEmpty ? defaultAddresses.first : null;

    const double shippingCost = 5.00;
    final double tax = cartTotal * 0.18;
    final double finalTotal = cartTotal + shippingCost + tax;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Checkout'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. SHIPPING ADDRESS ---
            const Text('Shipping Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: defaultAddress != null
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(defaultAddress.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressManagementScreen())), child: const Text('Change'))
                      ],
                    ),
                    Text("${defaultAddress.flatHouseNumber}, ${defaultAddress.areaStreet}", style: TextStyle(color: Colors.grey.shade700)),
                    Text("${defaultAddress.townCity}, ${defaultAddress.state} ${defaultAddress.pincode}", style: TextStyle(color: Colors.grey.shade700)),
                  ],
                )
                    : Center(
                  child: TextButton.icon(icon: const Icon(Icons.add_location_alt), label: const Text('Add Delivery Address'), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressManagementScreen()))),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- 2. PAYMENT METHOD RADIO BUTTONS ---
            const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('UPI (GPay, PhonePe, Paytm)'),
                    secondary: const Icon(Icons.qr_code_scanner, color: Colors.green),
                    value: 'upi', groupValue: _selectedPaymentMethod,
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Credit / Debit Card'),
                    secondary: const Icon(Icons.credit_card, color: Colors.blue),
                    value: 'card', groupValue: _selectedPaymentMethod,
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Cash on Delivery'),
                    secondary: const Icon(Icons.money, color: Colors.orange),
                    value: 'cod', groupValue: _selectedPaymentMethod,
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 3. SUMMARY ---
            const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _SummaryRow(label: 'Subtotal', value: '\₹${cartTotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    const _SummaryRow(label: 'Shipping', value: '\₹5.00'),
                    const SizedBox(height: 8),
                    _SummaryRow(label: 'Tax (18%)', value: '\₹${tax.toStringAsFixed(2)}'),
                    const Divider(height: 24, thickness: 1),
                    _SummaryRow(label: 'Total', value: '\₹${finalTotal.toStringAsFixed(2)}', isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),

      // --- 4. BOTTOM PAY BUTTON ---
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10)]),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isProcessing ? null : () => _processOrder(finalTotal),
            child: _isProcessing
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Proceed to Pay  •  \₹${finalTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.black : Colors.grey[700])),
        Text(value, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.w600, color: isTotal ? Theme.of(context).primaryColor : Colors.black)),
      ],
    );
  }
}