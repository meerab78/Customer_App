import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../../auth/signin/view.dart';
import '../../home/widget/delivery_pickup_card.dart';
import '../checkout_view.dart';

void showLoginRequiredSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isDismissible: true,
    enableDrag: true,
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
                "Login Required",
                style: getBoldStyle(
                  fontSize: MyFonts.size22,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Login to track your order, or continue as a guest.",
                style: getRegularStyle(
                  color: AppColors.grey600,
                ),
              ),
              const SizedBox(height: 18),

              // LOGIN OPTION
              DeliveryPickupCard(
                icon: Icons.login_rounded,
                title: "Login",
                subtitle: "Login to continue and save your order",
                onTap: () {
                  Navigator.pop(context); // sheet close
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignInView(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              // GUEST OPTION
              DeliveryPickupCard(
                icon: Icons.person_outline_rounded,
                title: "Continue as Guest",
                subtitle: "Checkout without creating an account",
                onTap: () {
                  Navigator.pop(context); // sheet close
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CheckoutView(),
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