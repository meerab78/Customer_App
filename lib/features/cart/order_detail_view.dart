import 'dart:async';

import 'package:flutter/material.dart';

import 'order_repository.dart';
import 'model/order_history_model.dart';
import '../../core/db/shared_pref.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';

class OrderDetailsView extends StatefulWidget {
  final OrderHistory order;

  const OrderDetailsView({super.key, required this.order});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  final OrderRepository _repo = OrderRepository();
  final SharedPrefService _prefs = SharedPrefService();

  late OrderHistory _order;
  Timer? _pollTimer;

  final List<String> steps = const [
    "Received",
    "Preparing",
    "Ready",
    "Out for Delivery",
    "Delivered",
  ];

  @override
  void initState() {
    super.initState();
    _order = widget.order;

    _pollTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _refreshOrder();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshOrder() async {
    try {
      String restaurantId = "1248";
      int? savedId = await _prefs.getRestaurantId();
      if (savedId != null) {
        restaurantId = savedId.toString();
      }

      List<OrderHistory> orders =
      await _repo.getOrderHistory(restaurantId);

      for (int i = 0; i < orders.length; i++) {
        if (orders[i].id == _order.id) {
          if (mounted) {
            setState(() {
              _order = orders[i];
            });
          }
          break;
        }
      }
    } catch (e) {
      print("Order detail refresh error: $e");
    }
  }

  int _currentStep(String status) {
    String s = status.toLowerCase();

    if (s == "pending" || s == "received") {
      return 0;
    } else if (s == "preparing") {
      return 1;
    } else if (s == "ready") {
      return 2;
    } else if (s == "out for delivery" || s == "dispatched") {
      return 3;
    } else if (s == "delivered") {
      return 4;
    } else {
      return 0;
    }
  }

  Color _statusColor(String status) {
    String s = status.toLowerCase();

    if (s == "delivered") {
      return const Color(0xFF16A34A);
    } else if (s == "preparing") {
      return const Color(0xFFEA580C);
    } else if (s == "ready") {
      return const Color(0xFF2563EB);
    } else if (s == "pending") {
      return const Color(0xFFCA8A04);
    } else if (s == "cancelled" || s == "rejected") {
      return const Color(0xFFDC2626);
    } else {
      return AppColors.primary;
    }
  }

  IconData _statusIcon(String status) {
    String s = status.toLowerCase();

    if (s == "delivered") {
      return Icons.check_circle_rounded;
    } else if (s == "preparing") {
      return Icons.local_fire_department_rounded;
    } else if (s == "ready") {
      return Icons.room_service_rounded;
    } else if (s == "pending") {
      return Icons.schedule_rounded;
    } else if (s == "cancelled" || s == "rejected") {
      return Icons.cancel_rounded;
    } else {
      return Icons.delivery_dining_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDelivered = _order.orderStatus.toLowerCase() == "delivered";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          'Details',
          style: getExtraBoldStyle(
            fontSize: MyFonts.size24,
            color: AppColors.text,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusCard(isDelivered),
            const SizedBox(height: 14),
            _orderInfoCard(),
            const SizedBox(height: 14),
            _itemsCard(),
            const SizedBox(height: 14),
            _paymentCard(),
          ],
        ),
      ),
    );
  }

  // ---------------- 1. STATUS CARD ----------------
  Widget _statusCard(bool isDelivered) {
    Color color = _statusColor(_order.orderStatus);
    IconData icon = _statusIcon(_order.orderStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // status header row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Status',
                      style: getRegularStyle(
                        fontSize: MyFonts.size12,
                        color: AppColors.greyText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _order.orderStatus,
                      style: getExtraBoldStyle(
                        fontSize: MyFonts.size17,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (isDelivered == false) ...[
            const SizedBox(height: 22),
            Container(height: 1, color: AppColors.grey200),
            const SizedBox(height: 22),
            _progressTracker(),
          ],
        ],
      ),
    );
  }

  Widget _progressTracker() {
    int current = _currentStep(_order.orderStatus);

    return Column(
      children: [
        Row(
          children: List.generate(steps.length, (index) {
            bool isDone = index <= current;
            bool isCurrent = index == current;
            bool isLast = index == steps.length - 1;

            return Expanded(
              child: Row(
                children: [
                  // circle
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.primary : AppColors.grey200,
                      shape: BoxShape.circle,
                      border: isCurrent
                          ? Border.all(
                        color: AppColors.primary.withOpacity(0.25),
                        width: 3,
                      )
                          : null,
                    ),
                    child: isDone
                        ? const Icon(Icons.check,
                        size: 15, color: Colors.white)
                        : null,
                  ),
                  // connecting line
                  if (isLast == false)
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: index < current
                              ? AppColors.primary
                              : AppColors.grey200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),

        const SizedBox(height: 10),

        Row(
          children: List.generate(steps.length, (index) {
            bool isDone = index <= current;

            return Expanded(
              child: Text(
                steps[index],
                textAlign: TextAlign.center,
                style: isDone
                    ? getSemiBoldStyle(
                  fontSize: MyFonts.size9,
                  color: AppColors.text,
                )
                    : getRegularStyle(
                  fontSize: MyFonts.size9,
                  color: AppColors.greyText,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ---------------- 2. ORDER INFO CARD ----------------
  Widget _orderInfoCard() {
    bool isDelivery =
    _order.orderTypeName.toLowerCase().contains("deliv");

    return _cardWrapper(
      icon: Icons.receipt_long_rounded,
      title: 'Order Information',
      child: Column(
        children: [
          _infoRow(Icons.tag_rounded, 'Order ID',
              _order.orderId ?? '${_order.id ?? ''}'),
          _infoRow(
              isDelivery
                  ? Icons.delivery_dining_rounded
                  : Icons.shopping_bag_rounded,
              'Type',
              _order.orderTypeName),
          _infoRow(Icons.access_time_rounded, 'Date & Time',
              _order.formattedDateTime),
          if (isDelivery && _order.deliveryAddress != null)
            _infoRow(Icons.location_on_rounded, 'Address',
                _order.deliveryAddress!),
          _infoRow(Icons.payments_rounded, 'Payment', _order.paymentType,
              isLast: true),
        ],
      ),
    );
  }

  // ---------------- 3. ITEMS CARD ----------------
  Widget _itemsCard() {
    return _cardWrapper(
      icon: Icons.fastfood_rounded,
      title: 'Your Items',
      child: Column(
        children: List.generate(_order.items.length, (i) {
          OrderHistoryItem item = _order.items[i];
          int qty = double.tryParse(item.quantity)?.toInt() ?? 1;
          bool isLast = i == _order.items.length - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${qty}x',
                    style: getBoldStyle(
                      fontSize: MyFonts.size11,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.menuName,
                        style: getSemiBoldStyle(
                          fontSize: MyFonts.size13,
                          color: AppColors.text,
                        ),
                      ),
                      if (item.customizationText.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          item.customizationText,
                          style: getRegularStyle(
                            fontSize: MyFonts.size11,
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'PKR ${item.price}',
                  style: getBoldStyle(
                    fontSize: MyFonts.size13,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ---------------- 4. PAYMENT SUMMARY ----------------
  Widget _paymentCard() {
    bool isDelivery =
    _order.orderTypeName.toLowerCase().contains("deliv");

    return _cardWrapper(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Payment Summary',
      child: Column(
        children: [
          _payRow('Subtotal', 'PKR ${_order.subTotal}'),
          _payRow('Tax (${_order.taxPercent}%)', 'PKR ${_order.taxAmount}'),
          if (isDelivery)
            _payRow('Delivery Fee', 'PKR ${_order.deliveryCharge}'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(height: 1, color: AppColors.grey200),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: getBoldStyle(
                  fontSize: MyFonts.size15,
                  color: AppColors.text,
                ),
              ),
              Text(
                'PKR ${_order.total}',
                style: getExtraBoldStyle(
                  fontSize: MyFonts.size19,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _cardWrapper({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: getBoldStyle(
                  fontSize: MyFonts.size15,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.greyText),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: getRegularStyle(
                fontSize: MyFonts.size12,
                color: AppColors.greyText,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: getSemiBoldStyle(
                fontSize: MyFonts.size13,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _payRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: getRegularStyle(
              fontSize: MyFonts.size13,
              color: AppColors.greyText,
            ),
          ),
          Text(
            value,
            style: getSemiBoldStyle(
              fontSize: MyFonts.size13,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}