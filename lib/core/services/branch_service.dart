

import '../models/branch_model.dart';
import 'api_constants.dart';
import 'api_services.dart';

class BranchService {
  final ApiService _apiService = ApiService();

  Future<BranchModel> getBranches() async {
    final url =
        '${ApiConstants.baseUrlV1}${ApiConstants.branches}';

    final response = await _apiService.getRequest(url);
    return BranchModel.fromJson(response);
  }
}