import 'dart:async';

import 'package:flutter/material.dart';

import 'order_detail_view.dart';
import 'order_repository.dart';
import 'model/order_history_model.dart';
import '../../core/db/shared_pref.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({super.key});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  final OrderRepository _repo = OrderRepository();
  final SharedPrefService _prefs = SharedPrefService();

  bool _isLoading = true;
  List<OrderHistory> _orders = [];
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadOrders();

    // Har 15 second me status refresh karo
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _loadOrders(silent: true);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // Orders load karna
  Future<void> _loadOrders({bool silent = false}) async {
    if (silent == false) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      String restaurantId = "1248";

      int? savedId = await _prefs.getRestaurantId();
      if (savedId != null) {
        restaurantId = savedId.toString();
      }

      List<OrderHistory> orders =
      await _repo.getOrderHistory(restaurantId);

      // Latest order upar dikhane ke liye sort
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Order history error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Status ke hisaab se color
  Color _statusColor(String status) {
    String s = status.toLowerCase();

    if (s == "delivered") {
      return const Color(0xFF16A34A);
    } else if (s == "preparing") {
      return const Color(0xFFEA580C);
    } else if (s == "pending") {
      return const Color(0xFFCA8A04);
    } else if (s == "cancelled" || s == "rejected") {
      return const Color(0xFFDC2626);
    } else {
      return AppColors.primary;
    }
  }

  // Status ke hisaab se icon
  IconData _statusIcon(String status) {
    String s = status.toLowerCase();

    if (s == "delivered") {
      return Icons.check_circle_rounded;
    } else if (s == "preparing") {
      return Icons.local_fire_department_rounded;
    } else if (s == "pending") {
      return Icons.schedule_rounded;
    } else if (s == "cancelled" || s == "rejected") {
      return Icons.cancel_rounded;
    } else {
      return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'ORDERS',
          style: getExtraBoldStyle(
            fontSize: MyFonts.size22,
            color: AppColors.primary,  // yellow
          ),
        ),
      ),

      body: _buildBody(),
    );
  }

  // Body banana
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_orders.isEmpty) {
      return _emptyState();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          return _orderCard(_orders[index]);
        },
      ),
    );
  }

  // Empty state
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 46,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'No orders yet',
            style: getBoldStyle(
              fontSize: MyFonts.size18,
              color: AppColors.text,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Your orders will show up here once you place one.',
            textAlign: TextAlign.center,
            style: getRegularStyle(
              fontSize: MyFonts.size13,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }
  // Ek order ka card (compact + border)
  Widget _orderCard(OrderHistory order) {
    Color statusColor = _statusColor(order.orderStatus);

    String mainItem = "";
    if (order.items.isNotEmpty) {
      mainItem = order.items[0].menuName;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailsView(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ROW 1: Order number + status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORDER #${order.orderNo ?? order.id ?? ''}',
                        style: getBoldStyle(
                          fontSize: MyFonts.size14,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.formattedDateTime,
                        style: getRegularStyle(
                          fontSize: MyFonts.size10,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge (pill)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.orderStatus,
                    style: getSemiBoldStyle(
                      fontSize: MyFonts.size10,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Container(height: 1, color: AppColors.grey200),

            const SizedBox(height: 8),

            // ROW 2: item + total + arrow (ek hi row me, compact)
            Row(
              children: [
                Icon(
                  Icons.restaurant_rounded,
                  size: 15,
                  color: AppColors.greyText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    mainItem,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getSemiBoldStyle(
                      fontSize: MyFonts.size13,
                      color: AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'PKR${order.total}',
                  style: getExtraBoldStyle(
                    fontSize: MyFonts.size14,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: AppColors.greyText,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}