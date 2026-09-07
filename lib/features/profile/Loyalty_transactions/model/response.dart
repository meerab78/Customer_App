class GetLoyaltyTransactionResponse {
  GetLoyaltyTransactionResponse({
    required this.errorMessage,
    required this.message,
    required this.success,
    required this.data,
    required this.status,
  });

  final String? errorMessage;
  final String? message;
  final bool? success;
  final LtData? data;
  final int? status;

  factory GetLoyaltyTransactionResponse.fromJson(Map<String, dynamic> json) {
    return GetLoyaltyTransactionResponse(
      errorMessage: json["ErrorMessage"],
      message: json["Message"],
      success: json["Success"],
      data: json["Data"] == null ? null : LtData.fromJson(json["Data"]),
      status: json["Status"],
    );
  }

  Map<String, dynamic> toJson() => {
    "ErrorMessage": errorMessage,
    "Message": message,
    "Success": success,
    "Data": data?.toJson(),
    "Status": status,
  };
}

class LtData {
  LtData({
    required this.loyaltyPoints,
    required this.loyaltyTransactions,
  });

  final String? loyaltyPoints;
  final List<LoyaltyTransaction> loyaltyTransactions;

  factory LtData.fromJson(Map<String, dynamic> json) {
    return LtData(
      loyaltyPoints: json["loyalty_points"],
      loyaltyTransactions: json["loyalty_transactions"] == null
          ? []
          : List<LoyaltyTransaction>.from(json["loyalty_transactions"]!
          .map((x) => LoyaltyTransaction.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "loyalty_points": loyaltyPoints,
    "loyalty_transactions":
    loyaltyTransactions.map((x) => x.toJson()).toList(),
  };
}

class LoyaltyTransaction {
  LoyaltyTransaction({
    required this.loyaltyTransactionId,
    required this.userId,
    required this.orderId,
    required this.points,
    required this.type,
    required this.description,
    required this.branchId,
    required this.restaurantId,
  });

  final String? loyaltyTransactionId;
  final int? userId;
  final int? orderId;
  final String? points;
  final String? type;
  final String? description;
  final dynamic branchId;
  final int? restaurantId;

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransaction(
      loyaltyTransactionId: json["loyalty_transaction_id"],
      userId: json["user_id"],
      orderId: json["order_id"],
      points: json["points"],
      type: json["type"],
      description: json["description"],
      branchId: json["branch_id"],
      restaurantId: json["restaurant_id"],
    );
  }

  Map<String, dynamic> toJson() => {
    "loyalty_transaction_id": loyaltyTransactionId,
    "user_id": userId,
    "order_id": orderId,
    "points": points,
    "type": type,
    "description": description,
    "branch_id": branchId,
    "restaurant_id": restaurantId,
  };
}