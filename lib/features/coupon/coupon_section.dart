import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller.dart';
import 'model/coupon_model.dart';
import '../../core/db/sqflite/model.dart'; // OrderDetails
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';

class CouponSection extends StatefulWidget {
  final String branchId;
  final String customerId;
  final double subtotal;
  final List<OrderDetails> cartItems;
  final int orderTypeId;
  final double deliveryFee;

  const CouponSection({
    super.key,
    required this.branchId,
    required this.customerId,
    required this.subtotal,
    required this.cartItems,
    required this.orderTypeId,
    this.deliveryFee = 0,
  });

  @override
  State<CouponSection> createState() => _CouponSectionState();
}

class _CouponSectionState extends State<CouponSection> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // List se select kiya hua coupon apply
  Future<void> _applyListCoupon(String code) async {
    final coupon = context.read<CouponController>();

    final success = await coupon.applyCoupon(
      branchId: widget.branchId,
      couponCode: code,
      subtotal: widget.subtotal,
    );

    if (!mounted) return;

    if (success) {
      _codeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Coupon applied!")),
      );
    }
  }

  // Manual typed code apply (promo pehle, coupon fallback)
  Future<void> _applyManualCode() async {
    final coupon = context.read<CouponController>();

    final success = await coupon.applyManualCode(
      branchId: widget.branchId,
      customerId: widget.customerId,
      code: _codeController.text,
      subtotal: widget.subtotal,
      cartItems: widget.cartItems,
      orderTypeId: widget.orderTypeId,
      deliveryFee: widget.deliveryFee,
    );

    if (!mounted) return;

    if (success) {
      _codeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Code applied!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CouponController>(
      builder: (context, coupon, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discount & Coupon',
              style: getBoldStyle(
                fontSize: MyFonts.size19,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),

            if (coupon.hasApplied)
              _appliedCard(coupon)
            else ...[
              _promoInput(coupon),
              const SizedBox(height: 14),
              if (coupon.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (coupon.coupons.isNotEmpty) ...[
                Text(
                  'Available Coupons',
                  style: getSemiBoldStyle(
                    fontSize: MyFonts.size14,
                    color: AppColors.greyText,
                  ),
                ),
                const SizedBox(height: 8),
                ...coupon.coupons.map((c) => _couponCard(c)),
              ],
            ],

            if (coupon.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                coupon.errorMessage!,
                style: getSemiBoldStyle(
                  fontSize: MyFonts.size12,
                  color: AppColors.error,
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _promoInput(CouponController coupon) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.grey200),
            ),
            child: TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: "Enter promo or coupon code",
                hintStyle: getRegularStyle(
                  fontSize: MyFonts.size13,
                  color: AppColors.greyText,
                ),
                prefixIcon: Icon(
                  Icons.local_offer_outlined,
                  size: 18,
                  color: AppColors.greyText,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: coupon.isValidating ? null : _applyManualCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: coupon.isValidating
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(
              'Apply',
              style: getBoldStyle(
                fontSize: MyFonts.size14,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _couponCard(Coupon c) {
    String discountText = c.isPercentage
        ? '${c.discountValue.toStringAsFixed(0)}% OFF'
        : 'Rs ${c.discountValue.toStringAsFixed(0)} OFF';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.confirmation_num_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.couponCode,
                  style: getBoldStyle(
                    fontSize: MyFonts.size14,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$discountText  •  ${c.discountName ?? ''}',
                  style: getRegularStyle(
                    fontSize: MyFonts.size11,
                    color: AppColors.greyText,
                  ),
                ),
                if (c.minOrderAmount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Min order: Rs ${c.minOrderAmount.toStringAsFixed(0)}',
                    style: getRegularStyle(
                      fontSize: MyFonts.size10,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: () => _applyListCoupon(c.couponCode),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: AppColors.primary),
              ),
            ),
            child: Text(
              'APPLY',
              style: getBoldStyle(
                fontSize: MyFonts.size12,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appliedCard(CouponController coupon) {
    final code = coupon.appliedDisplayCode ?? '';
    final isPercentage = coupon.appliedIsPercentage;
    final value = coupon.appliedDiscountValue;

    String discountText = isPercentage
        ? '${value.toStringAsFixed(0)}% OFF'
        : 'Rs ${value.toStringAsFixed(0)} OFF';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      code,
                      style: getBoldStyle(
                        fontSize: MyFonts.size15,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        discountText,
                        style: getBoldStyle(
                          fontSize: MyFonts.size10,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'You saved Rs ${coupon.discountAmount.toStringAsFixed(0)}',
                  style: getRegularStyle(
                    fontSize: MyFonts.size12,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => coupon.removeCoupon(),
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}