import '../../api_service/api_constants.dart';
import '../../api_service/api_service.dart';
import '../../core/db/shared_pref.dart';

class OrderRepository {
  final ApiService _api = ApiService();
  final SharedPrefService _prefs = SharedPrefService();

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