class UpdateCustomerResponse {
  final bool success;
  final String message;
  final String errorMessage;
  final int status;
  final CustomerData? data;

  UpdateCustomerResponse({
    required this.success,
    required this.message,
    required this.errorMessage,
    required this.status,
    this.data,
  });

  factory UpdateCustomerResponse.fromJson(Map<String, dynamic> json) {
    return UpdateCustomerResponse(
      success: json['Success'] ?? false,
      message: json['Message'] ?? '',
      errorMessage: json['ErrorMessage'] ?? '',
      status: json['Status'] ?? 0,
      data: json['Data'] != null ? CustomerData.fromJson(json['Data']) : null,
    );
  }
}

class CustomerData {
  final int id;
  final String customerId;
  final String name;
  final String? gender;
  final String? dateBirth;
  final String email;
  final String cellNum;
  final int restaurantId;
  final String restaurantName;

  CustomerData({
    required this.id,
    required this.customerId,
    required this.name,
    this.gender,
    this.dateBirth,
    required this.email,
    required this.cellNum,
    required this.restaurantId,
    required this.restaurantName,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'],
      dateBirth: json['date_birth'],
      email: json['email'] ?? '',
      cellNum: json['cell_num'] ?? '',
      restaurantId: json['restaurant_id'] ?? 0,
      restaurantName: json['restaurant_name'] ?? '',
    );
  }
}