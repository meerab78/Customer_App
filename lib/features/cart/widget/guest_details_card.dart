import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../../auth/address/manager_controller.dart';
import '../../auth/address/model/address_model.dart';
import '../../cart/controller.dart';

class GuestDetailsCard extends StatefulWidget {
  final String orderType; // 'Delivery' or 'Takeaway'
  final AddressManagerController addressManager;
  final IconData Function(int?) iconForType;
  final bool isGuest;
  final Future<void> Function() onEditAddress;
  final Future<void> Function()? onManageAddress;
  final VoidCallback? onShowAddressList;

  const GuestDetailsCard({
    super.key,
    required this.orderType,
    required this.addressManager,
    required this.iconForType,
    required this.isGuest,
    required this.onEditAddress,
    this.onManageAddress,
    this.onShowAddressList,
  });

  @override
  State<GuestDetailsCard> createState() => _GuestDetailsCardState();
}

class _GuestDetailsCardState extends State<GuestDetailsCard> {
  bool _expanded = true;

  void _confirmClear(BuildContext context, CartController cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          'Clear Guest Details?',
          style: getBoldStyle(
            fontSize: MyFonts.size16,
            color: AppColors.text,
          ),
        ),
        content: Text(
          'This will clear the name, email and phone number '
              'entered, so you can try again with different details.',
          style: getRegularStyle(
            fontSize: MyFonts.size13,
            color: AppColors.greyText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: getSemiBoldStyle(
                fontSize: MyFonts.size14,
                color: AppColors.greyText,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cart.resetGuestUser();
            },
            child: Text(
              'Clear',
              style: getSemiBoldStyle(
                fontSize: MyFonts.size14,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartController>(
      builder: (context, cart, _) {
        final isLocked = cart.isGuestLocked;

        // Guest ke liye: valid hone tak address edit disabled
        // Logged-in ke liye: hamesha editable (data already account se aata hai)
        final canEditAddress =
            !widget.isGuest || isLocked || cart.isGuestDetailsValid;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
    //---- Header (tap to expand/collapse) ----
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Row(
                  children: [
                    Expanded(
                      child: (!_expanded &&
                          cart.nameController.text.trim().isNotEmpty)
                          ? RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${cart.nameController.text}\n',
                              style: getSemiBoldStyle(
                                fontSize: MyFonts.size16,
                                color: AppColors.text,
                              ),
                            ),
                            TextSpan(
                              text: cart.phoneController.text,
                              style: getRegularStyle(
                                fontSize: MyFonts.size13,
                                color: AppColors.greyText,
                              ),
                            ),
                          ],
                        ),
                      )
                          : Text(
                        _expanded
                            ? 'Customer Details'
                            : (widget.isGuest
                            ? "Add Guest User's Detail"
                            : 'Customer Details'),
                        style: getSemiBoldStyle(
                          fontSize: MyFonts.size14,
                          color: AppColors.text,
                        ),
                      ),
                    ),

                    if (isLocked)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: InkWell(
                          onTap: () => _confirmClear(context, cart),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.close_rounded,
                                  color: AppColors.primary,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Clear',
                                  style: getSemiBoldStyle(
                                    fontSize: MyFonts.size11,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.text,
                    ),
                  ],
                ),
              ),

              // ---- Form fields + Address ----
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _expanded
                    ? Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Email'),
                      const SizedBox(height: 5),
                      _field(
                        controller: cart.emailController,
                        hint: 'Email',
                        enabled: !isLocked,
                        hasError: cart.emailError,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: cart.onGuestEmailChanged,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                _label('Name'),
                                const SizedBox(height: 5),
                                _field(
                                  controller: cart.nameController,
                                  hint: 'Name',
                                  enabled: !isLocked,
                                  hasError: cart.nameError,
                                  keyboardType: TextInputType.name,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z ]'),
                                    ),
                                  ],
                                  onChanged: cart.onGuestNameChanged,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                _label('Mobile No'),
                                const SizedBox(height: 5),
                                _field(
                                  controller: cart.phoneController,
                                  hint: 'Phone Number',
                                  enabled: !isLocked,
                                  hasError: cart.phoneError,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .digitsOnly,
                                    LengthLimitingTextInputFormatter(
                                        11),
                                  ],
                                  onChanged: cart.onGuestPhoneChanged,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // ---- Delivery Address (sirf Delivery order pe) ----
                      if (widget.orderType == 'Delivery') ...[
                        const SizedBox(height: 16),
                        Container(height: 1, color: AppColors.borderLight),
                        const SizedBox(height: 14),
                        _label('Delivery Address'),
                        const SizedBox(height: 8),
                        _addressBlock(canEditAddress),
                        if (!canEditAddress) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Fill in valid name, email & phone to edit address',
                            style: getRegularStyle(
                              fontSize: MyFonts.size10,
                              color: AppColors.greyText,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                )
                    : const SizedBox(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---- Address block (guest ya logged-in dono ke liye) ----
  Widget _addressBlock(bool canEdit) {
    final addressManager = widget.addressManager;
    final selected = addressManager.selectedAddress;

    if (addressManager.isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Fetching your address...',
              style: getRegularStyle(
                fontSize: MyFonts.size12,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      );
    }

    final onTapAction = widget.isGuest
        ? widget.onEditAddress
        : widget.onManageAddress;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: (canEdit && !addressManager.isSaving) ? onTapAction : null, // FIXED — saving ke dauran tap disabled
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.10),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: addressManager.isSaving // FIXED — spinner jab save ho raha ho
                        ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                        : Icon(
                      selected != null
                          ? widget.iconForType(selected.addressTypeId)
                          : Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      addressManager.isSaving
                          ? 'Saving address...' // FIXED
                          : (selected != null
                          ? selected.address1
                          : 'Tap to select delivery address'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: getRegularStyle(
                        fontSize: MyFonts.size12,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: canEdit
                          ? AppColors.containerColor4
                          : AppColors.containerColor4.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: canEdit ? AppColors.primary : AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (!widget.isGuest && addressManager.addresses.isNotEmpty) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: canEdit ? widget.onShowAddressList : null,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.text,
                size: 16,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: getRegularStyle(
        fontSize: MyFonts.size12,
        color: AppColors.greyText,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required bool enabled,
    required bool hasError,
    required TextInputType keyboardType,
    required ValueChanged<String> onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: getRegularStyle(
        fontSize: MyFonts.size14,
        color: AppColors.text,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: getRegularStyle(
          fontSize: MyFonts.size13,
          color: AppColors.greyText,
        ),
        filled: true,
        fillColor: enabled ? AppColors.background : AppColors.containerColor4,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: hasError ? AppColors.error : AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: hasError ? AppColors.error : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: hasError ? AppColors.error : AppColors.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}