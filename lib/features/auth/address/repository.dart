

import '../../../api_service/api_constants.dart';
import '../../../api_service/api_service.dart';
import '../../../core/db/shared_pref.dart';
import 'model/address_model.dart' show CustomerAddress;
class DeliveryChargeResult {
  final bool available;
  final double charge;
  final String? message;

  DeliveryChargeResult.available(this.charge)
      : available = true,
        message = null;

  DeliveryChargeResult.notAvailable(this.message)
      : available = false,
        charge = 0;
}
class AddressRepository {
  final ApiService _api = ApiService();
  final SharedPrefService _prefs = SharedPrefService();


  // GET saved addresses
  Future<List<CustomerAddress>> getCustomerAddresses() async {
    final token = await _prefs.getToken();
    final response = await _api.getRequest(
      ApiConstants.getAddresses,
      token: token,
    );

    if (response['Success'] == true && response['Data'] is List) {
      final List list = response['Data'] as List;
      return list.map((e) => CustomerAddress.fromJson(e)).toList();
    }
    return [];
  }

  // ADD / EDIT (address_id sirf edit pe bhejo)
  // Returns saved CustomerAddress (server response se)
  Future<CustomerAddress?> addEditAddress({
    String? addressId,
    required int addressTypeId,
    required String address1,
    int? townId,
    int? townBlockId,
    required String latitude,
    required String longitude,
    required int isDefault,
  }) async {
    final token = await _prefs.getToken();
    final customerId = await _prefs.getCustomerId();

    final body = {
      "address_id": addressId ?? "",
      "customer_id": customerId ?? "",
      "address_type_id": addressTypeId,
      "address1": address1,
      "town_id": townId ?? 11,
      "town_block_id": townBlockId ?? 104,
      "latitude": latitude,
      "longitude": longitude,
      "is_default": isDefault,
    };

    final response = await _api.postRequest(
      ApiConstants.addEditAddress,
      body,
      token: token,
    );

    if (response['Success'] == true && response['Data'] is Map) {
      return CustomerAddress.fromJson(response['Data']);
    }
    return null;
  }

  // DELIVERY CHARGES — Data seedha string "100.00" aata hai
  Future<DeliveryChargeResult> getDeliveryCharges({
    required String branchId,
    required String latitude,
    required String longitude,
    required String orderAmt,
  }) async {
    final token = await _prefs.getToken();
    final body = {
      "branch_id": branchId,
      "latitude": latitude,
      "longitude": longitude,
      "order_amt": orderAmt,
    };

    final response = await _api.postRequest(
      ApiConstants.getDeliveryCharges,
      body,
      token: token,
    );

    if (response['Success'] == true) {
      final parsed = double.tryParse('${response['Data']}');
      if (parsed != null) {
        return DeliveryChargeResult.available(parsed);
      }
      return DeliveryChargeResult.notAvailable(
        response['Message']?.toString() ?? "Delivery not available in this area",
      );
    }

    return DeliveryChargeResult.notAvailable(
      response['Message']?.toString() ??
          response['ErrorMessage']?.toString() ??
          "Delivery not available in this area",
    );
  }
}