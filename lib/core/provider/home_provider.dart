
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/branch_model.dart';
import '../models/menu_model.dart';
import '../services/branch_service.dart';
import '../services/location_Services.dart';
import '../services/menu_services.dart' show MenuService;

class HomeProvider extends ChangeNotifier {
  final BranchService _branchService = BranchService();
  final MenuService _menuService = MenuService();
  final LocationService _locationService = LocationService();
  bool isLoading = false;
  BranchModel? branchModel;
  MenuModel? menuModel;
  Branch? selectedBranch;
  double? userLatitude;
  double? userLongitude;
  Branch? recommendedBranch;

  int selectedCategoryIndex = 0;
  void changeCategory(int index) {
    selectedCategoryIndex = index;
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading = true;
      notifyListeners();
      final position = await _locationService.getCurrentLocation();
      userLatitude = position.latitude;
      userLongitude = position.longitude;
        } catch (e) {
      print(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<void> getBranches() async {
    try {
      branchModel = await _branchService.getBranches();
      notifyListeners();
    } catch(e){
      print(e);
    }
  }

  Future<void> findNearestBranch() async {
    if (branchModel == null) return;
    if (userLatitude == null || userLongitude == null) return;
    double shortestDistance = double.infinity;
    for (Branch branch in branchModel!.data) {
      double distance = Geolocator.distanceBetween(
        userLatitude!,
        userLongitude!,
        double.parse(branch.latitude!),
        double.parse(branch.longitude!),
      );
      if (distance < shortestDistance) {
        shortestDistance = distance;
        selectedBranch = branch;
        recommendedBranch = branch;
      }
    }
    notifyListeners();
  }
  Future<void> getMenu() async {
    if(selectedBranch == null) return;
    try{
      menuModel =
      await _menuService.getMenu(
          selectedBranch!.id.toString()
      );
      notifyListeners();
    }catch(e){
      print(e);
    }
  }
  Future<void> loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();

    userLatitude = prefs.getDouble("latitude");
    userLongitude = prefs.getDouble("longitude");
  }
  Future<void> loadHomeData() async {
    isLoading = true;
    notifyListeners();
    try {
      await loadSavedLocation();
      await getBranches();
      await findNearestBranch();
      await getMenu();
    } catch (e) {
      print(e);
    }
    isLoading = false;
    notifyListeners();
  }
  double getDistanceFromUser(Branch branch) {
    if (userLatitude == null || userLongitude == null) {
      return 0;
    }
    double distance = Geolocator.distanceBetween(
      userLatitude!,
      userLongitude!,
      double.parse(branch.latitude!),
      double.parse(branch.longitude!),
    );
    return distance / 1000; // kilometer
  }
  Future<void> selectBranch(Branch branch) async {
    selectedBranch = branch;
    notifyListeners();
    await getMenu();
  }
}