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
      // IMPORTANT: "Data" kabhi `false` (bool) aata hai jab guest
      // already exist ho ya validation fail ho — is liye Map hone
      // par hi parse karo, warna null rakho (crash se bachne ke liye)
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
    required this.addresses,
    required this.isGuest,
  });

  final int? id;
  final String? customerId;
  final String? name;
  final String? email;
  final String? cellNum;
  final String? token;
  final String? restaurantName;
  final List<dynamic> addresses;
  final int? isGuest;

  factory GuestData.fromJson(Map<String, dynamic> json) {
    return GuestData(
      id: json["id"],
      customerId: json["customer_id"],
      name: json["name"],
      email: json["email"],
      cellNum: json["cell_num"],
      token: json["token"],
      restaurantName: json["restaurant_name"],
      addresses: json["addresses"] == null
          ? []
          : List<dynamic>.from(json["addresses"]),
      isGuest: json["is_guest"],
    );
  }
}