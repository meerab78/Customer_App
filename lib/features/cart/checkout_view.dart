import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';

import '../home/controller.dart';
import '../auth/address/manager_controller.dart';
import '../auth/address/manage_address_view.dart';
import '../auth/address/model/address_model.dart';
import '../../core/db/shared_pref.dart';
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAddresses();
    });
  }

  // Checkout start hone par addresses load honge
  // Agar address nahi hai to Home address banega
  // Agar order Delivery hai to delivery fee calculate hogi
  Future<void> _initAddresses() async {
    final addressManager = context.read<AddressManagerController>();
    final cart = context.read<CartController>();

    await addressManager.loadAddresses();

    await addressManager.ensureHomeAddress();

    if (cart.orderType == 'Delivery') {
      _recalcFee();
    }
  }

  // Delivery fee calculate karna
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
            color: AppColors.white,
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
                                        : AppColors.white,
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
                                        color: AppColors.grey200,
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
      MaterialPageRoute(
        builder: (_) => const ManageAddressView(),
      ),
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

    setState(() => _isPlacingOrder = true);

    try {
      final userId = await _prefs.getUserId();
      final customerId = userId?.toString() ?? '';
      final subTotal = _calculateSubtotal(cart);
      final taxPercent = double.tryParse(menuData.taxPercent ?? '0') ?? 0;
      final taxInclude = menuData.taxInclude ?? true;

      final payload = OrderPayloadBuilder.build(
        cartItems: cart.cartItems,
        orderType: cart.orderType,
        customerId: customerId,
        branchId: branch.id.toString(),
        subTotal: subTotal,
        taxPercent: taxPercent,
        taxInclude: taxInclude,
        deliveryFee: addressManager.deliveryFee,
        deliveryAddressId: addressManager.selectedAddress?.id?.toString(),      );

      final response = await _orderRepository.placeOrder(payload);

      if (!mounted) return;

      if (response['Success'] == true) {
        await cart.clearCart();

        if (!mounted) return;

        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              'Order Placed! ',
              style: getBoldStyle(
                fontSize: MyFonts.size18,
                color: AppColors.text,
              ),
            ),
            content: Text(
              'Your order has been placed successfully.',
              style: getRegularStyle(
                fontSize: MyFonts.size14,
                color: AppColors.greyText,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: getSemiBoldStyle(
                    fontSize: MyFonts.size14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );

        if (!mounted) return;
        Navigator.pop(context);
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
          // Final total
          final total = subtotal + deliveryCharges;


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

                Text(
                  'Order Type',
                  style: getBoldStyle(
                    fontSize: MyFonts.size19,
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: 12),

                // Takeaway
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
                  ],
                ),

                const SizedBox(height: 10),

                // Delivery
                _orderTypeCard(
                  title: 'Delivery',
                  icon: Icons.delivery_dining_rounded,
                  selected: cart.orderType == 'Delivery',

                  onTap: () async {

                    await cart.changeOrderType('Delivery');

                    // Delivery select hone ke baad fee calculate
                    _recalcFee();
                  },
                ),
                // DELIVERY ADDRESS

                if (cart.orderType == 'Delivery') ...[

                  const SizedBox(height: 24),

                  Text(
                    'Delivery Address',
                    style: getBoldStyle(
                      fontSize: MyFonts.size19,
                      color: AppColors.text,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _deliveryAddressCard(addressManager),
                ],

                const SizedBox(height: 28),


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
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(
                    children: [

                      // Cart items
                      ...cart.cartItems.map((food) {

                        final price =
                            double.tryParse(food.price ?? '0') ?? 0;

                        final quantity = food.quantity ?? 1;

                        final itemTotal = price * quantity;

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 12,
                          ),

                          child: Row(
                            children: [

                              // Food name
                              Expanded(
                                child: Text(
                                  '${food.menuName ?? 'Food'} × $quantity',
                                  style: getRegularStyle(
                                    fontSize: MyFonts.size14,
                                    color: AppColors.text,
                                  ),
                                ),
                              ),

                              // Food total price
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
                      }),

                      Divider(
                        color: AppColors.grey200,
                      ),

                      const SizedBox(height: 8),

                      // Subtotal
                      _summaryRow(
                        'Subtotal',
                        subtotal,
                      ),
                      // TAX ROW (included tax — breakdown ke liye)
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
                      // DELIVERY CHARGES

                      if (cart.orderType == 'Delivery')
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                          ),

                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,

                            children: [

                              Text(
                                'Delivery Charges',
                                style: getRegularStyle(
                                  fontSize: MyFonts.size14,
                                  color: AppColors.greyText,
                                ),
                              ),

                              // Fee calculate ho rahi hai
                              if (addressManager.isCalculatingFee)

                                Text(
                                  'Calculating...',
                                  style: getSemiBoldStyle(
                                    fontSize: MyFonts.size13,
                                    color: AppColors.greyText,
                                  ),
                                )

                              // Delivery available nahi
                              else if (
                              !addressManager.deliveryAvailable
                              )

                                const SizedBox()

                              // Delivery available hai
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


                      // OUT OF AREA MESSAGE


                      if (cart.orderType == 'Delivery' &&
                          !addressManager.deliveryAvailable &&
                          !addressManager.isCalculatingFee &&
                          addressManager.deliveryMessage != null)

                        Padding(
                          padding: const EdgeInsets.only(
                            top: 6,
                          ),

                          child: Text(
                            addressManager.deliveryMessage!,
                            style: getSemiBoldStyle(
                              fontSize: MyFonts.size12,
                              color: AppColors.red,
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      Divider(
                        color: AppColors.grey200,
                      ),

                      const SizedBox(height: 8),

                      // TOTAL

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                        children: [

                          Text(
                            'Total',
                            style: getBoldStyle(
                              fontSize: MyFonts.size18,
                              color: AppColors.text,
                            ),
                          ),

                          Text(
                            'Rs ${total.toStringAsFixed(0)}',
                            style: getExtraBoldStyle(
                              fontSize: MyFonts.size20,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),


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

  Widget _deliveryAddressCard(
      AddressManagerController addressManager,
      ) {

    final selected = addressManager.selectedAddress;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.grey200,
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // Address icon
          Icon(
            selected != null
                ? _iconForType(selected.addressTypeId)
                : Icons.location_on_outlined,

            color: AppColors.primary,
          ),

          const SizedBox(width: 12),

          // Address details
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  selected != null
                      ? selected.typeName
                      : 'No address',

                  style: getBoldStyle(
                    fontSize: MyFonts.size14,
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  selected != null
                      ? selected.address1
                      : 'Select delivery address',

                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,

                  style: getRegularStyle(
                    fontSize: MyFonts.size13,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),

          // Edit address
          IconButton(
            onPressed: _openManageAddress,

            icon: Icon(
              Icons.edit_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),

          // Address dropdown
          if (addressManager.addresses.length > 1)

            IconButton(
              onPressed: _showAddressDropdown,

              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
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

      final price =
          double.tryParse(food.price ?? '0') ?? 0;

      final quantity = food.quantity ?? 1;

      total = total + (price * quantity);
    }

    return total;
  }
  // ORDER TYPE CARD

  Widget _orderTypeCard({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {

    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(18),

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        decoration: BoxDecoration(

          // Selected ho to halka primary color
          color: selected
              ? AppColors.primary.withOpacity(.08)
              : AppColors.white,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.grey200,

            width: selected ? 1.5 : 1,
          ),
        ),

        child: Row(
          children: [

            // Icon
            Icon(
              icon,
              color: selected
                  ? AppColors.primary
                  : AppColors.greyText,
            ),

            const SizedBox(width: 10),

            // Title
            Expanded(
              child: Text(
                title,

                style: getSemiBoldStyle(
                  fontSize: MyFonts.size14,

                  color: selected
                      ? AppColors.primary
                      : AppColors.text,
                ),
              ),
            ),

            // Selected check
            if (selected)

              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SUMMARY ROW
  // ==========================================

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
}