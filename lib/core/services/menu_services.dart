
import '../models/menu_model.dart';
import 'api_constants.dart';
import 'api_services.dart';

class MenuService {
  final ApiService _apiService = ApiService();
  Future<MenuModel> getMenu(String branchId) async {
    final url =
        "${ApiConstants.baseUrlV2}"
        "${ApiConstants.menu}"
        "?restaurant_branch_id=$branchId"
        "&order_resource_id=3";
    final response = await _apiService.getRequest(url);
    return MenuModel.fromJson(response);
  }
}