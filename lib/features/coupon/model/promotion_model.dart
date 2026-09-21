class PromotionResponse {
  PromotionResponse({
    required this.errorMessage,
    required this.message,
    required this.success,
    required this.data,
    required this.status,
  });

  final String? errorMessage;
  final String? message;
  final bool? success;
  final Data? data;
  final int? status;

  factory PromotionResponse.fromJson(Map<String, dynamic> json) {
    return PromotionResponse(
      errorMessage: json["ErrorMessage"]?.toString(),
      message: json["Message"]?.toString(),
      success: json["Success"] == true || json["Success"] == 1,
      data: json["Data"] == null
          ? null
          : Data.fromJson(Map<String, dynamic>.from(json["Data"] as Map)),
      status: _asInt(json["Status"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "ErrorMessage": errorMessage,
    "Message": message,
    "Success": success,
    "Data": data?.toJson(),
    "Status": status,
  };

  @override
  String toString() {
    return "$errorMessage, $message, $success, $data, $status, ";
  }
}

class Data {
  Data({
    required this.success,
    required this.error,
    required this.messages,
    required this.promotions,
    required this.totals,
    required this.legacyCompat,
  });

  final bool? success;
  final dynamic error;
  final List<String> messages;
  final List<Promotion> promotions;
  final Totals? totals;
  final LegacyCompat? legacyCompat;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      success: json["success"] == true || json["success"] == 1,
      error: json["error"],
      messages: json["messages"] == null
          ? []
          : List<String>.from(json["messages"]!.map((x) => x.toString())),
      promotions: json["promotions"] == null
          ? []
          : List<Promotion>.from(json["promotions"]!.map(
              (x) => Promotion.fromJson(Map<String, dynamic>.from(x as Map)))),
      totals: json["totals"] == null
          ? null
          : Totals.fromJson(Map<String, dynamic>.from(json["totals"] as Map)),
      legacyCompat: json["legacy_compat"] == null
          ? null
          : LegacyCompat.fromJson(
          Map<String, dynamic>.from(json["legacy_compat"] as Map)),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "error": error,
    "messages": messages,
    "promotions": promotions.map((x) => x.toJson()).toList(),
    "totals": totals?.toJson(),
    "legacy_compat": legacyCompat?.toJson(),
  };

  @override
  String toString() {
    return "$success, $error, $messages, $promotions, $totals, $legacyCompat, ";
  }
}

class LegacyCompat {
  LegacyCompat({
    required this.couponId,
    required this.discountId,
    required this.discountPer,
    required this.discountAmount,
    required this.promotionId,
  });

  final dynamic couponId;
  final dynamic discountId;
  final num? discountPer;
  final num? discountAmount;
  final String? promotionId;

  factory LegacyCompat.fromJson(Map<String, dynamic> json) {
    return LegacyCompat(
      couponId: json["coupon_id"],
      discountId: json["discount_id"],
      discountPer: _asNum(json["discount_per"]),
      discountAmount: _asNum(json["discount_amount"]),
      promotionId: json["promotion_id"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "coupon_id": couponId,
    "discount_id": discountId,
    "discount_per": discountPer,
    "discount_amount": discountAmount,
    "promotion_id": promotionId,
  };

  @override
  String toString() {
    return "$couponId, $discountId, $discountPer, $discountAmount, $promotionId, ";
  }
}

class Promotion {
  Promotion({
    required this.promotionId,
    required this.couponId,
    required this.code,
    required this.name,
    required this.promotionType,
    required this.discountAmount,
    required this.discountPer,
    required this.deliveryDiscountAmount,
    required this.lineDiscounts,
    required this.freeItems,
    required this.messages,
    required this.priority,
    required this.meta,
  });

  final String? promotionId;
  final dynamic couponId;
  final String? code;
  final String? name;
  final String? promotionType;
  final num? discountAmount;
  final dynamic discountPer;
  final num? deliveryDiscountAmount;
  final List<LineDiscount> lineDiscounts;
  final List<dynamic> freeItems;
  final List<String> messages;
  final int? priority;
  final Meta? meta;

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      promotionId: json["promotion_id"]?.toString(),
      couponId: json["coupon_id"],
      code: json["code"]?.toString(),
      name: json["name"]?.toString(),
      promotionType: json["promotion_type"]?.toString(),
      discountAmount: _asNum(json["discount_amount"]),
      discountPer: json["discount_per"],
      deliveryDiscountAmount: _asNum(json["delivery_discount_amount"]),
      lineDiscounts: json["line_discounts"] == null
          ? []
          : List<LineDiscount>.from(json["line_discounts"]!.map((x) =>
          LineDiscount.fromJson(Map<String, dynamic>.from(x as Map)))),
      freeItems: json["free_items"] == null
          ? []
          : List<dynamic>.from(json["free_items"]!.map((x) => x)),
      messages: json["messages"] == null
          ? []
          : List<String>.from(json["messages"]!.map((x) => x.toString())),
      priority: _asInt(json["priority"]),
      meta: json["meta"] == null
          ? null
          : Meta.fromJson(Map<String, dynamic>.from(json["meta"] as Map)),
    );
  }

  Map<String, dynamic> toJson() => {
    "promotion_id": promotionId,
    "coupon_id": couponId,
    "code": code,
    "name": name,
    "promotion_type": promotionType,
    "discount_amount": discountAmount,
    "discount_per": discountPer,
    "delivery_discount_amount": deliveryDiscountAmount,
    "line_discounts": lineDiscounts.map((x) => x.toJson()).toList(),
    "free_items": freeItems.map((x) => x).toList(),
    "messages": messages,
    "priority": priority,
    "meta": meta?.toJson(),
  };

  @override
  String toString() {
    return "$promotionId, $couponId, $code, $name, $promotionType, $discountAmount, $discountPer, $deliveryDiscountAmount, $lineDiscounts, $freeItems, $messages, $priority, $meta, ";
  }
}

class LineDiscount {
  LineDiscount({
    required this.lineId,
    required this.discountAmount,
    required this.discountPer,
    required this.isFreeItem,
    required this.rewardType,
    required this.originalPrice,
    required this.finalPrice,
  });

  final String? lineId;
  final num? discountAmount;
  final dynamic discountPer;
  final bool? isFreeItem;
  final String? rewardType;
  final num? originalPrice;
  final num? finalPrice;

  factory LineDiscount.fromJson(Map<String, dynamic> json) {
    return LineDiscount(
      lineId: json["line_id"]?.toString(),
      discountAmount: _asNum(json["discount_amount"]),
      discountPer: json["discount_per"],
      isFreeItem: json["is_free_item"] == true || json["is_free_item"] == 1,
      rewardType: json["reward_type"]?.toString(),
      originalPrice: _asNum(json["original_price"]),
      finalPrice: _asNum(json["final_price"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "line_id": lineId,
    "discount_amount": discountAmount,
    "discount_per": discountPer,
    "is_free_item": isFreeItem,
    "reward_type": rewardType,
    "original_price": originalPrice,
    "final_price": finalPrice,
  };

  @override
  String toString() {
    return "$lineId, $discountAmount, $discountPer, $isFreeItem, $rewardType, $originalPrice, $finalPrice, ";
  }
}

class Meta {
  Meta({
    required this.isStackable,
    required this.isExclusive,
    required this.stackGroup,
  });

  final bool? isStackable;
  final bool? isExclusive;
  final dynamic stackGroup;

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      isStackable: json["is_stackable"] == true || json["is_stackable"] == 1,
      isExclusive: json["is_exclusive"] == true || json["is_exclusive"] == 1,
      stackGroup: json["stack_group"],
    );
  }

  Map<String, dynamic> toJson() => {
    "is_stackable": isStackable,
    "is_exclusive": isExclusive,
    "stack_group": stackGroup,
  };

  @override
  String toString() {
    return "$isStackable, $isExclusive, $stackGroup, ";
  }
}

class Totals {
  Totals({
    required this.subTotal,
    required this.itemDiscountTotal,
    required this.orderDiscountTotal,
    required this.deliveryFee,
    required this.deliveryDiscount,
    required this.grandTotalBeforeTax,
  });

  final num? subTotal;
  final num? itemDiscountTotal;
  final num? orderDiscountTotal;
  final num? deliveryFee;
  final num? deliveryDiscount;
  final num? grandTotalBeforeTax;

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(
      subTotal: _asNum(json["sub_total"]),
      itemDiscountTotal: _asNum(json["item_discount_total"]),
      orderDiscountTotal: _asNum(json["order_discount_total"]),
      deliveryFee: _asNum(json["delivery_fee"]),
      deliveryDiscount: _asNum(json["delivery_discount"]),
      grandTotalBeforeTax: _asNum(json["grand_total_before_tax"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "sub_total": subTotal,
    "item_discount_total": itemDiscountTotal,
    "order_discount_total": orderDiscountTotal,
    "delivery_fee": deliveryFee,
    "delivery_discount": deliveryDiscount,
    "grand_total_before_tax": grandTotalBeforeTax,
  };

  @override
  String toString() {
    return "$subTotal, $itemDiscountTotal, $orderDiscountTotal, $deliveryFee, $deliveryDiscount, $grandTotalBeforeTax, ";
  }
}

num? _asNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse(value.toString());
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
