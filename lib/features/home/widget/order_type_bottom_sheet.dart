
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../branch_view.dart';
import 'delivery_pickup_card.dart';
void showOrderTypeBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (_) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Choose Order Type",
                style: getBoldStyle(
                  fontSize: MyFonts.size22,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Select how you'd like to receive your order.",
                style: getRegularStyle(
                  color: AppColors.grey600,
                ),
              ),
              const SizedBox(height: 18),
              DeliveryPickupCard(
                icon: Icons.delivery_dining,
                title: "Delivery",
                subtitle: "Deliver food to your address",
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              DeliveryPickupCard(
                icon: Icons.storefront,
                title: "Pickup",
                subtitle: "Collect from restaurant branch",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BranchView(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}



