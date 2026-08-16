
import 'package:flutter/foundation.dart';
import 'repository.dart';
import '../../core/db/shared_pref.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  bool _isLoading = false;
  String? _errorMessage;

  dynamic _signupResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  dynamic get signupResponse => _signupResponse;

// Signup
  Future signup({
    required String email,
    required int restaurantId,
    required String cellNum,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.signup(
        email: email,
        restaurantId: restaurantId,
        cellNum: cellNum,
        password: password,
        name: name,
      );

      _signupResponse = response;

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }
// Login
  Future login({
    required String restaurantId,
    required String email,
    required String orderResourceId,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.login(
        restaurantId: restaurantId,
        deviceId: 'test_device_001',
        email: email,
        orderResourceId: orderResourceId,
        password: password,
      );

      final data = response['Data'];

      if (data == null) {
        throw Exception('User data not received');
      }

      final token = data['token'];

      if (token == null) {
        throw Exception('Token not received');
      }

      // Save token
      await _sharedPrefService.saveToken(
        token.toString(),
      );

      // Save user data
      await _sharedPrefService.saveUserData(
        userId: data['id'],
        customerId: data['customer_id'],
        name: data['name'].toString().trim(),
        email: data['email'],
        phone: data['cell_num'],
        restaurantId: data['restaurant_id'],
        restaurantName: data['restaurant_name'],
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }
// Verify signup OTP
  Future verifySignupOtp({
    required String customerId,
    required String otp,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.verifySignupOtp(
        customerId: customerId,
        otp: otp,
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

// Resend signup OTP
  Future resendSignupOtp({
    required String customerId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.resendSignupOtp(
        customerId: customerId,
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

// Send forgot password OTP
  Future<bool> sendForgotPasswordOtp({
    required int restaurantId,
    required String email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.sendForgotPasswordOtp(
        restaurantId: restaurantId,
        email: email,
      );

      if (response['Success'] != true) {
        throw Exception(
          response['Message'] ?? 'Failed to send OTP',
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

// Verify forgot password OTP
  Future<bool> verifyForgotPasswordOtp({
    required String restaurantId,
    required String email,
    required String otp,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.verifyForgotPasswordOtp(
        restaurantId: restaurantId,
        email: email,
        otp: otp,
      );

      if (response['Success'] != true) {
        throw Exception(
          response['Message'] ?? 'Invalid OTP',
        );
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

// Change password
  Future<bool> changePassword({
    required String restaurantId,
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.changePassword(
        restaurantId: restaurantId,
        email: email,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (response['Success'] != true) {
        throw Exception(
          response['Message'] ?? 'Failed to change password',
        );
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }
// Delete account
  Future deleteAccount({
    required String userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.deleteAccount(
        userId: userId,
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }
  Future<String?> getSavedUserEmail() async {
    return await _sharedPrefService.getEmail();
  }
  Future<int?> getSavedRestaurantId() async {
    return await _sharedPrefService.getRestaurantId();
  }

// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}



