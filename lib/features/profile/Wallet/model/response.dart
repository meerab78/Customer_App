class GetWalletTransactionResponse {
  GetWalletTransactionResponse({
    required this.errorMessage,
    required this.message,
    required this.success,
    required this.data,
    required this.status,
  });

  final String? errorMessage;
  final String? message;
  final bool? success;
  final WalletTransactionData? data;
  final int? status;

  factory GetWalletTransactionResponse.fromJson(Map<String, dynamic> json) {
    return GetWalletTransactionResponse(
      errorMessage: json["ErrorMessage"],
      message: json["Message"],
      success: json["Success"],
      data: json["Data"] == null ? null : WalletTransactionData.fromJson(json["Data"]),
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

class WalletTransactionData {
  WalletTransactionData({
    required this.walletAmount,
    required this.walletTransactions,
  });

  final String? walletAmount;
  final List<WalletTransaction> walletTransactions;

  factory WalletTransactionData.fromJson(Map<String, dynamic> json) {
    return WalletTransactionData(
      walletAmount: json["wallet_amount"],
      walletTransactions: json["wallet_transactions"] == null
          ? []
          : List<WalletTransaction>.from(json["wallet_transactions"]!
          .map((x) => WalletTransaction.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "wallet_amount": walletAmount,
    "wallet_transactions":
    walletTransactions.map((x) => x.toJson()).toList(),
  };
}

// ⬇️ Ye class pehle missing thi — ab wapas add ki hai
class WalletTransaction {
  WalletTransaction({
    required this.walletTransactionId,
    required this.userId,
    required this.loyaltyConvertPackageId,
    required this.amount,
    required this.type,
    required this.description,
    required this.branchId,
    required this.restaurantId,
  });

  final String? walletTransactionId;
  final int? userId;
  final String? loyaltyConvertPackageId;
  final String? amount;
  final String? type;
  final String? description;
  final dynamic branchId;
  final int? restaurantId;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      walletTransactionId: json["wallet_transaction_id"],
      userId: json["user_id"],
      loyaltyConvertPackageId: json["loyalty_wallet_package_id"],
      amount: json["amount"],
      type: json["type"],
      description: json["description"],
      branchId: json["branch_id"],
      restaurantId: json["restaurant_id"],
    );
  }

  Map<String, dynamic> toJson() => {
    "wallet_transaction_id": walletTransactionId,
    "user_id": userId,
    "loyalty_wallet_package_id": loyaltyConvertPackageId,
    "amount": amount,
    "type": type,
    "description": description,
    "branch_id": branchId,
    "restaurant_id": restaurantId,
  };
}