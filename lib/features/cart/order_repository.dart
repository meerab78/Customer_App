import '../../api_service/api_constants.dart';
import '../../api_service/api_service.dart';
import '../../core/db/shared_pref.dart';
import 'model/order_history_model.dart';

class OrderRepository {
  final ApiService _api = ApiService();
  final SharedPrefService _prefs = SharedPrefService();

  Future<List<OrderHistory>> getOrderHistory(String restaurantId) async {
    final token = await _prefs.getToken();
    final response = await _api.getRequest(
      "${ApiConstants.getOrderHistory}?restaurant_id=$restaurantId",
      token: token,
    );

    if (response['Success'] == true && response['Data'] is List) {
      final List list = response['Data'] as List;
      return list.map((e) => OrderHistory.fromJson(e)).toList();
    }
    return [];
  }

  // place_order ko POST karta hai, raw server response wapas deta hai
  // ({Success, Message, ErrorMessage, Data, Status})
  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> body) async {
    final token = await _prefs.getToken();

    final response = await _api.postRequest(
      "${ApiConstants.baseUrlV2}add_edit_order",
      body,
      token: token,
    );

    // DEBUG
    print("PLACE ORDER REQUEST: $body");
    print("PLACE ORDER RESPONSE: $response");

    return Map<String, dynamic>.from(response);
  }
}