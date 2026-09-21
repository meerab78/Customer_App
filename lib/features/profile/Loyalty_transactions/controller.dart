import 'package:flutter/material.dart';
import 'model/convert_package_response.dart';
import 'repository.dart';
import 'model/response.dart';

class LoyaltyController extends ChangeNotifier {
  final LoyaltyRepository _repo = LoyaltyRepository();

  bool isLoading = false;
  bool isLoadingPackages = false;
  bool isRedeeming = false;

  double loyaltyPoints = 0;
  List<LoyaltyTransaction> transactions = [];
  List<ConvertPackage> packages = [];
  String? errorMessage;

  Future<void> loadLoyaltyData() async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _repo.getLoyaltyTransactions();
      if (data != null) {
        loyaltyPoints = double.tryParse('${data.loyaltyPoints}') ?? 0;
        transactions = data.loyaltyTransactions;
      }
    } catch (e) {
      debugPrint("loadLoyaltyData error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadPackages() async {
    isLoadingPackages = true;
    notifyListeners();

    try {
      packages = await _repo.getPointConvertPackages();
    } catch (e) {
      debugPrint("loadPackages error: $e");
      packages = [];
    }

    isLoadingPackages = false;
    notifyListeners();
  }

  Future<bool> redeemPackage(String packageId) async {
    isRedeeming = true;
    errorMessage = null;
    notifyListeners();

    bool success = false;

    try {
      final result = await _repo.convertPointsToWallet(packageId);

      if (result.success) {
        success = true;
        await loadLoyaltyData();
      } else {
        errorMessage = result.message;
      }
    } catch (e) {
      debugPrint("redeemPackage error: $e");
      errorMessage = "Something went wrong. Try again.";
    }

    isRedeeming = false;
    notifyListeners();
    return success;
  }

  bool canRedeem(ConvertPackage package) {
    return loyaltyPoints >= package.points;
  }
}