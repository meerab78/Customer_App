

import 'package:flutter/material.dart';
import 'package:http/http.dart' show read;
import 'package:provider/provider.dart' show ReadContext;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../../auth/signin/view.dart';
import '../../home/widget/delivery_pickup_card.dart';
import '../checkout_view.dart';
import '../controller.dart';

void showLoginRequiredSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isDismissible: true,
    enableDrag: true,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (_) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14), // Compact padding
        decoration: BoxDecoration(
          color: AppColors.card, // Theme aware surface background
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20), // Slightly reduced corner radius
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider, // Dynamic handle color for dark/light theme
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Login Required",
                style: getBoldStyle(
                  fontSize: MyFonts.size18, // Reduced font size for compact feel
                  color: AppColors.text, // Theme aware text color
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Login to track your order, or continue as a guest.",
                style: getRegularStyle(
                  fontSize: MyFonts.size12,
                  color: AppColors.greyText, // Dynamic grey text for better dark mode readability
                ),
              ),
              const SizedBox(height: 12),

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

              const SizedBox(height: 8),

              // GUEST OPTION
              DeliveryPickupCard(
                icon: Icons.person_outline_rounded,
                title: "Continue as Guest",
                subtitle: "Checkout without creating an account",
                onTap: () {
                  context.read<CartController>().startGuestCheckout();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CheckoutView(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      );
    },
  );
}