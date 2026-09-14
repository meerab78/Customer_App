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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 3),
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
                      style: getBoldStyle(fontSize: MyFonts.size15, color: AppColors.text),
                    ),
                  ),
                  _tabIcons(),
                ],
              ),
              const SizedBox(height: 10),

              if (_mode == _CouponMode.selectVoucher)
                _voucherList(coupon)
              else
                _codeInput(coupon),

              if (coupon.errorMessage != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 13, color: AppColors.error),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        coupon.errorMessage!,
                        style: getSemiBoldStyle(fontSize: MyFonts.size11, color: AppColors.error),
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
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _tabIconButton(
            icon: Icons.confirmation_number_outlined,
            selected: _mode == _CouponMode.selectVoucher,
            onTap: () => setState(() => _mode = _CouponMode.selectVoucher),
          ),
          const SizedBox(width: 2),
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
        width: 32,
        height: 28,
        decoration: BoxDecoration(
          color: selected ? AppColors.card : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: selected ? Border.all(color: AppColors.borderLight) : null,
        ),
        child: Icon(
          icon,
          size: 15,
          color: selected ? AppColors.primary : AppColors.greyText,
        ),
      ),
    );
  }

  // ---- MODE A: VOUCHER LIST (HORIZONTAL) ----
  Widget _voucherList(CouponController coupon) {
    if (coupon.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (coupon.coupons.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.local_offer_outlined, size: 16, color: AppColors.greyText.withOpacity(0.6)),
            const SizedBox(width: 8),
            Text(
              'No vouchers available',
              style: getRegularStyle(fontSize: MyFonts.size12, color: AppColors.greyText),
            ),
          ],
        ),
      );
    }

    // Height compact kar di 80px par
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: coupon.coupons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final c = coupon.coupons[index];
          final isApplied = coupon.appliedCoupon?.couponCode == c.couponCode;
          return _voucherCard(coupon, c, isApplied);
        },
      ),
    );
  }

  // ---- Compact Ticket-Style Voucher Card ----
  Widget _voucherCard(CouponController coupon, Coupon c, bool isApplied) {
    final discountText = c.isPercentage
        ? '${c.discountValue.toStringAsFixed(0)}%'
        : 'Rs ${c.discountValue.toStringAsFixed(0)}';

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
      child: ClipPath(
        clipper: TicketClipper(),
        child: Container(
          width: 230, // Reduced width
          color: isApplied ? AppColors.primary : AppColors.primary, // Clean solid/themed background
          child: Stack(
            children: [
              Row(
                children: [
                  // LEFT SIDE: Discount Rate
                  SizedBox(
                    width: 75,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          discountText,
                          style: getExtraBoldStyle(
                            fontSize: MyFonts.size15,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          'OFF',
                          style: getBoldStyle(
                            fontSize: MyFonts.size11,
                            color: AppColors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // DASHED VERTICAL DIVIDER
                  CustomPaint(
                    size: const Size(1, double.infinity),
                    painter: DashedLinePainter(
                      color: AppColors.white.withOpacity(0.4),
                    ),
                  ),

                  // RIGHT SIDE: Voucher Info + Button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  c.discountName ?? c.couponCode,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: getBoldStyle(
                                    fontSize: MyFonts.size12,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Small Compact Apply Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isApplied ? AppColors.white : AppColors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isApplied ? 'APPLIED' : 'APPLY',
                                  style: getBoldStyle(
                                    fontSize: MyFonts.size9,
                                    color: isApplied ? AppColors.primary : AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (c.minOrderAmount > 0) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Min. spend Rs. ${c.minOrderAmount.toStringAsFixed(0)}',
                              style: getRegularStyle(
                                fontSize: MyFonts.size9,
                                color: AppColors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                          if (validDate.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              validDate,
                              style: getRegularStyle(
                                fontSize: MyFonts.size8,
                                color: AppColors.white.withOpacity(0.75),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _codeError ? AppColors.error : AppColors.borderLight,
                width: _codeError ? 1.4 : 1,
              ),
            ),
            child: hasApplied
                ? InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => coupon.removeCoupon(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.local_offer_outlined, size: 16, color: AppColors.greyText.withOpacity(0.6)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Remove selected voucher',
                        style: getRegularStyle(fontSize: MyFonts.size12, color: AppColors.greyText),
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
              style: getRegularStyle(fontSize: MyFonts.size13, color: AppColors.text),
              decoration: InputDecoration(
                hintText: "Enter coupon code",
                hintStyle: getRegularStyle(fontSize: MyFonts.size12, color: AppColors.greyText),
                prefixIcon: Icon(Icons.local_offer_outlined, size: 16, color: AppColors.greyText),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 44,
          child: TextButton(
            onPressed: coupon.isValidating
                ? null
                : (hasApplied ? () => coupon.removeCoupon() : _applyManualCode),
            child: coupon.isValidating
                ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text(
              hasApplied ? 'Remove' : 'Apply',
              style: getBoldStyle(
                fontSize: MyFonts.size13,
                color: hasApplied ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Compact Ticket Shape Clipper
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 10;
    double cutoutRadius = 6; // Smaller notch size
    Path path = Path();

    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Right Cutout Notch
    path.lineTo(size.width, size.height / 2 - cutoutRadius);
    path.arcToPoint(
      Offset(size.width, size.height / 2 + cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height - radius);

    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    // Left Cutout Notch
    path.lineTo(0, size.height / 2 + cutoutRadius);
    path.arcToPoint(
      Offset(0, size.height / 2 - cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );
    path.lineTo(0, radius);

    path.quadraticBezierTo(0, 0, radius, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Dashed Line Painter
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 3, dashSpace = 3, startY = 6;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    while (startY < size.height - 6) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}