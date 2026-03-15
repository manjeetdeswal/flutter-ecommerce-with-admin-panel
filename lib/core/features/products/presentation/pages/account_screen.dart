import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'address_management_screen.dart';
import 'order_list_screen.dart'; // Import the screen we just made!

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Grab the current logged-in user from Firebase!
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. User Profile Header
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
            title: Text(user?.email ?? 'Guest User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: const Text('+1 234 567 8900'),
          ),
          const Divider(height: 32),

          // 2. Menu Items
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('My Orders'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderListScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Manage Addresses'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to our new Address Screen!
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressManagementScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Payment Methods'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const Divider(height: 32),

          // 3. LOG OUT BUTTON
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: () async {
              // Tell Firebase to sign out
              await FirebaseAuth.instance.signOut();

              // Magic: You don't need to write Navigator code here!
              // Your Riverpod AuthGuard in main.dart is listening to Firebase.
              // As soon as this finishes, the app will instantly boot them back to the Login Screen!
            },
          )
        ],
      ),
    );
  }
}