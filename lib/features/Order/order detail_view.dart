import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../cart/model/order_history_model.dart';
import '../track_order/view.dart';
import 'order_history_controller.dart' show OrderController;
import 'order_repository.dart';
import '../../core/db/shared_pref.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';

class OrderDetailsView extends StatelessWidget {
  final OrderHistory order;

  const OrderDetailsView({super.key, required this.order});

  final List<String> steps = const [
    "Received",
    "Preparing",
    "Ready",
    "Out for Delivery",
    "Delivered",
  ];

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
    return ChangeNotifierProvider.value(
      value: context.read<OrderController>()..startDetailPolling(order),
      child: Consumer<OrderController>(
        builder: (context, ctrl, _) {
          final currentOrder = ctrl.selectedOrder ?? order;
          bool isDelivered = currentOrder.orderStatus.toLowerCase() == "delivered";

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
                  _statusCard(context ,currentOrder, isDelivered),
                  const SizedBox(height: 14),
                  _orderInfoCard(currentOrder),
                  const SizedBox(height: 14),
                  _itemsCard(currentOrder),
                  const SizedBox(height: 14),
                  _paymentCard(currentOrder),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- 1. STATUS CARD ----------------
  Widget _statusCard(BuildContext context,OrderHistory order, bool isDelivered) {
    Color color = _statusColor(order.orderStatus);
    IconData icon = _statusIcon(order.orderStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
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
                      order.orderStatus,
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
            Container(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 22),
            _progressTracker(order),

            if (order.orderStatus.toLowerCase() == "out for delivery" ||
                order.orderStatus.toLowerCase() == "dispatched") ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    print("DEBUG order.orderId = ${order.orderId}");
                    print("DEBUG order.id = ${order.id}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(
                          orderId: order.orderId ?? '',
                          address: order.deliveryAddress ?? '',
                          orderStatus: order.orderStatus,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delivery_dining_rounded),
                  label: const Text('Track Your Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _progressTracker(OrderHistory order) {
    int current = _currentStep(order.orderStatus);

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
                      color: isDone ? AppColors.primary : AppColors.borderLight,
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
                          color: index < current ? AppColors.primary : AppColors.borderLight,
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
  Widget _orderInfoCard(OrderHistory order) {
    bool isDelivery =
    order.orderTypeName.toLowerCase().contains("deliv");

    return _cardWrapper(
      icon: Icons.receipt_long_rounded,
      title: 'Order Information',
      child: Column(
        children: [
          _infoRow(Icons.tag_rounded, 'Order ID',
              order.orderId ?? '${order.id ?? ''}'),
          _infoRow(
              isDelivery
                  ? Icons.delivery_dining_rounded
                  : Icons.shopping_bag_rounded,
              'Type',
              order.orderTypeName),
          _infoRow(Icons.access_time_rounded, 'Date & Time',
              order.formattedDateTime),
          if (isDelivery && order.deliveryAddress != null)
            _infoRow(Icons.location_on_rounded, 'Address',
                order.deliveryAddress!),
          _infoRow(Icons.payments_rounded, 'Payment', order.paymentType,
              isLast: true),
        ],
      ),
    );
  }

  // ---------------- 3. ITEMS CARD ----------------
  Widget _itemsCard(OrderHistory order) {
    return _cardWrapper(
      icon: Icons.fastfood_rounded,
      title: 'Your Items',
      child: Column(
        children: List.generate(order.items.length, (i) {
          OrderHistoryItem item = order.items[i];
          int qty = double.tryParse(item.quantity)?.toInt() ?? 1;
          bool isLast = i == order.items.length - 1;

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
  Widget _paymentCard(OrderHistory order) {
    bool isDelivery =
    order.orderTypeName.toLowerCase().contains("deliv");

    double discount = double.tryParse(order.discountAmount) ?? 0;

    return _cardWrapper(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Payment Summary',
      child: Column(
        children: [
          _payRow('Subtotal', 'PKR ${order.subTotal}'),
          _payRow('Tax (${order.taxPercent}%)', 'PKR ${order.taxAmount}'),

          // NEW — Discount row (sirf jab discount > 0 ho)
          if (discount > 0)
            _payRow(
              'Discount',
              '- PKR ${discount.toStringAsFixed(0)}',
              valueColor: AppColors.primary,
            ),

          if (isDelivery)
            _payRow('Delivery Fee', 'PKR ${order.deliveryCharge}'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(height: 1, color: AppColors.borderLight),
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
                'PKR ${order.total}',   // already discount-minus final hai
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
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
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

  Widget _payRow(String label, String value, {Color? valueColor}) {
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
              color: valueColor ?? AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}