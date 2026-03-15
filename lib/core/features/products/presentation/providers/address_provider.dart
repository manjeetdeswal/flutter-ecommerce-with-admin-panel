
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/address.dart';

class AddressNotifier extends StateNotifier<List<Address>> {
  AddressNotifier() : super([]) {
    // When the provider starts, immediately fetch the user's addresses from the cloud!
    fetchAddresses();
  }

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Helper getter to find exactly where this user's addresses are stored
  CollectionReference get _userAddresses => _firestore
      .collection('users')
      .doc(_auth.currentUser!.uid)
      .collection('addresses');

  // 1. READ FROM FIRESTORE
  Future<void> fetchAddresses() async {
    if (_auth.currentUser == null) return;

    try {
      final snapshot = await _userAddresses.get();
      // Loop through all documents in the cloud and convert them to Dart Address objects
      final addresses = snapshot.docs.map((doc) {
        return Address.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      state = addresses; // Update the UI!
    } catch (e) {
      print("Error fetching addresses: $e");
    }
  }

  // 2. WRITE TO FIRESTORE
  Future<void> addAddress(Address address) async {
    if (_auth.currentUser == null) return;

    try {
      // If the user checked "Make Default", we need to remove the default flag from older addresses
      if (address.isDefault) {
        await _removeOtherDefaults();
      }

      // Save the new address to Firestore
      await _userAddresses.doc(address.id).set(address.toMap());

      // Refresh the list so the UI updates
      await fetchAddresses();
    } catch (e) {
      print("Error adding address: $e");
    }
  }

  // 3. UPDATE IN FIRESTORE
  Future<void> updateAddress(Address address) async {
    if (_auth.currentUser == null) return;

    try {
      if (address.isDefault) {
        await _removeOtherDefaults();
      }

      // Overwrite the existing document with the new data
      await _userAddresses.doc(address.id).update(address.toMap());
      await fetchAddresses();
    } catch (e) {
      print("Error updating address: $e");
    }
  }

  // 4. SET DEFAULT ADDRESS
  Future<void> setDefaultAddress(String addressId) async {
    if (_auth.currentUser == null) return;

    try {
      await _removeOtherDefaults();
      // Set the clicked one to true
      await _userAddresses.doc(addressId).update({'isDefault': true});
      await fetchAddresses();
    } catch (e) {
      print("Error setting default: $e");
    }
  }

  // Utility method: Loops through the cloud and unchecks the 'isDefault' flag on old addresses
  Future<void> _removeOtherDefaults() async {
    final snapshot = await _userAddresses.where('isDefault', isEqualTo: true).get();
    for (var doc in snapshot.docs) {
      await doc.reference.update({'isDefault': false});
    }
  }
}

final addressProvider = StateNotifierProvider<AddressNotifier, List<Address>>((ref) {
  return AddressNotifier();
});