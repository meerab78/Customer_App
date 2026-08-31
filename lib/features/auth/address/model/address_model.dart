// class CustomerAddress {
//   final String? addressId;
//   final int? addressTypeId;   // 3=Home, 4=Flat, 5=Office
//   final String? addressType;  // server se aaya naam: "Home"/"Flat"/"Office"
//   final String address1;
//   final int? townId;
//   final int? townBlockId;
//   final String latitude;
//   final String longitude;
//   final int isDefault;
//
//   CustomerAddress({
//     this.addressId,
//     this.addressTypeId,
//     this.addressType,
//     required this.address1,
//     this.townId,
//     this.townBlockId,
//     required this.latitude,
//     required this.longitude,
//     this.isDefault = 0,
//   });
//
//   // Server ka naam ho to wahi, warna id se map
//   String get typeName {
//     if (addressType != null && addressType!.isNotEmpty) return addressType!;
//     switch (addressTypeId) {
//       case 3: return 'Home';
//       case 4: return 'Flat';
//       case 5: return 'Office';
//       default: return 'Address';
//     }
//   }
//
//   factory CustomerAddress.fromJson(Map<String, dynamic> json) {
//     int? _toInt(dynamic v) => v is int ? v : int.tryParse('$v');
//     return CustomerAddress(
//       addressId: json['address_id']?.toString(),
//       addressTypeId: _toInt(json['address_type_id']),
//       addressType: json['address_type']?.toString(),
//       address1: json['address1']?.toString() ?? '',
//       townId: _toInt(json['town_id']),
//       townBlockId: _toInt(json['town_block_id']),
//       latitude: json['latitude']?.toString() ?? '',
//       longitude: json['longitude']?.toString() ?? '',
//       isDefault: _toInt(json['is_default']) ?? 0,
//     );
//   }
// }

class CustomerAddress {
  final int? id;              // NEW: numeric id (jaise 1048830) - order ke liye
  final String? addressId;    // UUID (jaise 6d2c03da-...)
  final int? addressTypeId;   // 3=Home, 4=Flat, 5=Office
  final String? addressType;  // server se aaya naam: "Home"/"Flat"/"Office"
  final String address1;
  final int? townId;
  final int? townBlockId;
  final String latitude;
  final String longitude;
  final int isDefault;

  CustomerAddress({
    this.id,
    this.addressId,
    this.addressTypeId,
    this.addressType,
    required this.address1,
    this.townId,
    this.townBlockId,
    required this.latitude,
    required this.longitude,
    this.isDefault = 0,
  });

  String get typeName {
    if (addressType != null && addressType!.isNotEmpty) return addressType!;
    switch (addressTypeId) {
      case 3: return 'Home';
      case 4: return 'Flat';
      case 5: return 'Office';
      default: return 'Address';
    }
  }

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    int? _toInt(dynamic v) => v is int ? v : int.tryParse('$v');
    return CustomerAddress(
      id: _toInt(json['id']),                          // NEW
      addressId: json['address_id']?.toString(),
      addressTypeId: _toInt(json['address_type_id']),
      addressType: json['address_type']?.toString(),
      address1: json['address1']?.toString() ?? '',
      townId: _toInt(json['town_id']),
      townBlockId: _toInt(json['town_block_id']),
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      isDefault: _toInt(json['is_default']) ?? 0,
    );
  }
}