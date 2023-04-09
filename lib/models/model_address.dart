enum AddressType { receiptAddress, shippingAddress }

class AddressModel {
  final int id;
  final AddressType type;
  final String latitude;
  final String longitude;
  final String name;
  final int stateId;
  final String state;
  final int cityId;
  final String city;
  final String description;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  late bool isDefault;
  final bool? isShippingAddressSupported;

  AddressModel({
    required this.id,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.stateId,
    required this.state,
    required this.cityId,
    required this.city,
    required this.description,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.isDefault,
    this.isShippingAddressSupported = false,
  });

  @override
  bool operator ==(Object other) => other is AddressModel && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    AddressType type = AddressType.receiptAddress;
    if (json['type'] != null) {
      type = AddressType.values[int.parse(json['type'].toString())];
    }
    return AddressModel(
      id: json['id'] ?? 0,
      type: type,
      latitude: json['latitude'],
      longitude: json['longitude'],
      name: json['name'],
      stateId: json['stateId'],
      state: json['state'],
      cityId: json['cityId'],
      city: json['city'],
      description: json['description'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      isDefault: json['isDefault'] ?? false,
      isShippingAddressSupported: json['isShippingAddressSupported'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'stateId': stateId,
      'state': state,
      'cityId': cityId,
      'city': city,
      'description': description,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'isDefault': isDefault,
      'isShippingAddressSupported': isShippingAddressSupported,
    };
  }
}
