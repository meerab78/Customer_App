class ApiConstants {
  static const String baseUrlV1=  "https://dev-admin.cherryberrycloud.com/api/";
  static const String baseUrlV2=   "https://dev-admin.cherryberrycloud.com/v2/api/onlineapp/";
  static const String  branches =   "GetRestaurantBranchesNameAndId/1248";
  static const String menu =   "get_main_data";
  static const String getAddresses      = "${baseUrlV2}get_customer_addresses";
  static const String addEditAddress    = "${baseUrlV2}add_edit_customer_address";
  static const String getDeliveryCharges = "${baseUrlV1}GetDeliveryCharges";
  static const String getOrderHistory = "${baseUrlV2}get_order_history";
  static const String getCouponsByUserId = "${baseUrlV1}GetCouponsByUserId";
  static const String getValidateCoupon  = "${baseUrlV1}GetValidateCoupon";
  static const String baseUrlV2Root =
      "https://admin.cherryberryrms.com/v2/api/";
  static const String validatePromotion =
      "${baseUrlV2Root}promotions/validate";
  static const guestSignUp = '${baseUrlV2}guest_signup';
  static const String getLoyaltyTransactions = "${baseUrlV2}get_loyalty_transactions";
  static const String getPointConvertPackages = "${baseUrlV2}get_point_convert_packages";
  static const String convertLoyaltyPointsToWallet = "${baseUrlV2}convert_loyalty_points_to_wallet";
  static const String getWalletTransactions = "${baseUrlV2}get_wallet_transactions";
  //  place order endpoint
  static const String placeOrder = "${baseUrlV2}add_edit_order";

// Signup API
  static const String signup = "signup";

// Login API
  static const String login = "login";

// Signup OTP verify API
  static const String verifyOtp = "verify_otp";

// Signup OTP resend API
  static const String resendOtp = "resend_otp";

// Forgot password OTP send API
  static const String sendOtp = "sendOtp";

// Forgot password OTP verify API
  static const String verifyForgotOtp = "verifyOtp";

// Change password API
  static const String changePassword = "changePassword";

// Delete account API
  static const String deleteAccount = "MobileUserDelete";

}