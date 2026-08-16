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
  Marker? currentMarker;
  bool isLoading = false;
  String selectedAddress = "";
  double? latitude;
  double? longitude;
  final TextEditingController searchController =
  TextEditingController();
  final PlaceSearchService _placeService =
  PlaceSearchService();
  List<dynamic> searchResults = [];
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
  Future<void> searchAddress(String value) async {
    searchResults =
    await _placeService.searchPlaces(value);
    notifyListeners();
  }
  Future<void> selectPlace(String placeId) async {
    final place = await _placeService.getPlaceDetails(placeId);
    if (place == null) return;
    latitude = place["geometry"]["location"]["lat"];
    longitude = place["geometry"]["location"]["lng"];
    selectedAddress = place["formatted_address"];
    currentMarker = Marker(
      markerId: const MarkerId("selected_location"),
      position: LatLng(
        latitude!,
        longitude!,
      ),
    );
    await mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(
          latitude!,
          longitude!,
        ),
        17,
      ),
    );
    searchResults.clear();
    notifyListeners();
  }
  // Current Location
  Future<void> getCurrentLocation() async {
    try {
      isLoading = true;
      notifyListeners();
      Position position =
      await _locationService.getCurrentLocation();
      latitude = position.latitude;
      longitude = position.longitude;
      debugPrint("LAT : $latitude");
      debugPrint("LONG : $longitude");
      currentMarker = Marker(
        markerId: const MarkerId("current_location"),
        position: LatLng(
          latitude!,
          longitude!,
        ),
        draggable: true,
        onDragEnd: (value) {
          updateMarker(value);
        },
      );
      if(mapController != null){
        await mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(
              latitude!,
              longitude!,
            ),
            17,
          ),
        );
      }
      await getAddressFromLatLng();
      notifyListeners();
    } catch(e){
      debugPrint(
        e.toString(),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  /// Change Marker Position
  Future<void> updateMarker(LatLng position) async {
    latitude = position.latitude;
    longitude = position.longitude;
    currentMarker = Marker(
      markerId: const MarkerId("current"),
      position: position,
      draggable: true,
      onDragEnd: (value) {
        updateMarker(value);
      },
    );
    await getAddressFromLatLng();
    notifyListeners();
  }
  /// Save Address
  Future<void> saveAddress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      "address",
      selectedAddress,
    );
    await prefs.setDouble(
      "latitude",
      latitude ?? 0,
    );
    await prefs.setDouble(
      "longitude",
      longitude ?? 0,
    );
    await prefs.setBool(
      "address_saved",
      true,
    );
  }
  ///Check Address
  Future<bool> hasSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("address_saved") ?? false;
  }
  /// Load Saved Address
  Future<void> loadSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    selectedAddress =
        prefs.getString("address") ?? "";
    latitude =
        prefs.getDouble("latitude");
    longitude =
        prefs.getDouble("longitude");
    notifyListeners();
  }
  Future<void> getAddressFromLatLng() async {
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json"
        "?latlng=$latitude,$longitude"
        "&key=AIzaSyBUbCbmkNfSvQ8nflO64lgaIowblekfTrc";
    final response = await http.get(
      Uri.parse(url),
    );
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      if(data["results"].isNotEmpty){
        selectedAddress =
        data["results"][0]["formatted_address"];
        notifyListeners();
      }
    }
  }
}
