// lib/features/home/presentation/pages/address_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/address_provider.dart';

import 'address_form_screen.dart';

class AddressManagementScreen extends ConsumerWidget {
  const AddressManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the list of addresses from the new provider
    final addresses = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('My Addresses')),

      // 2. Display the robust address cards
      body: addresses.isEmpty
          ? const Center(child: Text("No addresses added yet."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          final isDefault = address.isDefault;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: isDefault ? Theme.of(context).primaryColor : Colors.grey.shade300,
                  width: isDefault ? 2 : 1
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: () {
                // Set as default address when tapped
                ref.read(addressProvider.notifier).setDefaultAddress(address.id);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: isDefault ? Theme.of(context).primaryColor : Colors.grey),
                            const SizedBox(width: 8),
                            Text(address.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            if (isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                child: Text('DEFAULT', style: TextStyle(fontSize: 10, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                              )
                            ]
                          ],
                        ),
                        // EDIT BUTTON: Pushes the form screen with address data
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AddressFormScreen(addressToEdit: address)),
                            );
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(address.fullName, style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text("${address.flatHouseNumber}, ${address.areaStreet}, ${address.landmark}, ${address.townCity}, ${address.state} - ${address.pincode}, ${address.country}", style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
                    const SizedBox(height: 4),
                    Text('Phone: ${address.mobileNumber}', style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      // 3. "Add New Address" Button
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add New Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            onPressed: () {
              // Pushes the empty form screen for a new address
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressFormScreen()));
            },
          ),
        ),
      ),
    );
  }
}