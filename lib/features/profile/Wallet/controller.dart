import 'package:flutter/material.dart';
import 'repository.dart';
import 'model/response.dart';

class WalletController extends ChangeNotifier {
  final WalletRepository _repo = WalletRepository();

  bool isLoading = false;
  double walletAmount = 0;
  List<WalletTransaction> transactions = [];

  Future<void> loadWalletData() async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _repo.getWalletTransactions();
      if (data != null) {
        walletAmount = double.tryParse('${data.walletAmount}') ?? 0;
        transactions = data.walletTransactions;
      }
    } catch (e) {
      debugPrint("loadWalletData error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}