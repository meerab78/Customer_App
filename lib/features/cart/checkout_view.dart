
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

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

      body: Consumer<CartController>(
        builder: (context, cart, _) {
          final subtotal = _calculateSubtotal(cart);

// Abhi delivery charges API se connect nahi kiye.
// Isliye temporary 0 rakhe hain.
          final deliveryCharges =
          cart.orderType == 'Delivery' ? 0.0 : 0.0;

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

                Row(
                  children: [
                    Expanded(
                      child: _orderTypeCard(
                        title: 'Dine-In',
                        icon: Icons.restaurant_rounded,
                        selected: cart.orderType == 'Dine-In',
                        onTap: () async {
                          await cart.changeOrderType('Dine-In');
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

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
                _orderTypeCard(
                  title: 'Delivery',
                  icon: Icons.delivery_dining_rounded,
                  selected: cart.orderType == 'Delivery',
                  onTap: () async {
                    await cart.changeOrderType('Delivery');
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

                  Container(
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
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            'Select delivery address',
                            style: getRegularStyle(
                              fontSize: MyFonts.size14,
                              color: AppColors.greyText,
                            ),
                          ),
                        ),

                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.greyText,
                        ),
                      ],
                    ),
                  ),
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

                      ...cart.cartItems.map(
                            (food) {
                          final price =
                              double.tryParse(
                                food.price ?? '0',
                              ) ??
                                  0;

                          final quantity =
                              food.quantity ?? 1;

                          return Padding(
                            padding:
                            const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${food.name ?? 'Food'} × $quantity',
                                    style: getRegularStyle(
                                      fontSize:
                                      MyFonts.size14,
                                      color:
                                      AppColors.text,
                                    ),
                                  ),
                                ),

                                Text(
                                  'Rs ${(price * quantity).toStringAsFixed(0)}',
                                  style: getSemiBoldStyle(
                                    fontSize:
                                    MyFonts.size14,
                                    color:
                                    AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      Divider(
                        color: AppColors.grey200,
                      ),

                      const SizedBox(height: 8),

                      _summaryRow(
                        'Subtotal',
                        subtotal,
                      ),

                      if (cart.orderType == 'Delivery')
                        _summaryRow(
                          'Delivery Charges',
                          deliveryCharges,
                        ),

                      const SizedBox(height: 8),

                      Divider(
                        color: AppColors.grey200,
                      ),

                      const SizedBox(height: 8),

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
                    onPressed: () {
// Next step:
// Place order API
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(17),
                      ),
                    ),
                    child: Text(
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

  double _calculateSubtotal(
      CartController cart,
      ) {
    double total = 0;

    for (final food in cart.cartItems) {
      final price =
          double.tryParse(food.price ?? '0') ?? 0;

      final quantity = food.quantity ?? 1;

      total += price * quantity;
    }

    return total;
  }

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
            Icon(
              icon,
              color: selected
                  ? AppColors.primary
                  : AppColors.greyText,
            ),

            const SizedBox(width: 10),

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
