import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static const String addressKey = "address1";
  static const String latitudeKey = "latitude";
  static const String longitudeKey = "longitude";
  static const String isDefaultKey = "isDefault";
  static const String tokenKey = "token";
  static const String deviceIdKey = "device_id";
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

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(deviceIdKey);
  }
}