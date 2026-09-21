import '../../auth/address/model/address_model.dart' show CustomerAddress;

class GuestUserResponse {
  GuestUserResponse({
    required this.errorMessage,
    required this.message,
    required this.success,
    required this.data,
    required this.status,
  });

  final String? errorMessage;
  final String? message;
  final bool? success;
  final GuestData? data;
  final int? status;

  factory GuestUserResponse.fromJson(Map<String, dynamic> json) {
    return GuestUserResponse(
      errorMessage: json["ErrorMessage"],
      message: json["Message"],
      success: json["Success"],
      data: (json["Data"] is Map<String, dynamic>)
          ? GuestData.fromJson(json["Data"])
          : null,
      status: json["Status"],
    );
  }
}

class GuestData {
  GuestData({
    required this.id,
    required this.customerId,
    required this.name,
    required this.email,
    required this.cellNum,
    required this.token,
    required this.restaurantName,
    required this.isGuest,
    this.addresses,
  });

  final int? id;
  final String? customerId;
  final String? name;
  final String? email;
  final String? cellNum;
  final String? token;
  final String? restaurantName;
  final int? isGuest;
  final List<CustomerAddress>? addresses;

  factory GuestData.fromJson(Map<String, dynamic> json) {
    return GuestData(
      id: json["id"],
      customerId: json["customer_id"],
      name: json["name"],
      email: json["email"],
      cellNum: json["cell_num"],
      token: json["token"],
      restaurantName: json["restaurant_name"],
      isGuest: json["is_guest"],
      addresses: (json["addresses"] is List)
          ? (json["addresses"] as List)
          .map((e) => CustomerAddress.fromJson(e))
          .toList()
          : null,
    );
  }
}