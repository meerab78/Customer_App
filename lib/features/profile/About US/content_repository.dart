import 'package:customer_app/features/profile/About%20US/resturant_content_model.dart';
import '../../../api_service/api_constants.dart';
import '../../../api_service/api_service.dart';
class ContentRepository {
  final ApiService _apiService = ApiService();

  Future<RestaurantContentModel> getRestaurantContent() async {
    final url =
        "${ApiConstants.baseUrlV2}${ApiConstants.restaurantContent}"
        "?restaurant_id=${ApiConstants.restaurantId}";

    final response = await _apiService.getRequest(url);
    return RestaurantContentModel.fromJson(response);
  }
}