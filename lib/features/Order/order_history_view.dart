
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../cart/model/order_history_model.dart';
import 'order detail_view.dart';
import 'order_history_controller.dart';
import 'order_repository.dart';
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
  late OrderController _orderController;
  @override
  void initState() {
    super.initState();
    // build ke bahar, sirf ek dafa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderController>().startHistoryPolling();
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orderController = context.read<OrderController>();
  }
  @override
  void dispose() {
    _orderController.stopHistoryPolling();
    super.dispose();
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
    return ChangeNotifierProvider.value(
      value: context.read<OrderController>(),
      child: Consumer<OrderController>(
        builder: (context, ctrl, _) {
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
                  color: AppColors.primary,
                ),
              ),
            ),
            body: _buildBody(ctrl),
          );
        },
      ),
    );
  }

// BODY
  Widget _buildBody(OrderController ctrl) {
    if (ctrl.isLoadingHistory) {
      return _buildSkeleton();
    }
    if (ctrl.orders.isEmpty) {
      return _emptyState();
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: ctrl.loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        itemCount: ctrl.orders.length,
        itemBuilder: (context, index) {
          return _orderCard(context, ctrl.orders[index]);
        },
      ),
    );
  }
// SKELETON
  Widget _buildSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          30,
        ),
        itemCount: 5,
        itemBuilder: (context, index) {
          return _orderSkeletonCard();
        },
      ),
    );
  }

// ============================================================
// SKELETON ORDER CARD
// ============================================================

  Widget _orderSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

// Order number + status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Bone.text(
                      words: 2,
                      fontSize: 14,
                    ),

                    const SizedBox(height: 5),

                    Bone.text(
                      words: 3,
                      fontSize: 10,
                    ),
                  ],
                ),
              ),

              Bone(
                width: 65,
                height: 22,
                borderRadius:
                BorderRadius.circular(20),
              ),
            ],
          ),

          const SizedBox(height: 10),

// Divider
          Bone(
            width: double.infinity,
            height: 1,
          ),

          const SizedBox(height: 10),

// Item + price + arrow
          Row(
            children: [
              Bone.circle(size: 15),

              const SizedBox(width: 8),

              Expanded(
                child: Bone.text(
                  words: 2,
                  fontSize: 13,
                ),
              ),

              const SizedBox(width: 8),

              Bone.text(
                words: 1,
                fontSize: 14,
              ),

              const SizedBox(width: 7),

              Bone(
                width: 8,
                height: 13,
              ),
            ],
          ),
        ],
      ),
    );
  }

// ============================================================
// EMPTY STATE
// ============================================================

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

// ============================================================
// ORDER CARD
// ============================================================

  Widget _orderCard(BuildContext context,OrderHistory order) {
    Color statusColor =
    _statusColor(order.orderStatus);

    String mainItem = "";

    if (order.items.isNotEmpty) {
      mainItem = order.items[0].menuName;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailsView(
              order: order,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

// ROW 1
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
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

// Status badge
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                    statusColor.withOpacity(0.12),
                    borderRadius:
                    BorderRadius.circular(20),
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

            Container(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 8),

// ROW 2
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
                    overflow:
                    TextOverflow.ellipsis,
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