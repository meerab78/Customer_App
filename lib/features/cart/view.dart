import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';
import 'widget/cart_item_card.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        title: Text(
          'My Cart',
          style: getExtraBoldStyle(
            fontSize: MyFonts.size24,
            color: AppColors.text,
          ),
        ),
      ),

      body: Consumer<CartController>(
        builder: (context, cart, _) {
          if (cart.cartItems.isEmpty) {
            return _emptyCart();
          }

          double total = 0;

          for (final food in cart.cartItems) {
            final price =
                double.tryParse(food.price ?? '0') ?? 0;

            total += price * (food.quantity ?? 1);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    10,
                    18,
                    10,
                  ),
                  itemCount: cart.cartItems.length,
                  itemBuilder: (context, index) {
                    final food = cart.cartItems[index];

                    return CartItemCard(
                      food: food,

                      onDelete: () {
                        cart.removeFromCart(food);
                      },

                      onPlus: () {
                        cart.increaseQuantity(food);
                      },

                      onMinus: () {
                        cart.decreaseQuantity(food);
                      },
                    );
                  },
                ),
              ),

              _checkoutSection(total),
            ],
          );
        },
      ),
    );
  }

  Widget _checkoutSection(double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        20,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: getRegularStyle(
                  fontSize: MyFonts.size15,
                  color: AppColors.greyText,
                ),
              ),
              Text(
                'Rs ${total.toStringAsFixed(0)}',
                style: getBlackStyle(
                  fontSize: MyFonts.size22,
                  color: AppColors.text,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                // Checkout later
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: Text(
                'Proceed to Checkout',
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
  }

  Widget _emptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Your cart is empty',
              style: getExtraBoldStyle(
                fontSize: MyFonts.size22,
                color: AppColors.text,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Add your favorite food and\nit will appear here.',
              textAlign: TextAlign.center,
              style: getRegularStyle(
                color: AppColors.greyText,
              ).copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}


