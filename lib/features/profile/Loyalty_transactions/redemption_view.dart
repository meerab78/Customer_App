

import 'package:customer_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import 'controller.dart';
import 'model/convert_package_response.dart';

class RedemptionView extends StatefulWidget {
  const RedemptionView({super.key});

  @override
  State<RedemptionView> createState() => _RedemptionViewState();
}

class _RedemptionViewState extends State<RedemptionView> {
  ConvertPackage? _selectedPackage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoyaltyController>().loadPackages();
    });
  }

  void _selectPackage(ConvertPackage package, bool canRedeem) {
    if (!canRedeem) return;
    setState(() {
      _selectedPackage = package;
    });
  }

  Future<void> _redeem(LoyaltyController loyalty, ConvertPackage package) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                'Redeem points',
                style: getBoldStyle(fontSize: MyFonts.size18, color: AppColors.text),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: getRegularStyle(fontSize: MyFonts.size13, color: AppColors.greyText),
                  children: [
                    TextSpan(text: 'Convert ${package.points.toStringAsFixed(0)} pts into '),
                    TextSpan(
                      text: 'Rs ${package.amount.toStringAsFixed(0)}',
                      style: getSemiBoldStyle(fontSize: MyFonts.size13, color: AppColors.text),
                    ),
                    const TextSpan(text: ' wallet balance.'),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.borderLight),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Cancel', style: getSemiBoldStyle(fontSize: MyFonts.size13, color: AppColors.greyText)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Confirm', style: getSemiBoldStyle(fontSize: MyFonts.size13, color: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;

    final success = await loyalty.redeemPackage(package.packageId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? AppColors.text : AppColors.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          success ? "Points redeemed" : (loyalty.errorMessage ?? "Redemption failed"),
          style: getSemiBoldStyle(fontSize: MyFonts.size12, color: AppColors.white),
        ),
      ),
    );

    if (success && mounted) {
      setState(() => _selectedPackage = null);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.tertiary),
        title: Text(
          'Redeem points',
          style: getExtraBoldStyle(fontSize: MyFonts.size19, color: AppColors.tertiary),
        ),
      ),
      body: Consumer<LoyaltyController>(
        builder: (context, loyalty, _) {
          final canRedeemSelected =
              _selectedPackage != null && loyalty.canRedeem(_selectedPackage!);

          return Column(
            children: [
              _pointsBar(loyalty),
              _sectionHeader(),
              Expanded(
                child: loyalty.isLoadingPackages
                    ? const Center(child: CircularProgressIndicator())
                    : loyalty.packages.isEmpty
                    ? _emptyState()
                    : RefreshIndicator(
                  onRefresh: loyalty.loadPackages,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
                    itemCount: loyalty.packages.length,
                    itemBuilder: (context, index) {
                      final package = loyalty.packages[index];
                      final canRedeem = loyalty.canRedeem(package);
                      final isSelected = _selectedPackage?.packageId == package.packageId;
                      return _packageRow(package, canRedeem, isSelected);
                    },
                  ),
                ),
              ),
              _claimButton(loyalty, canRedeemSelected),
            ],
          );
        },
      ),
    );
  }

  // ---- Points strip — card with sparkle icon (matches screenshot layout) ----
  Widget _pointsBar(LoyaltyController loyalty) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(18, 6, 18, 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.softShadow05,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: AppColors.tertiary, size: 26),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                loyalty.loyaltyPoints.toStringAsFixed(2),
                style: getExtraBoldStyle(fontSize: MyFonts.size22, color: AppColors.text),
              ),
              const SizedBox(width: 6),
              Text(
                'pts',
                style: getSemiBoldStyle(fontSize: MyFonts.size14, color: AppColors.greyText),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Your available balance',
            style: getRegularStyle(fontSize: MyFonts.size12, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }

  // ---- Section header — "Choose a package" ----
  Widget _sectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.containerColor5,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.card_giftcard_rounded, color: AppColors.text, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Choose a package',
              style: getBoldStyle(fontSize: MyFonts.size16, color: AppColors.text),
            ),
          ),
          Container(
            width: 28,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Package row — card, accent bar, radio selector ----
  Widget _packageRow(ConvertPackage package, bool canRedeem, bool isSelected) {
    return InkWell(
      onTap: () => _selectPackage(package, canRedeem),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.tertiary : AppColors.borderLight,
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.softShadow05,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 32,
              decoration: BoxDecoration(
                color: canRedeem ? AppColors.tertiary : AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${package.points.toStringAsFixed(2)} ',
                          style: getBoldStyle(fontSize: MyFonts.size18, color: AppColors.text),
                        ),
                        TextSpan(
                          text: 'points',
                          style: getRegularStyle(fontSize: MyFonts.size13, color: AppColors.greyText),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'will be equal to Rs. ${package.amount.toStringAsFixed(2)}',
                    style: getSemiBoldStyle(fontSize: MyFonts.size12, color: AppColors.greyText),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.tertiary : AppColors.borderLight,
                  width: 2,
                ),
                color: AppColors.transparent,
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.tertiary,
                  ),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ---- Bottom sticky Claim reward button ----
  Widget _claimButton(LoyaltyController loyalty, bool enabled) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (enabled && !loyalty.isRedeeming)
                ? () => _redeem(loyalty, _selectedPackage!)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: enabled ? AppColors.tertiary : AppColors.borderLight,
              disabledBackgroundColor: AppColors.borderLight,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: loyalty.isRedeeming
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
            )
                : Text(
              'Claim reward',
              style: getBoldStyle(
                fontSize: MyFonts.size15,
                color: enabled ? AppColors.white : AppColors.grey500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.tertiary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.card_giftcard_outlined, size: 34, color: AppColors.tertiary.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            Text(
              'No packages available',
              style: getSemiBoldStyle(fontSize: MyFonts.size14, color: AppColors.text),
            ),
            const SizedBox(height: 4),
            Text(
              'Check back later for redemption options',
              textAlign: TextAlign.center,
              style: getRegularStyle(fontSize: MyFonts.size12, color: AppColors.greyText),
            ),
          ],
        ),
      ),
    );
  }
}