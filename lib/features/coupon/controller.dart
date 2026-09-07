import 'package:customer_app/features/coupon/repository.dart';
import 'package:flutter/material.dart';
import 'model/coupon_model.dart';
import 'model/promotion_model.dart';
import '../../core/db/sqflite/model.dart'; // OrderDetails yahan se import hota hai

class CouponController extends ChangeNotifier {
  final CouponRepository _repo = CouponRepository();

  bool isLoading = false;
  bool isValidating = false;

  List<Coupon> coupons = [];
  Coupon? appliedCoupon;
  Data? appliedPromotionData;
  double discountAmount = 0;
  String? errorMessage;

  bool get hasApplied => appliedCoupon != null || appliedPromotionData != null;

  Promotion? get _firstPromo =>
      (appliedPromotionData?.promotions.isNotEmpty ?? false)
          ? appliedPromotionData!.promotions.first
          : null;

  String? get appliedDisplayCode =>
      appliedCoupon?.couponCode ?? _firstPromo?.code;

  bool get appliedIsPercentage {
    if (appliedCoupon != null) return appliedCoupon!.isPercentage;
    final per = appliedPromotionData?.legacyCompat?.discountPer;
    return per != null && per != 0;
  }

  double get appliedDiscountValue {
    if (appliedCoupon != null) return appliedCoupon!.discountValue;
    return (appliedPromotionData?.legacyCompat?.discountPer ??
        appliedPromotionData?.legacyCompat?.discountAmount ??
        0)
        .toDouble();
  }

  // Available coupons list load karo
  Future<void> loadCoupons(String branchId) async {
    isLoading = true;
    notifyListeners();
    try {
      coupons = await _repo.getCoupons(branchId);
    } catch (e) {
      debugPrint("loadCoupons error: $e");
      coupons = [];
    }
    isLoading = false;
    notifyListeners();
  }

  // List se coupon select karke apply
  Future<bool> applyCoupon({
    required String branchId,
    required String couponCode,
    required double subtotal,
  }) {
    return _applyCouponInternal(
      branchId: branchId,
      couponCode: couponCode,
      subtotal: subtotal,
    );
  }

  // Manual code apply — pehle promotions/validate, fail ho to GetValidateCoupon
  Future<bool> applyManualCode({
    required String branchId,
    required String customerId,
    required String code,
    required double subtotal,
    required List<OrderDetails> cartItems,
    required int orderTypeId,
    double deliveryFee = 0,
  }) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      errorMessage = "Please enter a coupon or promo code";
      notifyListeners();
      return false;
    }

    isValidating = true;
    errorMessage = null;
    notifyListeners();

    bool success = false;

    try {
      final items = _buildPromotionItems(cartItems);

      debugPrint("🟢 PROMO URL CALL START — code: $trimmed");

      final promoResponse = await _repo.validatePromotion(
        branchId: branchId,
        customerId: customerId,
        code: trimmed,
        orderTypeId: orderTypeId,
        deliveryFee: deliveryFee,
        items: items,
      );

      debugPrint("🟢 PROMO RESPONSE: success=${promoResponse.success}, "
          "dataSuccess=${promoResponse.data?.success}, "
          "promotions=${promoResponse.data?.promotions.length}");

      final data = promoResponse.data;

      if (promoResponse.success == true &&
          data != null &&
          data.success == true &&
          data.promotions.isNotEmpty) {
        appliedPromotionData = data;
        appliedCoupon = null;

        final lc = data.legacyCompat;
        discountAmount = (lc?.discountAmount ??
            (data.totals?.itemDiscountTotal ?? 0) +
                (data.totals?.orderDiscountTotal ?? 0))
            .toDouble();

        errorMessage = null;
        success = true;
      } else {
        debugPrint("🟡 Promotion failed, trying coupon fallback for: $trimmed");

        success = await _applyCouponInternal(
          branchId: branchId,
          couponCode: trimmed,
          subtotal: subtotal,
          silent: true,
        );

        if (!success) {
          errorMessage = (data?.messages.isNotEmpty ?? false)
              ? data!.messages.join(', ')
              : (promoResponse.message ??
              promoResponse.errorMessage ??
              "Code not valid");
          _clearApplied();
        }
      }
    } catch (e) {
      debugPrint("applyManualCode error: $e");
      errorMessage = "Something went wrong. Try again.";
      _clearApplied();
    }

    isValidating = false;
    notifyListeners();
    return success;
  }

  Future<bool> _applyCouponInternal({
    required String branchId,
    required String couponCode,
    required double subtotal,
    bool silent = false,
  }) async {
    if (!silent) {
      isValidating = true;
      errorMessage = null;
      notifyListeners();
    }

    bool success = false;

    try {
      final result = await _repo.validateCoupon(
        branchId: branchId,
        couponCode: couponCode.trim(),
      );

      if (result.valid && result.coupon != null) {
        final coupon = result.coupon!;

        if (subtotal < coupon.minOrderAmount) {
          errorMessage =
          "Minimum order Rs ${coupon.minOrderAmount.toStringAsFixed(0)} required";
          _clearApplied();
        } else {
          appliedCoupon = coupon;
          appliedPromotionData = null;
          discountAmount = coupon.discountAmountFor(subtotal);
          errorMessage = null;
          success = true;
        }
      } else {
        if (!silent) errorMessage = result.message ?? "Coupon not valid";
        _clearApplied();
      }
    } catch (e) {
      debugPrint("applyCoupon error: $e");
      if (!silent) errorMessage = "Something went wrong. Try again.";
      _clearApplied();
    }

    if (!silent) {
      isValidating = false;
      notifyListeners();
    }
    return success;
  }

  void _clearApplied() {
    appliedCoupon = null;
    appliedPromotionData = null;
    discountAmount = 0;
  }

  void removeCoupon() {
    _clearApplied();
    errorMessage = null;
    notifyListeners();
  }

  void recalcDiscount(double subtotal) {
    if (!hasApplied) return;

    if (appliedCoupon != null) {
      if (subtotal < appliedCoupon!.minOrderAmount) {
        removeCoupon();
        errorMessage = "Coupon removed (minimum order not met)";
        notifyListeners();
        return;
      }
      discountAmount = appliedCoupon!.discountAmountFor(subtotal);
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _buildPromotionItems(
      List<OrderDetails> cartItems) {
    final items = <Map<String, dynamic>>[];
    for (var i = 0; i < cartItems.length; i++) {
      final item = cartItems[i];
      items.add({
        "line_id": "line_$i",
        "menu_id": int.tryParse('${item.menuId}') ?? item.menuId,
        "menu_variation_id":
        int.tryParse('${item.menuVariation?.id ?? ''}') ?? 0,
        "qty": item.quantity ?? 1,
        "unit_price": double.tryParse(item.price ?? '0') ?? 0,
      });
    }
    return items;
  }

  void reset() {
    _clearApplied();
    errorMessage = null;
    coupons = [];
    notifyListeners();
  }
}