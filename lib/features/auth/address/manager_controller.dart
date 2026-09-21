
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/db/shared_pref.dart';
import 'model/address_model.dart';
import 'repository.dart';

class AddressManagerController extends ChangeNotifier {
  final AddressRepository _repo = AddressRepository();
  final SharedPrefService _prefs = SharedPrefService();
  // Address loading aur saving ke states
  bool isLoading = false;
  bool isSaving = false;
  bool userEditedAddress = false;
  bool _isPersistingAddress = false;

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
      addresses = await _repo.getCustomerAddresses();

      if (selectedAddress != null) {
        bool stillExists = false;

        // Pehle addressId se match karo
        for (final address in addresses) {
          if (address.addressId == selectedAddress!.addressId) {
            selectedAddress = address;
            stillExists = true;
            break;
          }
        }

        // Agar addressId se match nahi hua (local/unsaved address tha)
        // to lat/lng se match karo
        if (!stillExists && selectedAddress!.addressId == null) {
          for (final address in addresses) {
            if (address.latitude == selectedAddress!.latitude &&
                address.longitude == selectedAddress!.longitude) {
              selectedAddress = address;
              stillExists = true;
              break;
            }
          }
        }

        if (!stillExists) {
          _preselectDefault();
        }
      }else {
        _preselectDefault();
      }
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
    if (addresses.isNotEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    double? latitude;
    double? longitude;

    try { latitude = prefs.getDouble("latitude"); } catch (_) {}
    try { longitude = prefs.getDouble("longitude"); } catch (_) {}

    if (latitude == null || longitude == null) {
      try {
        final latStr = prefs.getString("latitude");
        final lngStr = prefs.getString("longitude");
        if (latStr != null) latitude = double.tryParse(latStr);
        if (lngStr != null) longitude = double.tryParse(lngStr);
      } catch (_) {}
    }

    if (latitude == null || longitude == null) {
      try {
        final latVal = prefs.get("latitude");
        final lngVal = prefs.get("longitude");
        if (latVal != null) latitude = double.tryParse(latVal.toString());
        if (lngVal != null) longitude = double.tryParse(lngVal.toString());
      } catch (_) {}
    }

    final String address = prefs.getString("address") ??
        prefs.getString("address_area") ??
        "Home";

    if (latitude == null || longitude == null) return;
    if (latitude == 0 && longitude == 0) return;

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
    final bool isFirstTimeCreate = addressId == null;

    try {
      // Address repository.dart ko call karo
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
        if (isDefault == 1) {
          CustomerAddress? matched;
          for (final address in addresses) {
            if (address.addressId == saved.addressId) {
              matched = address;
              break;
            }
          }
          selectedAddress = matched ?? saved;
        }
        if (isFirstTimeCreate && addressTypeId == 3) {
          await _prefs.setHomeAddressCreated(true); // NEW — safe discard
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

  Future<void> useLocalAddressForGuest() async {
    final prefs = await SharedPreferences.getInstance();

    double? latitude;
    double? longitude;
    String address = "";

    // Try EVERY possible way to read lat/lng
    // kyunki kahin setDouble se save hua, kahin setString se
    try { latitude = prefs.getDouble("latitude"); } catch (_) {}
    try { longitude = prefs.getDouble("longitude"); } catch (_) {}

    if (latitude == null || longitude == null) {
      try {
        final latStr = prefs.getString("latitude");
        final lngStr = prefs.getString("longitude");
        if (latStr != null) latitude = double.tryParse(latStr);
        if (lngStr != null) longitude = double.tryParse(lngStr);
      } catch (_) {}
    }

    // Agar ab bhi null hai to generic get se try karo
    if (latitude == null || longitude == null) {
      try {
        final latVal = prefs.get("latitude");
        final lngVal = prefs.get("longitude");
        if (latVal != null) latitude = double.tryParse(latVal.toString());
        if (lngVal != null) longitude = double.tryParse(lngVal.toString());
      } catch (_) {}
    }

    // Address string
    address = prefs.getString("address") ??
        prefs.getString("address_area") ??
        "";

    debugPrint("=== GUEST ADDRESS DEBUG ===");
    debugPrint("lat: $latitude, lng: $longitude, addr: $address");
    debugPrint("===========================");

    if (latitude == null || longitude == null) {
      debugPrint("useLocalAddressForGuest: no lat/lng found");
      return;
    }
    if (latitude == 0 && longitude == 0) return;
    if (address.isEmpty) address = "Home";

    selectedAddress = CustomerAddress(
      addressTypeId: 3,
      addressType: 'Home',
      address1: address,
      latitude: latitude.toString(),
      longitude: longitude.toString(),
      isDefault: 1,
    );

    debugPrint("useLocalAddressForGuest: loaded => $address");
    notifyListeners();
  }

  Future<bool> persistSelectedAddressIfNeeded() async {
    final addr = selectedAddress;
    if (addr == null) return false;
    if (addr.id != null) return true; // already saved

    if (_isPersistingAddress) return false; // lock
    _isPersistingAddress = true;

    try {
      // Hamesha FRESH list se check karo — stale list galat CREATE karati hai
      await loadAddresses();

      CustomerAddress? existingSameType;
      for (final a in addresses) {
        if (a.addressTypeId == (addr.addressTypeId ?? 3)) {
          existingSameType = a;
          break;
        }
      }

      bool saved = await addEditAddress(
        addressId: existingSameType?.addressId,
        addressTypeId: addr.addressTypeId ?? 3,
        address1: addr.address1,
        latitude: addr.latitude,
        longitude: addr.longitude,
        isDefault: 1,
      );

      // FALLBACK: agar CREATE ki thi (existingSameType null tha) aur
      // backend ne "already exist" bola, list refresh karke UPDATE se retry
      if (!saved && existingSameType == null) {
        await loadAddresses();
        CustomerAddress? retryMatch;
        for (final a in addresses) {
          if (a.addressTypeId == (addr.addressTypeId ?? 3)) {
            retryMatch = a;
            break;
          }
        }
        if (retryMatch != null) {
          saved = await addEditAddress(
            addressId: retryMatch.addressId,
            addressTypeId: addr.addressTypeId ?? 3,
            address1: addr.address1,
            latitude: addr.latitude,
            longitude: addr.longitude,
            isDefault: 1,
          );
        }
      }

      return saved;
    } finally {
      _isPersistingAddress = false;
    }
  }
}