import '../../../api_service/api_constants.dart';
import '../../../api_service/api_service.dart';
import '../../../core/db/shared_pref.dart';
import 'model/response.dart';

class WalletRepository {
  final ApiService _api = ApiService();
  final SharedPrefService _prefs = SharedPrefService();

  Future<WalletTransactionData?> getWalletTransactions() async {   // ✅ renamed
    final token = await _prefs.getToken();

    final response = await _api.getRequest(
      ApiConstants.getWalletTransactions,
      token: token,
    );

    final parsed = GetWalletTransactionResponse.fromJson(response);

    if (parsed.success == true) {
      return parsed.data;
    }
    return null;
  }
}