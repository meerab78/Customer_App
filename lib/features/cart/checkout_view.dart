import 'package:customer_app/core/utils/page_transitions.dart';
import 'package:customer_app/features/cart/widget/guest_details_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constant/app_constants.dart';
import '../auth/address/view.dart' show AddressView;
import '../coupon/controller.dart';
import '../coupon/coupon_section.dart';
import '../profile/Wallet/controller.dart' show WalletController;
import 'controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';

import '../home/controller.dart';
import '../auth/address/manager_controller.dart';
import '../auth/address/manage_address_view.dart';
import '../auth/address/model/address_model.dart';
import '../../core/db/shared_pref.dart';
import 'order_history_view.dart';
import 'order_playload_builder.dart';
import 'order_repository.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  // NEW: order placement state
  final OrderRepository _orderRepository = OrderRepository();
  final SharedPrefService _prefs = SharedPrefService();
  bool _isPlacingOrder = false;
  String _customerId = '';
  bool _useWallet = false;
  bool _isActuallyGuest = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAddresses();

    });
    _prefs.getIsGuest().then((value) {
      if (mounted) setState(() => _isActuallyGuest = value);
    });
  }

  // NEW — Guest ke liye address editor, turant update
  Future<void> _openGuestAddressEditor() async {
    final addressManager = context.read<AddressManagerController>();

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddressView(pickerMode: true),
      ),
    );

    if (result == null || !mounted) return;

    // Turant local (unsaved) selected address update karo — koi API call nahi
    addressManager.selectAddress(
      CustomerAddress(
        addressTypeId: 3,
        addressType: 'Home',
        address1: result["address1"] ?? "",
        latitude: result["latitude"] ?? "",
        longitude: result["longitude"] ?? "",
        isDefault: 1,
      ),
    );

    _recalcFee();
  }
  Future<void> _initAddresses() async {
    final addressManager = context.read<AddressManagerController>();
    final cart = context.read<CartController>();

    // GUEST + abhi signup nahi hua -> backend address API skip karo
    // (token nahi hai), sirf local SharedPreferences se address dikhao
    if (cart.isGuestCheckout && !cart.isGuestLocked) {
      await addressManager.useLocalAddressForGuest();
    } else {
      await addressManager.loadAddresses();
      await addressManager.ensureHomeAddress();
      if (!cart.isGuestCheckout) {
        await cart.prefillLoggedInDetails();
      }
    }



    if (cart.orderType == 'Delivery') {
      _recalcFee();
    }

    final home = context.read<HomeController>();
    final branchId = home.selectedBranch?.id?.toString() ?? '';

    // GUEST + abhi signup nahi hua -> customerId khali rahega
    // (guest signup ke baad token/customer id milega)
    if (!cart.isGuestCheckout || cart.isGuestLocked) {
      final userId = await _prefs.getUserId();
      _customerId = userId?.toString() ?? '';
    }
    if (!cart.isGuestCheckout) {
      if (branchId.isNotEmpty) {
        context.read<CouponController>().loadCoupons(branchId);
      } else {
        debugPrint("Skipping loadCoupons — branchId empty");
      }

      if (AppConstants.enableLoyaltySystem) {
        context.read<WalletController>().loadWalletData();
      }
    }
  }
  void _recalcFee() {
    final addressManager = context.read<AddressManagerController>();
    final cart = context.read<CartController>();
    final home = context.read<HomeController>();

    final branchId = home.selectedBranch?.id?.toString() ?? '';

    final subtotal = _calculateSubtotal(cart);

    if (branchId.isEmpty) {
      return;
    }

    addressManager.recalculateDeliveryFee(
      branchId: branchId,
      orderAmount: subtotal,
    );
  }
  void _showAddressDropdown() {
    final addressManager = context.read<AddressManagerController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top handle
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

                  // Header
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
                          Icons.location_on_rounded,
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
                              'Select Address',
                              style: getBoldStyle(
                                fontSize: MyFonts.size18,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Choose your delivery address',
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

                  // Address list
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: addressManager.addresses.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final address =
                        addressManager.addresses[index];

                        final isSelected =
                            addressManager.selectedAddress?.addressId ==
                                address.addressId;

                        return InkWell(
                          onTap: () {
                            addressManager.selectAddress(address);

                            Navigator.pop(context);

                            _recalcFee();
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(.07)
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.grey200,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Address icon
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withOpacity(.12)
                                        : AppColors.card,
                                    borderRadius:
                                    BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    _iconForType(
                                      address.addressTypeId,
                                    ),
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Address details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        address.typeName,
                                        style: getBoldStyle(
                                          fontSize: MyFonts.size14,
                                          color: AppColors.text,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        address.address1,
                                        maxLines: 2,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        style: getRegularStyle(
                                          fontSize: MyFonts.size12,
                                          color: AppColors.greyText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Selected tick
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
                                      border: Border.all(
                                        color: AppColors.borderLight,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Manage Address screen open karna
  Future<void> _openManageAddress() async {

    final selected = await Navigator.push<CustomerAddress>(
      context,
      PageTransitions.slideFromRight(const ManageAddressView()),
    );

    if (!mounted) {
      return;
    }

    final addressManager = context.read<AddressManagerController>();

    // Address list dobara load karna
    await addressManager.loadAddresses();

    // Agar koi address select karke wapas aaye hain
    // to us address ko selected rakhna
    if (selected != null) {
      addressManager.selectAddress(selected);
    }

    // Address change hone ke baad fee calculate karna
    _recalcFee();
  }

  // Address type ke according icon
  IconData _iconForType(int? typeId) {

    switch (typeId) {

      case 3:
        return Icons.home_rounded;

      case 4:
        return Icons.apartment_rounded;

      case 5:
        return Icons.work_rounded;

      default:
        return Icons.location_on;
    }
  }
  // NEW: ORDER PLACEMENT

  Future<void> _placeOrder() async {
    final cart = context.read<CartController>();
    final addressManager = context.read<AddressManagerController>();
    final home = context.read<HomeController>();

    final branch = home.selectedBranch;
    final menuData = home.menuModel?.data;

    if (branch == null || menuData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Branch info not available. Please try again."),
        ),
      );
      return;
    }

    if (cart.orderType == 'Delivery' &&
        addressManager.selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a delivery address.")),
      );
      return;
    }

    // GUEST SIGNUP — sirf guest checkout ke liye, aur sirf agar
    // abhi tak locked/signed-up nahi hua
    // GUEST SIGNUP — sirf guest checkout ke liye, aur sirf agar
    // abhi tak locked/signed-up nahi hua
    if (cart.isGuestCheckout && !cart.isGuestLocked) {
      final isValid = cart.validateGuestDetails();

      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please fill in your name, email and phone number."),
          ),
        );
        return;
      }

      final signUpSuccess = await cart.guestSignUp();

      if (!mounted) return;

      if (!signUpSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not verify guest details. Please try again."),
          ),
        );
        return; // Guest signup fail -> order place NAHI hoga
      }

      // Ab token mil chuka hai. Agar Delivery hai, to abhi tak jo
      // local (unsaved) address select thi usko backend par save
      // karo taake usko ek real delivery_address_id mil jaye.
      if (cart.orderType == 'Delivery' &&
          addressManager.selectedAddress != null) {

        final existingAddress = cart.guestUserData?.addresses
            ?.where((a) => a.addressTypeId == 3)
            .cast<CustomerAddress?>()
            .firstWhere((a) => a != null, orElse: () => null);

        if (existingAddress != null && existingAddress.id != null) {
          // Backend pe already address maujood hai — dobara create mat karo
          addressManager.selectAddress(existingAddress);
        } else {
          final localAddress = addressManager.selectedAddress!;
          final saved = await addressManager.addEditAddress(
            addressTypeId: localAddress.addressTypeId ?? 3,
            address1: localAddress.address1,
            latitude: localAddress.latitude,
            longitude: localAddress.longitude,
            isDefault: 1,
          );

          if (!mounted) return;

          if (!saved || addressManager.selectedAddress?.id == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Could not save delivery address. Please try again."),
              ),
            );
            return;
          }
        }
      }
    }
    setState(() => _isPlacingOrder = true);

    try {
      // final userId = await _prefs.getUserId();
      final String customerId;
      if (cart.isGuestCheckout && cart.guestUserData?.id != null) {
        customerId = cart.guestUserData!.id.toString();
      } else {
        final userId = await _prefs.getUserId();
        customerId = userId?.toString() ?? '';
      }
      final subTotal = _calculateSubtotal(cart);
      final taxPercent = double.tryParse(menuData.taxPercent ?? '0') ?? 0;
      final taxInclude = menuData.taxInclude ?? true;
      final couponCtrl = context.read<CouponController>();
      final appliedCoupon = couponCtrl.appliedCoupon;
      final legacy = couponCtrl.appliedPromotionData?.legacyCompat;
      final walletCtrl = context.read<WalletController>();
      double deliveryCharges = cart.orderType == 'Delivery' ? addressManager.deliveryFee : 0;
      double subtotalAfterDiscount = subTotal + deliveryCharges - couponCtrl.discountAmount;
      double walletToApply = (_useWallet && AppConstants.enableLoyaltySystem)
          ? (walletCtrl.walletAmount > subtotalAfterDiscount
          ? subtotalAfterDiscount
          : walletCtrl.walletAmount)
          : 0.0;

      final payload = OrderPayloadBuilder.build(
        cartItems: cart.cartItems,
        orderType: cart.orderType,
        customerId: customerId,
        branchId: branch.id.toString(),
        subTotal: subTotal,
        taxPercent: taxPercent,
        taxInclude: taxInclude,
        deliveryFee: addressManager.deliveryFee,
        deliveryAddressId: addressManager.selectedAddress?.id?.toString(),
        discountAmount: couponCtrl.discountAmount,
        discountPercent: appliedCoupon?.isPercentage == true
            ? appliedCoupon!.discountValue
            : (legacy?.discountPer?.toDouble() ?? 0),
        discountId: appliedCoupon?.discountId ?? int.tryParse('${legacy?.discountId ?? ''}'),
        couponId: appliedCoupon?.couponId ?? int.tryParse('${legacy?.couponId ?? ''}'),
        walletAmount: walletToApply,
      );
      final response = await _orderRepository.placeOrder(payload);

      if (!mounted) return;
      if (AppConstants.enableLoyaltySystem) {
        walletCtrl.loadWalletData();
      }


      if (response['Success'] == true) {
        await cart.clearCart();

        if (!mounted) return;

        // success dialog dikhao
        await showDialog(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: AppColors.card,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Modern Success Icon Badge
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Order Placed!',
                    textAlign: TextAlign.center,
                    style: getBoldStyle(
                      fontSize: MyFonts.size18,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Content Message
                  Text(
                    'Your order has been placed successfully.',
                    textAlign: TextAlign.center,
                    style: getRegularStyle(
                      fontSize: MyFonts.size13,
                      color: AppColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Compact Modern Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'OK',
                        style: getBoldStyle(
                          fontSize: MyFonts.size14,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        if (!mounted) return;
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        final errorMsg = response['ErrorMessage']?.toString() ??
            response['Message']?.toString() ??
            "Failed to place order. Please try again.";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
        ),
      );
    }

    if (mounted) setState(() => _isPlacingOrder = false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,

      // App Bar
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        title: Text(
          'Checkout',
          style: getExtraBoldStyle(
            fontSize: MyFonts.size24,
            color: AppColors.text,
          ),
        ),
      ),

      body: Consumer2<CartController, AddressManagerController>(
        builder: (
            context,
            cart,
            addressManager,
            child,
            ) {

          // Cart ka subtotal
          final subtotal = _calculateSubtotal(cart);

          // Delivery charges
          double deliveryCharges = 0.0;

          if (cart.orderType == 'Delivery' &&
              addressManager.deliveryAvailable) {
            deliveryCharges = addressManager.deliveryFee;
          }
// Tax nikaalo (menu data se) — tax_include: true hai isliye
// yeh subtotal ke andar hi shaamil hai, sirf dikhane ke liye
          final menuData = context.read<HomeController>().menuModel?.data;
          final taxPercent = double.tryParse(menuData?.taxPercent ?? '0') ?? 0;
          final taxAmount = (subtotal * taxPercent) / (100 + taxPercent);
          // Coupon discount
          final discount = context.watch<CouponController>().discountAmount;
//  NEW — wallet calculation
          final walletController = context.watch<WalletController>();
          final subtotalAfterDiscount = subtotal + deliveryCharges - discount;
          final walletApplied = (_useWallet && AppConstants.enableLoyaltySystem)
              ? (walletController.walletAmount > subtotalAfterDiscount
              ? subtotalAfterDiscount
              : walletController.walletAmount)
              : 0.0;

          final total = subtotalAfterDiscount - walletApplied;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              18,
              10,
              18,
              30,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ORDER TYPE
// ORDER TYPE
//                 Text(
//                   'Order Type',
//                   style: getBoldStyle(
//                     fontSize: MyFonts.size19,
//                     color: AppColors.text,
//                   ),
//                 ),

                // const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _orderTypeCard(
                        title: 'Takeaway',
                        icon: Icons.shopping_bag_rounded,
                        selected: cart.orderType == 'Takeaway',
                        onTap: () async {
                          await cart.changeOrderType('Takeaway');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _orderTypeCard(
                        title: 'Delivery',
                        icon: Icons.delivery_dining_rounded,
                        selected: cart.orderType == 'Delivery',
                        onTap: () async {
                          await cart.changeOrderType('Delivery');
                          _recalcFee();
                        },
                      ),
                    ),
                  ],
                ),
              // DELIVERY ADDRESS

                const SizedBox(height: 14),
                // Text(
                //   'Customer Details',
                //   style: getBoldStyle(fontSize: MyFonts.size19, color: AppColors.text),
                // ),
                const SizedBox(height: 10),
                GuestDetailsCard(
                  orderType: cart.orderType,
                  addressManager: addressManager,
                  iconForType: _iconForType,
                  isGuest: cart.isGuestCheckout,        // NEW
                  onEditAddress: _openGuestAddressEditor,     // guest: map
                  onManageAddress: _openManageAddress,        // NEW — logged-in: manage screen
                  onShowAddressList: _showAddressDropdown,    // NEW — logged-in: dropdown
                ),
                SizedBox(height: 10,),
                // ORDER SUMMARY
                Text(
                  'Order Summary',
                  style: getBoldStyle(
                    fontSize: MyFonts.size19,
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [

                      // ---- Header strip ----
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(.08),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Icon(
                                Icons.receipt_long_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Bill Details',
                              style: getSemiBoldStyle(
                                fontSize: MyFonts.size14,
                                color: AppColors.text,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${cart.cartItems.length} item${cart.cartItems.length > 1 ? 's' : ''}',
                              style: getRegularStyle(
                                fontSize: MyFonts.size12,
                                color: AppColors.greyText,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ---- Cart items ----
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
                        child: Column(
                          children: cart.cartItems.map((food) {
                            final price = double.tryParse(food.price ?? '0') ?? 0;
                            final quantity = food.quantity ?? 1;
                            final itemTotal = price * quantity;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$quantity',
                                      style: getBoldStyle(
                                        fontSize: MyFonts.size11,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      food.menuName ?? 'Food',
                                      style: getRegularStyle(
                                        fontSize: MyFonts.size14,
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Rs ${itemTotal.toStringAsFixed(0)}',
                                    style: getSemiBoldStyle(
                                      fontSize: MyFonts.size14,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // ---- Dashed divider ----
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          children: List.generate(
                            40,
                                (index) => Expanded(
                              child: Container(
                                height: 1,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                color: index % 2 == 0
                                    ? AppColors.borderLight
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ---- Summary rows ----
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
                        child: Column(
                          children: [
                            _summaryRow('Subtotal', subtotal),

                            if (taxAmount > 0)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tax (${taxPercent.toStringAsFixed(0)}% incl.)',
                                      style: getRegularStyle(
                                        fontSize: MyFonts.size14,
                                        color: AppColors.greyText,
                                      ),
                                    ),
                                    Text(
                                      'Rs ${taxAmount.toStringAsFixed(0)}',
                                      style: getSemiBoldStyle(
                                        fontSize: MyFonts.size14,
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (discount > 0)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.local_offer_rounded, size: 13, color: AppColors.primary),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Discount',
                                          style: getRegularStyle(
                                            fontSize: MyFonts.size14,
                                            color: AppColors.greyText,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '- Rs ${discount.toStringAsFixed(0)}',
                                      style: getSemiBoldStyle(
                                        fontSize: MyFonts.size14,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (walletApplied > 0)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.account_balance_wallet_rounded, size: 13, color: AppColors.primary),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Wallet Balance',
                                          style: getRegularStyle(
                                            fontSize: MyFonts.size14,
                                            color: AppColors.greyText,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '- Rs ${walletApplied.toStringAsFixed(0)}',
                                      style: getSemiBoldStyle(
                                        fontSize: MyFonts.size14,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (cart.orderType == 'Delivery')
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Delivery Charges',
                                      style: getRegularStyle(
                                        fontSize: MyFonts.size14,
                                        color: AppColors.greyText,
                                      ),
                                    ),
                                    if (addressManager.isCalculatingFee)
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 11,
                                            height: 11,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.6,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Calculating...',
                                            style: getSemiBoldStyle(
                                              fontSize: MyFonts.size13,
                                              color: AppColors.greyText,
                                            ),
                                          ),
                                        ],
                                      )
                                    else if (!addressManager.deliveryAvailable)
                                      const SizedBox()
                                    else
                                      Text(
                                        'Rs ${addressManager.deliveryFee.toStringAsFixed(0)}',
                                        style: getSemiBoldStyle(
                                          fontSize: MyFonts.size14,
                                          color: AppColors.text,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                            if (cart.orderType == 'Delivery' &&
                                !addressManager.deliveryAvailable &&
                                !addressManager.isCalculatingFee &&
                                addressManager.deliveryMessage != null)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 10, bottom: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.red.withOpacity(.07),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline_rounded, size: 15, color: AppColors.red),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        addressManager.deliveryMessage!,
                                        style: getSemiBoldStyle(
                                          fontSize: MyFonts.size12,
                                          color: AppColors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 8),
                          ],
                        ),
                      ),

                      // ---- Total (highlighted footer) ----
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.06),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Total Amount',
                              style: getBoldStyle(
                                fontSize: MyFonts.size16,
                                color: AppColors.text,
                              ),
                            ),
                            Text(
                              'Rs ${total.toStringAsFixed(0)}',
                              style: getExtraBoldStyle(
                                fontSize: MyFonts.size22,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                if (!cart.isGuestCheckout && !_isActuallyGuest) ... [ const SizedBox(height: 8),
                  CouponSection(
                    branchId: context.read<HomeController>().selectedBranch?.id?.toString() ?? '',
                    customerId: _customerId,
                    subtotal: subtotal,
                    cartItems: cart.cartItems,
                    orderTypeId: cart.orderType == 'Delivery' ? 3 : 2,
                    deliveryFee: cart.orderType == 'Delivery' ? addressManager.deliveryFee : 0,
                  ),
                  const SizedBox(height: 17),
                  if (AppConstants.enableLoyaltySystem && walletController.walletAmount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 17),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Use wallet balance',
                                  style: getSemiBoldStyle(fontSize: MyFonts.size13, color: AppColors.text),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Rs ${walletController.walletAmount.toStringAsFixed(0)} available',
                                  style: getRegularStyle(fontSize: MyFonts.size11, color: AppColors.greyText),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _useWallet,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() => _useWallet = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ] else
                    const SizedBox(height: 15), ],

                // PLACE ORDER
                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton(

                    // CHANGED: Delivery area se bahar ho, cart khaali ho,
                    // ya order already place ho raha ho to button disabled
                    onPressed:
                    (_isPlacingOrder ||
                        cart.cartItems.isEmpty ||
                        addressManager.isLoading ||
                        (cart.orderType == 'Delivery' &&
                            !addressManager.deliveryAvailable))
                        ? null
                        : _placeOrder,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),

                    child: _isPlacingOrder
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      'Place Order',
                      style: getExtraBoldStyle(
                        fontSize: MyFonts.size16,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // DELIVERY ADDRESS CARD

  // DELIVERY ADDRESS CARD
  Widget _deliveryAddressCard(
      AddressManagerController addressManager, {
        bool isEditable = true,
      }) {
    final selected = addressManager.selectedAddress;
    if (addressManager.isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Fetching your address...',
              style: getSemiBoldStyle(fontSize: MyFonts.size13, color: AppColors.greyText),
            ),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Address icon
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              selected != null
                  ? _iconForType(selected.addressTypeId)
                  : Icons.location_on_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          // Address details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        selected != null ? selected.typeName : 'No address',
                        style: getBoldStyle(
                          fontSize: MyFonts.size14,
                          color: AppColors.text,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (selected != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Selected',
                          style: getSemiBoldStyle(
                            fontSize: MyFonts.size9,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  selected != null ? selected.address1 : 'Select delivery address',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: getRegularStyle(
                    fontSize: MyFonts.size12,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // Actions
          if (isEditable)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: _openManageAddress,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ),
              if (addressManager.addresses.isNotEmpty) ...[
                const SizedBox(height: 6),
                InkWell(
                  onTap: _showAddressDropdown,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(7),
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
          ),
        ],
      ),
    );
  }

  // ORDER TYPE CARD
  // ORDER TYPE CARD
  Widget _orderTypeCard({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(.08)
              : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.greyText,
              size: 19,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: getSemiBoldStyle(
                  fontSize: MyFonts.size13,
                  color: selected ? AppColors.primary : AppColors.text,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
  // SUMMARY ROW
  Widget _summaryRow(
      String title,
      double value,
      ) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

        children: [

          Text(
            title,
            style: getRegularStyle(
              fontSize: MyFonts.size14,
              color: AppColors.greyText,
            ),
          ),

          Text(
            'Rs ${value.toStringAsFixed(0)}',
            style: getSemiBoldStyle(
              fontSize: MyFonts.size14,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
  // CALCULATE SUBTOTAL
  double _calculateSubtotal(CartController cart) {
    double total = 0;

    for (final food in cart.cartItems) {
      final price = double.tryParse(food.price ?? '0') ?? 0;
      final quantity = food.quantity ?? 1;

      total = total + (price * quantity);
    }

    return total;
  }
}