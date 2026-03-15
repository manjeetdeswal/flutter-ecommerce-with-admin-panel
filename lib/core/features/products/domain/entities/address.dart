class Address {
  final String id;
  final String name;
  final String country;
  final String fullName;
  final String mobileNumber;
  final String flatHouseNumber;
  final String areaStreet;
  final String landmark;
  final String pincode;
  final String townCity;
  final String state;
  final bool isDefault;

  Address({
    required this.id, required this.name, required this.country, required this.fullName,
    required this.mobileNumber, required this.flatHouseNumber, required this.areaStreet,
    required this.landmark, required this.pincode, required this.townCity,
    required this.state, this.isDefault = false,
  });

  // 1. Send to Firestore (Translates Dart object to a Map)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'country': country,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'flatHouseNumber': flatHouseNumber,
      'areaStreet': areaStreet,
      'landmark': landmark,
      'pincode': pincode,
      'townCity': townCity,
      'state': state,
      'isDefault': isDefault,
    };
  }

  // 2. Read from Firestore (Translates a Map back into a Dart object)
  factory Address.fromMap(Map<String, dynamic> map, String documentId) {
    return Address(
      id: documentId, // We get the ID directly from the Firestore document name!
      name: map['name'] ?? '',
      country: map['country'] ?? '',
      fullName: map['fullName'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      flatHouseNumber: map['flatHouseNumber'] ?? '',
      areaStreet: map['areaStreet'] ?? '',
      landmark: map['landmark'] ?? '',
      pincode: map['pincode'] ?? '',
      townCity: map['townCity'] ?? '',
      state: map['state'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }

  Address copyWith({bool? isDefault}) {
    return Address(
      id: id, name: name, country: country, fullName: fullName, mobileNumber: mobileNumber,
      flatHouseNumber: flatHouseNumber, areaStreet: areaStreet, landmark: landmark,
      pincode: pincode, townCity: townCity, state: state, isDefault: isDefault ?? this.isDefault,
    );
  }
}