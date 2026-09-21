class Coupon {
  final int? couponId;
  final String couponCode;
  final bool isActive;
  final String? validFrom;
  final String? validTill;
  final double minOrderAmount;
  final double maxOrderAmount;
  final String couponType;      // "All Users"
  final int? discountId;
  final String? discountName;   // "dis 10"
  final String discountType;    // "Percentage" ya "Fixed"
  final double discountValue;   // 10.00
  final int? branchId;

  Coupon({
    this.couponId,
    required this.couponCode,
    this.isActive = true,
    this.validFrom,
    this.validTill,
    this.minOrderAmount = 0,
    this.maxOrderAmount = 0,
    this.couponType = '',
    this.discountId,
    this.discountName,
    this.discountType = '',
    this.discountValue = 0,
    this.branchId,
  });

  bool get isPercentage => discountType.toLowerCase() == 'percentage';

  factory Coupon.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) => double.tryParse('$v') ?? 0;
    int? _toInt(dynamic v) => v is int ? v : int.tryParse('$v');

    return Coupon(
      couponId: _toInt(json['coupon_id']),
      couponCode: json['coupon_code']?.toString() ?? '',
      isActive: json['is_active'] == true,
      validFrom: json['valid_from']?.toString(),
      validTill: json['valid_till']?.toString(),
      minOrderAmount: _toDouble(json['min_order_amount']),
      maxOrderAmount: _toDouble(json['max_order_amount']),
      couponType: json['coupon_type']?.toString() ?? '',
      discountId: _toInt(json['discount_id']),
      discountName: json['discount_name']?.toString(),
      discountType: json['discount_type']?.toString() ?? '',
      discountValue: _toDouble(json['discount_value']),
      branchId: _toInt(json['branch_id']),
    );
  }

  // Discount amount nikaalo subtotal ke hisaab se
  double discountAmountFor(double subtotal) {
    if (isPercentage) {
      return (subtotal * discountValue) / 100;
    } else {
      return discountValue; // fixed amount
    }
  }
}