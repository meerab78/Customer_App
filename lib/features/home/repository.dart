import 'model/branch_model.dart';
import 'model/menu_model.dart';
import '../../api_service/api_constants.dart';
import '../../api_service/api_service.dart';

class BranchRepository {
  final ApiService _apiService = ApiService();

  Future<BranchModel> getBranches() async {
    final url =
        '${ApiConstants.baseUrlV1}${ApiConstants.branches}';

    final response = await _apiService.getRequest(url);
    return BranchModel.fromJson(response);
  }
}

class MenuRepository {
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
