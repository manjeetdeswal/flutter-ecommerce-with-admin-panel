import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/address.dart';
import '../providers/address_provider.dart';

class AddressFormScreen extends ConsumerStatefulWidget {
  // If editing, we pass the existing address. If null, we are adding.
  final Address? addressToEdit;

  const AddressFormScreen({super.key, this.addressToEdit});

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Field State
  String? _selectedCountry = 'India';
  final _fullNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _flatHouseNumberController = TextEditingController();
  final _areaStreetController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _townCityController = TextEditingController();
  String? _selectedState;
  bool _isDefault = false;

  // Dummy lists for dropdowns. Later, these would come from an API.
  final List<String> _countries = ['India', 'USA', 'UK', 'Canada'];
  final List<String> _states = ['Delhi', 'California', 'London', 'Ontario'];

  @override
  void initState() {
    super.initState();
    // If editing, pre-fill all the form fields
    if (widget.addressToEdit != null) {
      final address = widget.addressToEdit!;
      _selectedCountry = address.country;
      _fullNameController.text = address.fullName;
      _mobileNumberController.text = address.mobileNumber;
      _flatHouseNumberController.text = address.flatHouseNumber;
      _areaStreetController.text = address.areaStreet;
      _landmarkController.text = address.landmark;
      _pincodeController.text = address.pincode;
      _townCityController.text = address.townCity;
      _selectedState = address.state;
      _isDefault = address.isDefault;
    }
  }

  @override
  void dispose() {
    // Prevent memory leaks
    _fullNameController.dispose(); _mobileNumberController.dispose(); _flatHouseNumberController.dispose();
    _areaStreetController.dispose(); _landmarkController.dispose(); _pincodeController.dispose();
    _townCityController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    // 1. Validate the form
    if (_formKey.currentState!.validate()) {
      final addressNotifier = ref.read(addressProvider.notifier);

      // 2. Create the Address object
      final newOrUpdatedAddress = Address(
        // Reuse ID if editing, generate a new one if adding
        id: widget.addressToEdit?.id ?? const Uuid().v4(),
        name: 'New Address', // derrive or ask
        country: _selectedCountry!,
        fullName: _fullNameController.text.trim(),
        mobileNumber: _mobileNumberController.text.trim(),
        flatHouseNumber: _flatHouseNumberController.text.trim(),
        areaStreet: _areaStreetController.text.trim(),
        landmark: _landmarkController.text.trim(),
        pincode: _pincodeController.text.trim(),
        townCity: _townCityController.text.trim(),
        state: _selectedState!,
        isDefault: _isDefault,
      );

      // 3. Call the correct Notifier method
      if (widget.addressToEdit == null) {
        addressNotifier.addAddress(newOrUpdatedAddress);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Address Added!'), backgroundColor: Colors.green));
      } else {
        addressNotifier.updateAddress(newOrUpdatedAddress);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Address Updated!'), backgroundColor: Colors.green));
      }

      // If set as default, update the defaults logic
      if(_isDefault){
        addressNotifier.setDefaultAddress(newOrUpdatedAddress.id);
      }

      Navigator.pop(context); // Go back to management screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.addressToEdit != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Address' : 'Add a new address'),
        leading: TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.black))),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add a new address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                // --- 1. THE DROPDOWNS ---
                _buildDropdownField<String>(
                  value: _selectedCountry, items: _countries, hint: 'India',
                  onChanged: (value) => setState(() => _selectedCountry = value),
                  validator: (value) => value == null ? 'Please select a country' : null,
                ),
                const SizedBox(height: 16),

                // --- 2. THE TEXT FIELDS MATCHING YOUR IMAGE ---
                _buildTextField(
                  controller: _fullNameController, labelText: 'Full name (First and Last name)',
                  validator: (value) => value!.isEmpty ? 'Please enter full name' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _mobileNumberController, labelText: 'Mobile number', keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? 'Please enter mobile number' : null,
                  helperText: 'May be used to assist delivery',
                ),
                const SizedBox(height: 16),

                // Add location on map (UI only)
                TextButton.icon(
                  onPressed: () {}, // No implementation, just UI
                  icon: const Icon(Icons.location_on_outlined, color: Colors.blue),
                  label: const Text('Add location on map', style: TextStyle(color: Colors.blue)),
                ),
                const SizedBox(height: 16),

                _buildTextField(controller: _flatHouseNumberController, labelText: 'Flat, House no., Building, Company, Apartment'),
                const SizedBox(height: 16),
                _buildTextField(controller: _areaStreetController, labelText: 'Area, Street, Sector, Village'),
                const SizedBox(height: 16),
                _buildTextField(controller: _landmarkController, labelText: 'Landmark', hintText: 'E.g. near apollo hospital'),
                const SizedBox(height: 16),

                // Pincode and Town/City in a Row
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: _pincodeController, labelText: 'Pincode', keyboardType: TextInputType.number, hintText: '6-digit Pincode')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controller: _townCityController, labelText: 'Town/City')),
                  ],
                ),
                const SizedBox(height: 16),

                _buildDropdownField<String>(
                  value: _selectedState, items: _states, hint: 'Select', labelText: 'State',
                  onChanged: (value) => setState(() => _selectedState = value),
                  validator: (value) => value == null ? 'Please select a state' : null,
                ),
                const SizedBox(height: 24),

                // --- 3. MAKE DEFAULT CHECKBOX ---
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Make this my default address'),
                  value: _isDefault,
                  onChanged: (value) => setState(() => _isDefault = value!),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 24),

                // Delivery Instructions (UI only)
                TextButton(onPressed: () {}, child: const Text("Delivery instructions (optional)\nNotes, preferences and more")),
                const SizedBox(height: 24),

                // --- 4. THE MAIN BUTTON ---
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.amber[600],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _saveAddress,
                  child: Text(isEditing ? 'Save Changes' : 'Add address', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Generic helper for TextFields to add suffix clear buttons
  Widget _buildTextField({
    required TextEditingController controller, required String labelText, String? hintText,
    TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator, String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText, hintText: hintText, border: const OutlineInputBorder(),
        helperText: helperText,
        // The clear button suffix icon
        suffixIcon: IconButton(onPressed: () => controller.clear(), icon: const Icon(Icons.clear, size: 20, color: Colors.grey)),
      ),
      keyboardType: keyboardType, validator: validator,
    );
  }

  // Generic helper for Dropdowns
  Widget _buildDropdownField<T>({
    required T? value, required List<T> items, required String hint, String? labelText,
    required void Function(T?) onChanged, String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items.map((T item) => DropdownMenuItem<T>(value: item, child: Text(item.toString()))).toList(),
      onChanged: onChanged, validator: validator,
      decoration: InputDecoration(labelText: labelText, hintText: hint, border: const OutlineInputBorder()),
    );
  }
}