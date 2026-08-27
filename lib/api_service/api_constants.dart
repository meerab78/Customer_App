class ApiConstants {
  static const String baseUrlV1=  "https://dev-admin.cherryberrycloud.com/api/";
  static const String baseUrlV2=   "https://dev-admin.cherryberrycloud.com/v2/api/onlineapp/";
  static const String  branches =   "GetRestaurantBranchesNameAndId/1248";
  static const String menu =   "get_main_data";
  static const String getAddresses      = "${baseUrlV2}get_customer_addresses";
  static const String addEditAddress    = "${baseUrlV2}add_edit_customer_address";
  static const String getDeliveryCharges = "${baseUrlV1}GetDeliveryCharges";
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