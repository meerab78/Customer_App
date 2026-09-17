import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../core/db/shared_pref.dart';
import 'order_repository.dart';
import 'model/order_history_model.dart';

class OrderController extends ChangeNotifier {
  final OrderRepository _repo = OrderRepository();
  final SharedPrefService _prefs = SharedPrefService();

  // ================= HISTORY LIST =================
  bool isLoadingHistory = true;
  List<OrderHistory> orders = [];
  Timer? _historyPollTimer;
  bool _historyPollingActive = false;

  void startHistoryPolling() {
    if (_historyPollingActive) return; // guard FIRST now
    _historyPollingActive = true;
    loadOrders(); // safe: only runs once per polling session

    _historyPollTimer = Timer.periodic(
      const Duration(seconds: 15),
          (timer) => loadOrders(silent: true),
    );
  }

  Future<void> loadOrders({bool silent = false}) async {

    if (!silent) {
      isLoadingHistory = true;
      notifyListeners();
    }

    try {
      String restaurantId = "1248";
      int? savedId = await _prefs.getRestaurantId();
      if (savedId != null) {
        restaurantId = savedId.toString();
      }

      List<OrderHistory> result = await _repo.getOrderHistory(restaurantId);
      result.sort((a, b) => b.orderDate.compareTo(a.orderDate));

      orders = result;
      isLoadingHistory = false;
      notifyListeners();
    } catch (e) {
      print("Order history error: $e");
      isLoadingHistory = false;
      if (e.toString().contains('401')) {
        stopHistoryPolling();
      }
      notifyListeners();
    }
  }

  // ================= SINGLE ORDER DETAILS =================
  OrderHistory? selectedOrder;
  Timer? _detailPollTimer;
  bool _detailPollingActive = false;

  void startDetailPolling(OrderHistory initialOrder) {
    // Skip if we're already polling this exact order
    if (_detailPollingActive && selectedOrder?.id == initialOrder.id) return;

    selectedOrder = initialOrder;
    _detailPollTimer?.cancel();
    _detailPollingActive = true;

    _detailPollTimer = Timer.periodic(
      const Duration(seconds: 15),
          (timer) => _refreshSelectedOrder(),
    );

    // Defer the notify to after this build/frame completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
  Future<void> _refreshSelectedOrder() async {
    if (selectedOrder == null) return;

    try {
      String restaurantId = "1248";
      int? savedId = await _prefs.getRestaurantId();
      if (savedId != null) {
        restaurantId = savedId.toString();
      }

      List<OrderHistory> allOrders = await _repo.getOrderHistory(restaurantId);

      for (final o in allOrders) {
        if (o.id == selectedOrder!.id) {
          selectedOrder = o;
          notifyListeners();
          break;
        }
      }
    } catch (e) {
      print("Order detail refresh error: $e");
      if (e.toString().contains('401')) {
        stopDetailPolling();
      }
    }
  }

  void stopDetailPolling() {
    _detailPollTimer?.cancel();
    _detailPollingActive = false;
    selectedOrder = null;
  }
  void stopHistoryPolling() {
    _historyPollTimer?.cancel();
    _historyPollingActive = false;
  }

  @override
  void dispose() {
    _historyPollTimer?.cancel();
    _detailPollTimer?.cancel();
    super.dispose();
  }
}