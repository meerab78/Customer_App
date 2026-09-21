import '../../../api_service/api_constants.dart';
import '../../../api_service/api_service.dart';
import '../../../core/db/shared_pref.dart';
import 'model/convert_package_response.dart';
import 'model/response.dart';

class LoyaltyRepository {
  final ApiService _api = ApiService();
  final SharedPrefService _prefs = SharedPrefService();

  Future<LtData?> getLoyaltyTransactions() async {
    final token = await _prefs.getToken();

    final response = await _api.getRequest(
      ApiConstants.getLoyaltyTransactions,
      token: token,
    );

    final parsed = GetLoyaltyTransactionResponse.fromJson(response);

    if (parsed.success == true) {
      return parsed.data;
    }
    return null;
  }

  Future<List<ConvertPackage>> getPointConvertPackages() async {
    final token = await _prefs.getToken();

    final response = await _api.getRequest(
      ApiConstants.getPointConvertPackages,
      token: token,
    );

    if (response['Success'] == true && response['Data'] is List) {
      final List list = response['Data'] as List;
      return list.map((e) => ConvertPackage.fromJson(e)).toList();
    }
    return [];
  }

  Future<ConvertResult> convertPointsToWallet(String packageId) async {
    final token = await _prefs.getToken();

    final body = {"loyalty_wallet_package_id": packageId};

    final response = await _api.postRequest(
      ApiConstants.convertLoyaltyPointsToWallet,
      body,
      token: token,
    );

    if (response['Success'] == true) {
      return ConvertResult.success(
        response['Message']?.toString() ?? "Converted successfully",
      );
    }

    return ConvertResult.fail(
      response['ErrorMessage']?.toString() ??
          response['Message']?.toString() ??
          "Conversion failed",
    );
  }
}

class ConvertResult {
  final bool success;
  final String message;

  ConvertResult.success(this.message) : success = true;
  ConvertResult.fail(this.message) : success = false;
}