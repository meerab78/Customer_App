import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/db/sqflite/model.dart' show OrderDetails;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../../cart/controller.dart';
import '../model/menu_model.dart';
import 'add_to_cart_handler.dart';

class FoodItemCard extends StatelessWidget {
  final Menu food;
  final VoidCallback? onTap;

  const FoodItemCard({
    super.key,
    required this.food,
    this.onTap,
  });

  bool get hasCustomization =>
      food.menuVariations.isNotEmpty ||
          food.choiceGroup.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ??
              () {
            handleFoodTap(context, food);
          },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 160,
        height: 205,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.grey200,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.softShadow05,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: _foodImage(),
                ),

                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Consumer<CartController>(
                    builder: (context, cart, _) {
                      final cartItem = cart.simpleCartItem(food);

                      if (cartItem == null) {
                        return _addButton(context);
                      }

                      return _quantityButton(context, cart, cartItem);
                    },
                  ),
                ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  10,
                  8,
                  10,
                  8,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getBoldStyle(
                        fontSize: MyFonts.size15,
                        color: AppColors.text,
                      ),
                    ),

                    const SizedBox(height: 3),

                    if ((food.description ?? '').isNotEmpty)
                      Text(
                        food.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: getRegularStyle(
                          fontSize: MyFonts.size11,
                          color: AppColors.greyText,
                        ).copyWith(height: 1.2),
                      ),

                    const Spacer(),

                    Text(
                      'Rs ${food.price ?? '0'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getBoldStyle(
                        fontSize: MyFonts.size15,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          handleAddToCart(
            context,
            food,
          );
        },
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            Icons.add,
            color: AppColors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _quantityButton(
      BuildContext context,
      CartController cart,
      OrderDetails cartItem,
      ) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyIcon(
            Icons.remove,
            () {
              cart.decreaseQuantity(cartItem);
            },
          ),
          Text(
            '${cartItem.quantity ?? 1}',
            style: getBoldStyle(
              fontSize: MyFonts.size12,
              color: AppColors.white,
            ),
          ),
          _qtyIcon(
            Icons.add,
            () {
              cart.increaseQuantity(cartItem);
            },
          ),
        ],
      ),
    );
  }

  Widget _qtyIcon(
      IconData icon,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 28,
        height: 32,
        child: Icon(
          icon,
          color: AppColors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _foodImage() {
    final imageUrl = food.imageUrl ?? '';

    if (imageUrl.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 110,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return _placeholder();
      },
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 110,
      color: AppColors.grey100,
      child: Icon(
        Icons.fastfood_rounded,
        size: 42,
        color: AppColors.primary,
      ),
    );
  }
}
