import '../../api_service/api_constants.dart';
import '../../api_service/api_service.dart';
import '../../core/db/shared_pref.dart';
import 'model/coupon_model.dart';
import 'model/promotion_model.dart';

class CouponRepository {
  final ApiService _api = ApiService();
  final SharedPrefService _prefs = SharedPrefService();

  // Available coupons list (GET)
  Future<List<Coupon>> getCoupons(String branchId) async {
    final token = await _prefs.getToken();
    final userId = await _prefs.getUserId();

    final url =
        "${ApiConstants.getCouponsByUserId}?user_id=$userId&branch_id=$branchId";

    final response = await _api.getRequest(url, token: token);

    if (response['Success'] == true && response['Data'] is List) {
      final List list = response['Data'] as List;
      return list.map((e) => Coupon.fromJson(e)).toList();
    }
    return [];
  }

  // Coupon validate (POST)
  Future<CouponResult> validateCoupon({
    required String branchId,
    required String couponCode,
  }) async {
    final token = await _prefs.getToken();
    final userId = await _prefs.getUserId();

    final body = {
      "user_id": userId?.toString() ?? '',
      "branch_id": branchId,
      "coupon_code": couponCode,
    };

    final response = await _api.postRequest(
      ApiConstants.getValidateCoupon,
      body,
      token: token,
    );

    if (response['Success'] == true && response['Data'] is Map) {
      return CouponResult.success(Coupon.fromJson(response['Data']));
    }

    return CouponResult.fail(
      response['Message']?.toString() ??
          response['ErrorMessage']?.toString() ??
          "Coupon not valid",
    );
  }

  // NEW — Promotion validate (POST)
  Future<PromotionResponse> validatePromotion({
    required String branchId,
    required String customerId,
    required String code,
    required int orderTypeId,
    required double deliveryFee,
    required List<Map<String, dynamic>> items,
  }) async {
    final token = await _prefs.getToken();

    final body = {
      "branch_id": branchId,
      "customer_id": int.tryParse(customerId) ?? customerId,
      "code": code,
      "channel": "mobile",
      "order_type_id": orderTypeId,
      "payment_type_id": 1,
      "delivery_fee": deliveryFee,
      "items": items,
    };

    final response = await _api.postRequest(
      ApiConstants.validatePromotion,
      body,
      token: token,
    );

    return PromotionResponse.fromJson(response);
  }
}

class CouponResult {
  final bool valid;
  final Coupon? coupon;
  final String? message;

  CouponResult.success(this.coupon)
      : valid = true,
        message = null;

  CouponResult.fail(this.message)
      : valid = false,
        coupon = null;
}