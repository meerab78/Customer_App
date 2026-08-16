class BranchModel {
  BranchModel({
    required this.errorMessage,
    required this.message,
    required this.success,
    required this.data,
    required this.status,
  });

  final String? errorMessage;
  final String? message;
  final bool? success;
  final List<Branch> data;
  final int? status;

  BranchModel copyWith({
    String? errorMessage,
    String? message,
    bool? success,
    List<Branch>? data,
    int? status,
  }) {
    return BranchModel(
      errorMessage: errorMessage ?? this.errorMessage,
      message: message ?? this.message,
      success: success ?? this.success,
      data: data ?? this.data,
      status: status ?? this.status,
    );
  }

  factory BranchModel.fromJson(Map<String, dynamic> json){
    return BranchModel(
      errorMessage: json["ErrorMessage"],
      message: json["Message"],
      success: json["Success"],
      data: json["Data"] == null ? [] : List<Branch>.from(json["Data"]!.map((x) => Branch.fromJson(x))),
      status: json["Status"],
    );
  }

  Map<String, dynamic> toJson() => {
    "ErrorMessage": errorMessage,
    "Message": message,
    "Success": success,
    "Data": data.map((x) => x?.toJson()).toList(),
    "Status": status,
  };

  @override
  String toString(){
    return "$errorMessage, $message, $success, $data, $status, ";
  }
}

class Branch {
  Branch({
    required this.id,
    required this.name,
    required this.logo,
    required this.restaurantName,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.contactEmail,
    required this.contactNumber,
    required this.openTime,
    required this.closeTime,
    required this.restaurantBranchId,
    required this.restaurantOpen,
  });

  final int? id;
  final String? name;
  final String? logo;
  final String? restaurantName;
  final String? latitude;
  final String? longitude;
  final String? address;
  final String? contactEmail;
  final String? contactNumber;
  final String? openTime;
  final String? closeTime;
  final String? restaurantBranchId;
  final bool? restaurantOpen;

  Branch copyWith({
    int? id,
    String? name,
    String? logo,
    String? restaurantName,
    String? latitude,
    String? longitude,
    String? address,
    String? contactEmail,
    String? contactNumber,
    String? openTime,
    String? closeTime,
    String? restaurantBranchId,
    bool? restaurantOpen,
  }) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      restaurantName: restaurantName ?? this.restaurantName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      contactEmail: contactEmail ?? this.contactEmail,
      contactNumber: contactNumber ?? this.contactNumber,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      restaurantBranchId: restaurantBranchId ?? this.restaurantBranchId,
      restaurantOpen: restaurantOpen ?? this.restaurantOpen,
    );
  }

  factory Branch.fromJson(Map<String, dynamic> json){
    return Branch(
      id: json["id"],
      name: json["name"],
      logo: json["logo"],
      restaurantName: json["restaurant_name"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      address: json["address"],
      contactEmail: json["contact_email"],
      contactNumber: json["contact_number"],
      openTime: json["open_time"],
      closeTime: json["close_time"],
      restaurantBranchId: json["restaurant_branch_id"],
      restaurantOpen: json["restaurant_open"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "logo": logo,
    "restaurant_name": restaurantName,
    "latitude": latitude,
    "longitude": longitude,
    "address": address,
    "contact_email": contactEmail,
    "contact_number": contactNumber,
    "open_time": openTime,
    "close_time": closeTime,
    "restaurant_branch_id": restaurantBranchId,
    "restaurant_open": restaurantOpen,
  };

  @override
  String toString(){
    return "$id, $name, $logo, $restaurantName, $latitude, $longitude, $address, $contactEmail, $contactNumber, $openTime, $closeTime, $restaurantBranchId, $restaurantOpen, ";
  }
}
