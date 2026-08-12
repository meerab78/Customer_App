import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static const String tokenKey = "token";
  static const String deviceIdKey = "device_id";

  // static const String orderTypeShownKey = "order_type_shown";

  static const String addressKey = "address1";
  static const String latitudeKey = "latitude";
  static const String longitudeKey = "longitude";
  static const String isDefaultKey = "isDefault";

  static const String userIdKey = "user_id";
  static const String customerIdKey = "customer_id";
  static const String nameKey = "name";
  static const String emailKey = "email";
  static const String phoneKey = "phone";
  static const String restaurantIdKey = "restaurant_id";
  static const String restaurantNameKey = "restaurant_name";

  static const String dateOfBirthKey = "date_of_birth";
  static const String genderKey = "gender";

  // AUTH

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> saveDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(deviceIdKey, deviceId);
  }

  Future<String?> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(deviceIdKey);
  }

  // USER

  Future<void> saveUserData({
    required int userId,
    required String customerId,
    required String name,
    required String email,
    required String phone,
    required int restaurantId,
    required String restaurantName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(userIdKey, userId);
    await prefs.setString(customerIdKey, customerId);
    await prefs.setString(nameKey, name);
    await prefs.setString(emailKey, email);
    await prefs.setString(phoneKey, phone);
    await prefs.setInt(restaurantIdKey, restaurantId);
    await prefs.setString(restaurantNameKey, restaurantName);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(userIdKey);
  }

  Future<String?> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(customerIdKey);
  }

  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(nameKey);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(emailKey);
  }

  Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(phoneKey);
  }

  Future<int?> getRestaurantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(restaurantIdKey);
  }

  Future<String?> getRestaurantName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(restaurantNameKey);
  }

  // EDIT PROFILE

  Future<void> saveProfileDetails({
    required String name,
    String? dateOfBirth,
    String? gender,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(nameKey, name);

    if (dateOfBirth != null) {
      await prefs.setString(dateOfBirthKey, dateOfBirth);
    }

    if (gender != null) {
      await prefs.setString(genderKey, gender);
    }
  }

  Future<String?> getDateOfBirth() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(dateOfBirthKey);
  }

  Future<String?> getGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(genderKey);
  }

  // ADDRESS

  Future<void> saveAddress({
    required String address,
    required String latitude,
    required String longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(addressKey, address);
    await prefs.setString(latitudeKey, latitude);
    await prefs.setString(longitudeKey, longitude);
    await prefs.setInt(isDefaultKey, 1);
  }

  Future<String?> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(addressKey);
  }

  Future<String?> getLatitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(latitudeKey);
  }

  Future<String?> getLongitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(longitudeKey);
  }

  Future<bool> hasAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(addressKey);
  }

  Future<void> clearAddress() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(addressKey);
    await prefs.remove(latitudeKey);
    await prefs.remove(longitudeKey);
    await prefs.remove(isDefaultKey);
  }

  //LOGOUT / DELETE

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(tokenKey);
    await prefs.remove(deviceIdKey);

    await prefs.remove(userIdKey);
    await prefs.remove(customerIdKey);
    await prefs.remove(nameKey);
    await prefs.remove(emailKey);
    await prefs.remove(phoneKey);
    await prefs.remove(restaurantIdKey);
    await prefs.remove(restaurantNameKey);

    await prefs.remove(dateOfBirthKey);
    await prefs.remove(genderKey);
  }
}