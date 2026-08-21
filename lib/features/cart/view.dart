import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../home/deal_detail_view.dart' show DealDetailView;
import '../home/model/menu_model.dart';
import '../home/variation_view.dart';
import 'checkout_view.dart';
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
                    return  CartItemCard(
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
                      onTap: () async {
                        // -----------------------------
                        // DEAL EDIT
                        // -----------------------------
                        if (food.isDeal == true) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DealDetailView(
                                food: food,
                              ),
                            ),
                          );

                          return;
                        }

                        // -----------------------------
                        // NORMAL CUSTOMIZATION
                        // -----------------------------
                        final hasCustomization =
                            food.menuVariation != null ||
                                food.choiceGroup.any(
                                      (group) =>
                                  group.choices.isNotEmpty,
                                );

                        if (!hasCustomization) {
                          return;
                        }

                        // ----------------------------------------------------
                        // ASAL BASE PRICE NIKALEIN
                        // (food.price abhi total hai: base + variation + choices)
                        // ----------------------------------------------------
                        final currentTotal =
                            double.tryParse(food.price ?? '0') ?? 0;

                        final variationExtra =
                            double.tryParse(food.menuVariation?.price ?? '0') ?? 0;

                        double choicesExtra = 0;
                        for (final group in food.menuVariation?.choiceGroups ?? []) {
                          for (final choice in group.choices) {
                            choicesExtra += double.tryParse(choice.price ?? '0') ?? 0;
                          }
                        }

                        final originalBasePrice =
                            currentTotal - variationExtra - choicesExtra;

                        // VariationView ko asal base price ke sath bhejein
                        final foodForEdit = food.copyWith(
                          price: originalBasePrice.toString(),
                        );

                        final updatedVariation =
                        await Navigator.push<MenuVariation>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VariationView(
                              food: foodForEdit,
                              isEditMode: true,
                            ),
                          ),
                        );

                        if (updatedVariation == null) {
                          return;
                        }

                        // Updated Menu create karo — base price yahan bhi preserve karein
                        final updatedFood = food.copyWith(
                          price: originalBasePrice.toString(),
                          menuVariation: updatedVariation,
                          choiceGroup: updatedVariation.choiceGroups,
                        );

                        await cart.updateCartItem(
                          food,
                          updatedFood,
                        );
                      },
                    );
                  },
                ),
              ),
              _checkoutSection(context, total),
            ],
          );
        },
      ),
    );
  }

  Widget _checkoutSection(
      BuildContext context,
      double total,
      ) {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CheckoutView(),
                  ),
                );
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


