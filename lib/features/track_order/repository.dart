import '../../api_service/api_constants.dart';
import '../../api_service/api_service.dart';
import '../../core/db/shared_pref.dart';

class OrderTrackingRepository {
  final ApiService _apiService = ApiService();
  Future<Map<String, dynamic>?> getOrderTracking(
      String orderId) async {
    final url = "${ApiConstants.getOrderTracking}?order_id=$orderId";
    print("TRACKING URL: $url");
    final SharedPrefService _prefs = SharedPrefService();
    final token = await _prefs.getToken();

    try {
      final response = await _apiService.getRequest(url, token: token);
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      print("Order Tracking API Error: $e");
      return null;
    }
  }
}
