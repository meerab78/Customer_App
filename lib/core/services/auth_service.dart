
import 'api_constants.dart';
import 'api_services.dart';
class AuthService {
  final ApiService _apiService = ApiService();

  Future<dynamic> signup({
    required String email,
    required int restaurantId,
    required String cellNum,
    required String password,
    required String name,
  }) async {
    final url =
        '${ApiConstants.baseUrlV2}${ApiConstants.signup}';

    final body = {
      "email": email,
      "restaurant_id": restaurantId,
      "cell_num": cellNum,
      "password": password,
      "name": name,
    };

    return await _apiService.postRequest(url, body);
  }

  Future<dynamic> login({
    required String restaurantId,
    required String deviceId,
    required String email,
    required String orderResourceId,
    required String password,
  }) async {
    final url =
        '${ApiConstants.baseUrlV2}${ApiConstants.login}';

    final body = {
      "restaurant_id": restaurantId,
      "device_id": deviceId,
      "email": email,
      "order_resource_id": orderResourceId,
      "password": password,
    };

    return await _apiService.postRequest(url, body);
  }

  Future verifySignupOtp({
    required String customerId,
    required String otp,
  }) async {
    final url =
        '${ApiConstants.baseUrlV2}${ApiConstants.verifyOtp}';
    final body = {
      "customer_id": customerId,
      "otp": otp,
    };
    print("VERIFY OTP URL: $url");
    print("VERIFY OTP BODY: $body");

    return await _apiService.postRequest(url, body);
  }

  Future<dynamic> resendSignupOtp({
    required String customerId,
  }) async {
    final url =
        '${ApiConstants.baseUrlV2}${ApiConstants.resendOtp}';

    final body = {
      "customer_id": customerId,
    };

    return await _apiService.postRequest(url, body);
  }

  Future<dynamic> sendForgotPasswordOtp({
    required int restaurantId,
    required String email,
  }) async {
    final url =
        '${ApiConstants.baseUrlV1}${ApiConstants.sendOtp}';

    final body = {
      "restaurant_id": restaurantId,
      "email": email,
    };

    return await _apiService.postRequest(url, body);
  }

  Future<dynamic> verifyForgotPasswordOtp({
    required String restaurantId,
    required String email,
    required String otp,
  }) async {
    final url =
        '${ApiConstants.baseUrlV1}${ApiConstants.verifyForgotOtp}';

    final body = {
      "restaurant_id": restaurantId,
      "email": email,
      "otp": otp,
    };

    return await _apiService.postRequest(url, body);
  }

  Future<dynamic> changePassword({
    required String restaurantId,
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final url =
        '${ApiConstants.baseUrlV1}${ApiConstants.changePassword}';

    final body = {
      "restaurant_id": restaurantId,
      "email": email,
      "new_password": newPassword,
      "confirm_password": confirmPassword,
    };

    return await _apiService.postRequest(url, body);
  }

  Future<dynamic> deleteAccount({
    required String userId,
  }) async {
    final url =
        '${ApiConstants.baseUrlV1}${ApiConstants.deleteAccount}';

    final body = {
      "user_id": userId,
    };

    return await _apiService.postRequest(url, body);
  }
}
