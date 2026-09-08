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
          // padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
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
                Text(
                  coupon.errorMessage!,
                  style: getSemiBoldStyle(fontSize: MyFonts.size12, color: AppColors.error),
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

  // ---- MODE A: VOUCHER LIST ----
  Widget _voucherList(CouponController coupon) {
    if (coupon.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (coupon.coupons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No vouchers available',
            style: getRegularStyle(fontSize: MyFonts.size12, color: AppColors.greyText),
          ),
        ),
      );
    }

    return Column(
      children: coupon.coupons.map((c) {
        final isApplied = coupon.appliedCoupon?.couponCode == c.couponCode;
        return _voucherTicket(coupon, c, isApplied);
      }).toList(),
    );
  }

  // ---- Ticket-style voucher card ----
  Widget _voucherTicket(CouponController coupon, Coupon c, bool isApplied) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          ClipPath(
            child: Container(
              height: 84,
              decoration: BoxDecoration(
                color: isApplied ? AppColors.primary : AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Left: % off block
                  SizedBox(
                    width: 92,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          c.isPercentage
                              ? '${c.discountValue.toStringAsFixed(0)}%'
                              : 'Rs ${c.discountValue.toStringAsFixed(0)}',
                          style: getExtraBoldStyle(
                            fontSize: MyFonts.size19,
                            color: isApplied ? AppColors.white : AppColors.primary,
                          ),
                        ),
                        Text(
                          'OFF',
                          style: getBoldStyle(
                            fontSize: MyFonts.size11,
                            color: isApplied
                                ? AppColors.white.withOpacity(0.85)
                                : AppColors.primary.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Dashed divider
                  _dashedDivider(isApplied),
                  const SizedBox(width: 14),
                  // Right: details + apply
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          c.discountName ?? c.couponCode,
                          style: getBoldStyle(
                            fontSize: MyFonts.size13,
                            color: isApplied ? AppColors.white : AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 3),
                        if (c.minOrderAmount > 0)
                          Text(
                            'Min. spend Rs ${c.minOrderAmount.toStringAsFixed(0)}',
                            style: getRegularStyle(
                              fontSize: MyFonts.size11,
                              color: isApplied ? AppColors.white.withOpacity(0.85) : AppColors.greyText,
                            ),
                          ),
                        if (c.validTill != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Valid until: ${c.validTill}',
                            style: getRegularStyle(
                              fontSize: MyFonts.size10,
                              color: isApplied ? AppColors.white.withOpacity(0.7) : AppColors.greyText.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: GestureDetector(
                      onTap: isApplied
                          ? () => coupon.removeCoupon()
                          : () => _applyListCoupon(c.couponCode),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isApplied ? AppColors.white : AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isApplied ? 'APPLIED' : 'APPLY',
                          style: getBoldStyle(
                            fontSize: MyFonts.size10,
                            color: isApplied ? AppColors.primary : AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashedDivider(bool isApplied) {
    return SizedBox(
      height: 60,
      width: 1,
      child: Column(
        children: List.generate(8, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 1.5),
              color: isApplied
                  ? AppColors.white.withOpacity(0.4)
                  : AppColors.primary.withOpacity(0.3),
            ),
          );
        }),
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
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.card,
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
          height: 50,
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