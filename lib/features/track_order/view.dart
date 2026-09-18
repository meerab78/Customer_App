
import 'package:lottie/lottie.dart';

import '../../core/theme/app_paddings.dart';
import '../../generated/assets.dart';
import '/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/core/theme/textfont_styles.dart';

import '/features/track_order/controller.dart';
import 'package:url_launcher/url_launcher.dart';
import '/features/track_order/widgets/rider_card.dart';
import '/features/track_order/widgets/order_id_row.dart';
import '/features/track_order/widgets/delivery_timeline.dart';
import '/features/track_order/widgets/expandable_tracking_map.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  final String address;
  final String? orderStatus;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.address,
    this.orderStatus,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderTrackingController()..initialize(orderId),
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: Consumer<OrderTrackingController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return _buildLoading();
            }
            if (!controller.isOrderTrackingAvailable) {
              return _buildUnavailable();
            }
            if (controller.showArrivalDialog) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.dialogShown();
                _showArrivalDialog(context);
              });
            }
            return _buildTrackingContent(context, controller);
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        title: const SizedBox.shrink(),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildUnavailable() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        title: const SizedBox.shrink(),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_off_rounded,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Tracking Unavailable',
                  style: getBoldStyle(
                    fontSize: 18,
                    color: AppColors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We couldn\'t find tracking details for this order right now. Please try again later or check your order history.',
                  style: getMediumStyle(
                    fontSize: 13,
                    color: AppColors.textColor2.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingContent(
    BuildContext context,
    OrderTrackingController controller,
  ) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The map's rounded bottom edge sits directly on the page
            // background, and light map tiles are nearly the same tone as
            // it — without a shadow the two run together. The decoration
            // lives outside the map's own ClipRRect so the shadow is not
            // clipped, and it follows the map's animated height.
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 20,
                    spreadRadius: -2,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpandableTrackingMap(
                controller: controller,
                onBack: () => Navigator.pop(context),
              ),
            ),
            padding40,
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    padding24,
                    OrderIdRow(
                      orderId: orderId,
                      hasArrived: controller.hasArrived,
                      onTap: () =>
                          _showDetailedBottomSheet(context, controller),
                    ),
                    padding18,
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(height: 1, color: AppColors.borderColor1),
                          padding24,
                          DeliveryTimeline(hasArrived: controller.hasArrived),
                          padding56,
                          RiderCard(
                            riderName: controller.riderName,
                            riderPhoneNumber: controller.riderPhoneNumber,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailedBottomSheet(
      BuildContext context, OrderTrackingController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: BoxDecoration(
          color: AppColors.containerColor6,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.borderColor1,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery Details',
                        style: getBoldStyle(
                          fontSize: 20,
                          color: AppColors.textColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#$orderId',
                          style: getBoldStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.my_location,
                              color: AppColors.textColor2, size: 20),
                          Container(
                            height: 30,
                            width: 2,
                            color: AppColors.borderColor1,
                          ),
                          Icon(Icons.location_on,
                              color: AppColors.primary, size: 20),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Restaurant',
                                style: getRegularStyle(
                                    fontSize: 12, color: AppColors.textColor2)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                orderStatus ?? 'Processing',
                                style: getSemiBoldStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text('Delivery Address',
                                style: getRegularStyle(
                                    fontSize: 12, color: AppColors.textColor2)),
                            const SizedBox(height: 2),
                            Text(address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: getSemiBoldStyle(
                                    fontSize: 14, color: AppColors.textColor)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  Divider(color: AppColors.borderColor1),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.containerColor4,
                        child: Icon(Icons.person, color: AppColors.textColor2),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.riderName,
                              style: getBoldStyle(
                                  fontSize: 16, color: AppColors.textColor),
                            ),
                            Text(
                              'Your Rider',
                              style: getRegularStyle(
                                  fontSize: 12, color: AppColors.textColor2),
                            ),
                          ],
                        ),
                      ),
                      if (controller.riderPhoneNumber.isNotEmpty)
                        InkWell(
                          onTap: () => launchUrl(Uri(
                              scheme: 'tel',
                              path: controller.riderPhoneNumber)),
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.phone, color: AppColors.success),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showArrivalDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: AppColors.containerColor6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle,
                    color: AppColors.success, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                'Order Arrived!',
                style: getBoldStyle(fontSize: 22, color: AppColors.textColor),
              ),
              const SizedBox(height: 10),
              Text(
                'Your rider has reached the destination.',
                textAlign: TextAlign.center,
                style:
                    getRegularStyle(fontSize: 14, color: AppColors.textColor2),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Awesome!',
                    style: getBoldStyle(
                        fontSize: 15, color: AppColors.btnTextColorWhite),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
