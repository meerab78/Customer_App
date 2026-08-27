import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../api_service/location_service.dart';
import '../../../api_service/place_search_service.dart';

class AddressController extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  GoogleMapController? mapController;

  bool isLoading = false;
  String selectedAddress = "";   // Google se fetch hua area/road address
  double? latitude;
  double? longitude;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController addressDetailController = TextEditingController(); // House/Street/Landmark

  final PlaceSearchService _placeService = PlaceSearchService();
  List<dynamic> searchResults = [];

  int _geocodeRequestId = 0; // stale response ignore karne ke liye

  @override
  void dispose() {
    searchController.dispose();
    addressDetailController.dispose();
    super.dispose();
  }

  Future<void> searchAddress(String value) async {
    searchResults = await _placeService.searchPlaces(value);
    notifyListeners();
  }

  /// Jab map drag start ho, purana address "Locating..." se replace karo
  void onMoveStarted() {
    isLoading = true;
    notifyListeners();
  }

  Future<void> selectPlace(String placeId) async {
    final place = await _placeService.getPlaceDetails(placeId);
    if (place == null) return;

    latitude = place["geometry"]["location"]["lat"];
    longitude = place["geometry"]["location"]["lng"];
    selectedAddress = place["formatted_address"];

    await mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(latitude!, longitude!), 17),
    );

    searchResults.clear();
    notifyListeners();
  }

  /// Current Location
  Future<void> getCurrentLocation() async {
    try {
      isLoading = true;
      notifyListeners();

      Position position = await _locationService.getCurrentLocation();
      latitude = position.latitude;
      longitude = position.longitude;
      debugPrint("LAT : $latitude");
      debugPrint("LONG : $longitude");

      if (mapController != null) {
        await mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(latitude!, longitude!), 17),
        );
      }

      await getAddressFromLatLng();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Reverse geocoding — sabse latest request ka hi result accept hota hai
  Future<void> getAddressFromLatLng() async {
    if (latitude == null || longitude == null) return;

    final int thisRequestId = ++_geocodeRequestId;
    final double reqLat = latitude!;
    final double reqLng = longitude!;

    final url = "https://maps.googleapis.com/maps/api/geocode/json"
        "?latlng=$reqLat,$reqLng"
        "&key=AIzaSyBUbCbmkNfSvQ8nflO64lgaIowblekfTrc";

    try {
      final response = await http.get(Uri.parse(url));

      // agar isse baad koi naya request ja chuka hai to ye result purana hai — ignore
      if (thisRequestId != _geocodeRequestId) {
        debugPrint("Ignoring stale geocode response for req $thisRequestId");
        return;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("GEOCODE STATUS: ${data["status"]}");

        if (data["status"] == "OK" && (data["results"] as List).isNotEmpty) {
          final results = data["results"] as List;

          final rooftop = results.firstWhere(
                (r) => r["geometry"]?["location_type"] == "ROOFTOP",
            orElse: () => null,
          );

          if (rooftop != null) {
            selectedAddress = rooftop["formatted_address"];
          } else {
            final rangeInterp = results.firstWhere(
                  (r) => r["geometry"]?["location_type"] == "RANGE_INTERPOLATED",
              orElse: () => null,
            );
            selectedAddress = (rangeInterp ?? results[0])["formatted_address"];
          }
        } else {
          debugPrint("Geocoding failed: ${data["error_message"] ?? data["status"]}");
        }
      } else {
        debugPrint("HTTP error: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("Geocode exception: $e");
    } finally {
      if (thisRequestId == _geocodeRequestId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Save Address — user ka house/street detail + Google address dono save
  Future<void> saveAddress() async {
    final prefs = await SharedPreferences.getInstance();

    final String extraDetail = addressDetailController.text.trim();

    final String fullAddress = extraDetail.isNotEmpty
        ? "$extraDetail, $selectedAddress"
        : selectedAddress;

    await prefs.setString("address", fullAddress);          // full address (Manage Address screen ke liye)
    await prefs.setString("address_area", selectedAddress); // sirf Google wala area address
    await prefs.setString("address_detail", extraDetail);   // sirf user ka likha hua detail
    await prefs.setDouble("latitude", latitude ?? 0);
    await prefs.setDouble("longitude", longitude ?? 0);
    await prefs.setBool("address_saved", true);
  }

  /// Check Address
  Future<bool> hasSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("address_saved") ?? false;
  }

  /// Load Saved Address
  Future<void> loadSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    selectedAddress = prefs.getString("address_area") ?? "";
    addressDetailController.text = prefs.getString("address_detail") ?? "";
    latitude = prefs.getDouble("latitude");
    longitude = prefs.getDouble("longitude");
    notifyListeners();
  }
}