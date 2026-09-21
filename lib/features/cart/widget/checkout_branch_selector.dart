import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../../base/controller.dart';
import '../../home/controller.dart';
import '../../home/model/branch_model.dart'; // path apne project ke hisaab se check karein
import '../controller.dart';

class CheckoutBranchSelector extends StatefulWidget {
  const CheckoutBranchSelector({super.key});

  @override
  State<CheckoutBranchSelector> createState() =>
      _CheckoutBranchSelectorState();
}

class _CheckoutBranchSelectorState extends State<CheckoutBranchSelector> {
  bool _isBusy = false;

  Future<void> _openBranchSheet() async {
    final home = context.read<HomeController>();

    if (home.branchModel == null) {
      await home.getBranches();
    }
    if (!mounted) return;

    final branches = home.branchModel?.data ?? <Branch>[];
    if (branches.isEmpty) return;

    final picked = await showModalBottomSheet<Branch>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BranchSheet(
        branches: List<Branch>.from(branches),
        selected: home.selectedBranch,
      ),
    );

    if (picked == null || !mounted) return;
    if (picked.id == home.selectedBranch?.id) return;

    await _switchBranch(picked);
  }

  Future<void> _switchBranch(Branch branch) async {
    final cart = context.read<CartController>();
    final home = context.read<HomeController>();
    final tabs = context.read<BaseTabController>();
    final navigator = Navigator.of(context);

    final confirmed = await _confirmSwitch();
    if (!confirmed || !mounted) return;

    setState(() => _isBusy = true);

    if (cart.cartItems.isNotEmpty) {
      await cart.clearCart();
    }
    await home.selectBranch(branch);

    tabs.changeTab(0);
    navigator.popUntil((route) => route.isFirst);
  }

  Future<bool> _confirmSwitch() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.storefront_outlined,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Switch Branch?',
                textAlign: TextAlign.center,
                style: getBoldStyle(
                  fontSize: MyFonts.size22,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Switching the branch will clear all items from your cart.',
                textAlign: TextAlign.center,
                style: getRegularStyle(
                  fontSize: MyFonts.size15,
                  color: AppColors.greyText,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: getMediumStyle(
                          fontSize: MyFonts.size15,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Switch',
                        style: getMediumStyle(
                          fontSize: MyFonts.size15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<HomeController>().selectedBranch;

    return InkWell(
      onTap: _isBusy ? null : _openBranchSheet,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isBusy
                  ? Padding(
                padding: const EdgeInsets.all(11),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
                  : Icon(
                Icons.storefront_rounded,
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
                    'Branch',
                    style: getRegularStyle(
                      fontSize: MyFonts.size12,
                      color: AppColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selected?.name ?? 'Select branch',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getSemiBoldStyle(
                      fontSize: MyFonts.size14,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.text,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- BOTTOM SHEET ----------------

class _BranchSheet extends StatelessWidget {
  final List<Branch> branches;
  final Branch? selected;

  const _BranchSheet({
    required this.branches,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final others = branches.where((b) => b.id != selected?.id).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Branch',
                          style: getBoldStyle(
                            fontSize: MyFonts.size18,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Switching will clear your cart',
                          style: getRegularStyle(
                            fontSize: MyFonts.size12,
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (selected != null) ...[
                      _sectionLabel('CURRENTLY SELECTED'),
                      const SizedBox(height: 8),
                      _tile(context, selected!, isSelected: true),
                      const SizedBox(height: 14),
                    ],
                    if (others.isNotEmpty) ...[
                      _sectionLabel('OTHER BRANCHES'),
                      const SizedBox(height: 8),
                      ...others.map(
                            (b) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _tile(context, b, isSelected: false),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: getBoldStyle(
        fontSize: MyFonts.size11,
        color: AppColors.greyText,
      ),
    );
  }

  Widget _tile(BuildContext context, Branch branch,
      {required bool isSelected}) {
    final address = branch.address ?? '';

    return InkWell(
      onTap: () => Navigator.pop(context, isSelected ? null : branch),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(.07)
              : AppColors.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(.12)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.storefront_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.name ?? 'Branch',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getBoldStyle(
                      fontSize: MyFonts.size14,
                      color: AppColors.text,
                    ),
                  ),
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: getRegularStyle(
                        fontSize: MyFonts.size12,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isSelected)
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.white,
                  size: 16,
                ),
              )
            else
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderLight),
                ),
              ),
          ],
        ),
      ),
    );
  }
}