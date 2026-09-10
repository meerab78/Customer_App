import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller.dart';
import 'model/coupon_model.dart';
import '../../core/db/sqflite/model.dart'; // OrderDetails
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';

enum _CouponMode { selectVoucher, typeCode }

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
  _CouponMode _mode = _CouponMode.selectVoucher;
  bool _codeError = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _applyListCoupon(String code) async {
    final coupon = context.read<CouponController>();

    final success = await coupon.applyCoupon(
      branchId: widget.branchId,
      couponCode: code,
      subtotal: widget.subtotal,
    );

    if (!mounted) return;
    if (success) _codeController.clear();
  }

  Future<void> _applyManualCode() async {
    if (_codeController.text.trim().isEmpty) {
      setState(() => _codeError = true);
      return;
    }
    setState(() => _codeError = false);

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
      setState(() => _mode = _CouponMode.selectVoucher);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CouponController>(
      builder: (context, coupon, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- HEADER: title + tab icons ----
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _mode == _CouponMode.selectVoucher
                          ? 'Select Voucher'
                          : 'Type Coupon code',
                      style: getBoldStyle(fontSize: MyFonts.size17, color: AppColors.text),
                    ),
                  ),
                  _tabIcons(),
                ],
              ),
              const SizedBox(height: 14),

              if (_mode == _CouponMode.selectVoucher)
                _voucherList(coupon)
              else
                _codeInput(coupon),

              if (coupon.errorMessage != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        coupon.errorMessage!,
                        style: getSemiBoldStyle(fontSize: MyFonts.size12, color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ---- TAB ICONS (top right) ----
  Widget _tabIcons() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tabIconButton(
            icon: Icons.confirmation_number_outlined,
            selected: _mode == _CouponMode.selectVoucher,
            onTap: () => setState(() => _mode = _CouponMode.selectVoucher),
          ),
          const SizedBox(width: 3),
          _tabIconButton(
            icon: Icons.local_offer_outlined,
            selected: _mode == _CouponMode.typeCode,
            onTap: () => setState(() => _mode = _CouponMode.typeCode),
          ),
        ],
      ),
    );
  }

  Widget _tabIconButton({
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 32,
        decoration: BoxDecoration(
          color: selected ? AppColors.card : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: selected ? Border.all(color: AppColors.borderLight) : null,
        ),
        child: Icon(
          icon,
          size: 17,
          color: selected ? AppColors.primary : AppColors.greyText,
        ),
      ),
    );
  }

  // ---- MODE A: VOUCHER LIST (HORIZONTAL) ----
  Widget _voucherList(CouponController coupon) {
    if (coupon.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (coupon.coupons.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.local_offer_outlined, size: 18, color: AppColors.greyText.withOpacity(0.6)),
            const SizedBox(width: 10),
            Text(
              'No vouchers available',
              style: getRegularStyle(fontSize: MyFonts.size13, color: AppColors.greyText),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 135,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: coupon.coupons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final c = coupon.coupons[index];
          final isApplied = coupon.appliedCoupon?.couponCode == c.couponCode;
          return _voucherCard(coupon, c, isApplied);
        },
      ),
    );
  }


  // ---- Horizontal voucher card (clean style) ----
  Widget _voucherCard(CouponController coupon, Coupon c, bool isApplied) {
    final discountText = c.isPercentage
        ? '${c.discountValue.toStringAsFixed(0)}%\nOFF'
        : 'Rs ${c.discountValue.toStringAsFixed(0)}\nOFF';

    // Valid date format
    String validDate = '';
    if (c.validTill != null) {
      try {
        final dt = DateTime.parse(c.validTill!);
        validDate = 'Valid until ${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      } catch (_) {
        validDate = 'Valid until ${c.validTill}';
      }
    }

    return GestureDetector(
      onTap: isApplied
          ? () => coupon.removeCoupon()
          : () => _applyListCoupon(c.couponCode),
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: isApplied
              ? AppColors.primary.withOpacity(0.85)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isApplied
              ? null
              : Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            // LEFT: discount value
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: isApplied
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.10),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(15),
                ),
              ),
              child: Center(
                child: Text(
                  discountText,
                  textAlign: TextAlign.center,
                  style: getExtraBoldStyle(
                    fontSize: MyFonts.size15,
                    color: isApplied ? AppColors.white : AppColors.primary,
                  ),
                ),
              ),
            ),

            // RIGHT: info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Name
                    Text(
                      c.discountName ?? c.couponCode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getBoldStyle(
                        fontSize: MyFonts.size14,
                        color: isApplied ? AppColors.white : AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Min spend
                    if (c.minOrderAmount > 0)
                      Text(
                        'Min. spend Rs. ${c.minOrderAmount.toStringAsFixed(0)}',
                        style: getRegularStyle(
                          fontSize: MyFonts.size11,
                          color: isApplied
                              ? AppColors.white.withOpacity(0.8)
                              : AppColors.greyText,
                        ),
                      ),

                    // Applied badge OR Apply text
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isApplied
                                ? AppColors.white.withOpacity(0.2)
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isApplied ? 'APPLIED' : 'APPLY',
                            style: getBoldStyle(
                              fontSize: MyFonts.size10,
                              color: isApplied
                                  ? AppColors.white
                                  : AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Valid until
                    if (validDate.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        validDate,
                        style: getRegularStyle(
                          fontSize: MyFonts.size9,
                          color: isApplied
                              ? AppColors.white.withOpacity(0.7)
                              : AppColors.greyText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- MODE B: TYPE CODE ----
  Widget _codeInput(CouponController coupon) {
    final hasApplied = coupon.hasApplied;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _codeError ? AppColors.error : AppColors.borderLight,
                width: _codeError ? 1.4 : 1,
              ),
            ),
            child: hasApplied
                ? InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => coupon.removeCoupon(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Icon(Icons.local_offer_outlined, size: 17, color: AppColors.greyText.withOpacity(0.6)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Remove selected voucher',
                        style: getRegularStyle(fontSize: MyFonts.size13, color: AppColors.greyText),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) {
                if (_codeError) setState(() => _codeError = false);
              },
              style: getRegularStyle(fontSize: MyFonts.size14, color: AppColors.text),
              decoration: InputDecoration(
                hintText: "Enter coupon code",
                hintStyle: getRegularStyle(fontSize: MyFonts.size13, color: AppColors.greyText),
                prefixIcon: Icon(Icons.local_offer_outlined, size: 18, color: AppColors.greyText),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 52,
          child: TextButton(
            onPressed: coupon.isValidating
                ? null
                : (hasApplied ? () => coupon.removeCoupon() : _applyManualCode),
            child: coupon.isValidating
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text(
              hasApplied ? 'Remove' : 'Apply',
              style: getBoldStyle(
                fontSize: MyFonts.size14,
                color: hasApplied ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}