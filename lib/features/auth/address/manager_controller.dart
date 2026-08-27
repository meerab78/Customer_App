
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/address_model.dart';
import 'repository.dart';

class AddressManagerController extends ChangeNotifier {
  final AddressRepository _repo = AddressRepository();

  // Address loading aur saving ke states
  bool isLoading = false;
  bool isSaving = false;


  // Delivery status
  bool deliveryAvailable = true;
  String? deliveryMessage;

  // Customer addresses
  List<CustomerAddress> addresses = [];

  // Currently selected address
  CustomerAddress? selectedAddress;

  // Delivery fee
  bool isCalculatingFee = false;
  double deliveryFee = 0;

  // LOAD ADDRESSES
  Future<void> loadAddresses() async {
    isLoading = true;
    notifyListeners();

    try {
      // API se addresses get karo
      addresses = await _repo.getCustomerAddresses();

      // Default address select karo
      _preselectDefault();
    } catch (e) {
      debugPrint("loadAddresses error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // Default address ko select karo
  void _preselectDefault() {
    // Agar koi address nahi hai
    if (addresses.isEmpty) {
      selectedAddress = null;
      return;
    }

    // Pehle default address find karo
    for (CustomerAddress address in addresses) {
      if (address.isDefault == 1) {
        selectedAddress = address;
        return;
      }
    }

    // Agar default address nahi mila
    // to pehla address select kar do
    selectedAddress = addresses.first;
  }

  // Checkout se address select karna
  void selectAddress(CustomerAddress address) {
    selectedAddress = address;

    notifyListeners();
  }
  // AUTO CREATE HOME ADDRESS

  // First time Home address automatically create karta hai
  // Map picker se SharedPreferences mein save ki hui
  // address, latitude aur longitude use hoti hai.

  Future<void> ensureHomeAddress() async {
    // Agar addresses already loaded hain
    // to naya Home address nahi banana
    if (addresses.isNotEmpty) {
      return;
    }

    // SharedPreferences open karo
    final prefs = await SharedPreferences.getInstance();

    // Latitude aur longitude get karo
    final double? latitude = prefs.getDouble("latitude");
    final double? longitude = prefs.getDouble("longitude");

    // Address get karo
    // Pehle full address check hoga
    // agar nahi mila to address_area use hoga
    final String address =
        prefs.getString("address") ??
            prefs.getString("address_area") ??
            "Home";

    // Agar latitude ya longitude nahi hai
    // to address create nahi karna
    if (latitude == null || longitude == null) {
      return;
    }

    // Agar location 0,0 hai
    // to bhi address create nahi karna
    if (latitude == 0 && longitude == 0) {
      return;
    }

    // Home address save karo
    await addEditAddress(
      addressTypeId: 3,
      address1: address.isEmpty ? "Home" : address,
      latitude: latitude.toString(),
      longitude: longitude.toString(),
      isDefault: 1,
    );
  }
  // ADD / EDIT ADDRESS


  Future<bool> addEditAddress({
    String? addressId,
    required int addressTypeId,
    required String address1,
    int? townId,
    int? townBlockId,
    required String latitude,
    required String longitude,
    required int isDefault,
  }) async {
    isSaving = true;
    notifyListeners();

    bool success = false;

    try {
      // Address repository ko call karo
      final saved = await _repo.addEditAddress(
        addressId: addressId,
        addressTypeId: addressTypeId,
        address1: address1,
        townId: townId,
        townBlockId: townBlockId,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );

      // Agar address successfully save hua
      if (saved != null) {
        success = true;

        // Address list dobara load karo
        await loadAddresses();

        // Agar saved address default hai
        // to usko selected address bana do
        if (isDefault == 1) {
          for (CustomerAddress address in addresses) {
            if (address.addressId == saved.addressId) {
              selectedAddress = address;
              break;
            }
          }

          // Agar list mein address na mile
          // to saved address select kar do
          if (selectedAddress == null) {
            selectedAddress = saved;
          }
        }
      }
    } catch (e) {
      debugPrint("addEditAddress error: $e");
    }

    isSaving = false;
    notifyListeners();

    return success;
  }

  // DELIVERY FEE

  Future<void> recalculateDeliveryFee({
    required String branchId,
    required double orderAmount,
  }) async {
    // Agar address select nahi hai
    if (selectedAddress == null) {
      deliveryFee = 0;
      deliveryAvailable = false;
      deliveryMessage =
      "Please select a delivery address";

      notifyListeners();
      return;
    }

    // Delivery fee calculate ho rahi hai
    isCalculatingFee = true;
    deliveryMessage = null;

    notifyListeners();

    try {
      // Delivery charges API call
      final result = await _repo.getDeliveryCharges(
        branchId: branchId,
        latitude: selectedAddress!.latitude,
        longitude: selectedAddress!.longitude,
        orderAmt: orderAmount.toString(),
      );

      // Delivery available hai
      if (result.available) {
        deliveryFee = result.charge;
        deliveryAvailable = true;
        deliveryMessage = null;
      }

      // Delivery available nahi hai
      else {
        deliveryFee = 0;
        deliveryAvailable = false;
        deliveryMessage = result.message;
      }
    } catch (e) {
      debugPrint(
        "recalculateDeliveryFee error: $e",
      );

      deliveryFee = 0;
      deliveryAvailable = false;

      deliveryMessage =
      "Something went wrong. Please try again.";
    }

    // Calculation complete
    isCalculatingFee = false;

    notifyListeners();
  }
}