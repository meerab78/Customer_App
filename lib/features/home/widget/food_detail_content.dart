import 'package:flutter/material.dart';
import '../model/menu_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import 'food_quantity_cart_bar.dart';

class FoodDetailContent extends StatelessWidget {
  final Menu food;
  final int quantity;
  final double total;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;
  final bool isAddEnabled;

  const FoodDetailContent({
    super.key,
    required this.food,
    required this.quantity,
    required this.total,
    required this.onQuantityChanged,
    required this.onAddToCart,
    this.isAddEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FoodImage(
          imageUrl: food.imageUrl ?? '',
          hasImage: food.imageUrl != null &&
              food.imageUrl!.isNotEmpty,
        ),

        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                food.name ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: getExtraBoldStyle(
                  fontSize: MyFonts.size21,
                  color: AppColors.text,
                ).copyWith(height: 1.15),
              ),
            ),

            const SizedBox(width: 12),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.09),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Rs ${food.price ?? '0'}',
                style: getExtraBoldStyle(
                  fontSize: MyFonts.size15,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),

        if ((food.description ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 9),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              food.description!.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: getRegularStyle(
                fontSize: MyFonts.size13_5,
                color: AppColors.greyText,
              ).copyWith(height: 1.45),
            ),
          ),
        ],

        const SizedBox(height: 18),

        FoodQuantityCartBar(
          quantity: quantity,
          total: total,
          isAddEnabled: isAddEnabled,
          onMinus: () {
            if (quantity > 1) {
              onQuantityChanged(quantity - 1);
            }
          },
          onPlus: () {
            onQuantityChanged(quantity + 1);
          },
          onAddToCart: onAddToCart,
        ),
      ],
    );
  }
}

class FoodImage extends StatelessWidget {
  final String imageUrl;
  final bool hasImage;

  const FoodImage({
    super.key,
    required this.imageUrl,
    required this.hasImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      height: 165,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.softShadow07,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: hasImage
            ? Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return const FoodPlaceholder();
          },
        )
            : const FoodPlaceholder(),
      ),
    );
  }
}

class FoodPlaceholder extends StatelessWidget {
  const FoodPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.grey100,
      child: Icon(
        Icons.fastfood_rounded,
        size: 55,
        color: AppColors.primary,
      ),
    );
  }
}