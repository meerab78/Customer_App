

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/db/sqflite/model.dart' show OrderDetails;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../../../core/utils/order_type_price.dart' show pickOrderTypePrice;
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
      food.menuVariations.isNotEmpty || food.choiceGroup.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final orderType = context.watch<CartController>().orderType;

    final double displayPrice = pickOrderTypePrice(
      orderType: orderType,
      dinePrice: food.price,
      takeawayPrice: food.takeAwayPrice,
      deliveryPrice: food.deliveryPrice,
    );

    return Align(
      alignment: Alignment.topCenter, // Stretch overflow handle karega
      child: InkWell(
        onTap: onTap ??
                () {
              handleFoodTap(context, food);
            },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 155,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderLight.withOpacity(0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Price ke niche extra gap khatam
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE SECTION
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: _foodImage(),
                  ),
                  Positioned(
                    right: 6,
                    bottom: 6,
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

              // DETAILS SECTION
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getBoldStyle(
                        fontSize: MyFonts.size13,
                        color: AppColors.text,
                      ),
                    ),
                    if ((food.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        food.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: getRegularStyle(
                          fontSize: MyFonts.size10,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Rs ${displayPrice.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getBoldStyle(
                        fontSize: MyFonts.size13,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addButton(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            handleAddToCart(
              context,
              food,
            );
          },
          child: const Icon(
            Icons.add,
            color: AppColors.white,
            size: 18,
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
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              '${cartItem.quantity ?? 1}',
              style: getBoldStyle(
                fontSize: MyFonts.size11,
                color: AppColors.white,
              ),
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
        width: 24,
        height: 28,
        child: Icon(
          icon,
          color: AppColors.white,
          size: 14,
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
      height: 110, // Increased image height to perfectly fill container
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
      color: AppColors.containerColor4,
      child: Icon(
        Icons.fastfood_rounded,
        size: 36,
        color: AppColors.primary,
      ),
    );
  }
}