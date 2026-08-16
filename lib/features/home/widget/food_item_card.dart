import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../model/menu_model.dart';
import 'add_to_cart_handler.dart';
import 'food_detail_bottom_sheet.dart';

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

                // Plus button
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Material(
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