
import 'package:customer_app/features/home/widget/food_detail_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/branch_model.dart';
import 'model/menu_model.dart';
import 'repository.dart';
import '../../api_service/location_service.dart';

class HomeController extends ChangeNotifier {
  final BranchRepository _branchRepository = BranchRepository();
  final MenuRepository _menuRepository = MenuRepository();
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
      branchModel = await _branchRepository.getBranches();
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
  Future<void> getMenu(String branchId) async {
    menuModel = await _menuRepository.getMenu(branchId);

    // TEMPORARY PRICE CHECK
    if (menuModel?.data != null) {
      for (final category
      in menuModel!.data!.restaurantBranchMenu) {
        for (final food in category.menu) {
        }
      }
    }

    notifyListeners();
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
      if (selectedBranch != null) {
        await getMenu(selectedBranch!.id.toString());
      }
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
  // Future<void> selectBranch(Branch branch) async {
  //   selectedBranch = branch;
  //   notifyListeners();
  //   await getMenu(selectedBranch!.id.toString());
  // }
  Future<void> selectBranch(Branch branch) async {
    selectedBranch = branch;
    selectedCategoryIndex = 0;

    notifyListeners();

    await getMenu(branch.id.toString());
  }
  void onMenuItemTap(
      BuildContext context,
      Menu food,
      ) {
    showFoodDetailBottomSheet(
      context,
      food,
    );
  }


}
