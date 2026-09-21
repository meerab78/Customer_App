
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../deal_detail_view.dart';
import '../model/menu_model.dart';
import '../variation_view.dart';
import '../../cart/controller.dart';
import 'food_detail_bottom_sheet.dart';

Future<void> handleFoodTap(
    BuildContext context,
    Menu food,
    ) async {
// DEAL
  if (food.isDeal == true) {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DealDetailView(
          food: food,
        ),
      ),
    );
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    return;
  }
// NORMAL ITEM

  final hasCustomization =
      food.menuVariations.isNotEmpty ||
          food.choiceGroup.isNotEmpty;

  if (hasCustomization) {
    await _openVariationView(
      context,
      food,
    );

    return;
  }

  showFoodDetailBottomSheet(
    context,
    food,
  );
}

Future<void> handleAddToCart(
    BuildContext context,
    Menu food,
    ) async {
// Deal ke plus button par bhi
// DealDetailView open hogi.
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

  final hasCustomization =
      food.menuVariations.isNotEmpty ||
          food.choiceGroup.isNotEmpty;

  if (hasCustomization) {
    await _openVariationView(
      context,
      food,
    );

    return;
  }
  await context.read<CartController>().addToCart(
    food,
    1,
  );

  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.primary,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      margin: const EdgeInsets.all(16),
      content: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${food.name ?? 'Item'} added to cart',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  if (context.mounted) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

Future<void> _openVariationView(
    BuildContext context,
    Menu food,
    ) async {
  final variation =
  await Navigator.push<MenuVariation>(
    context,
    MaterialPageRoute(
      builder: (_) => VariationView(
        food: food,
      ),
    ),
  );

  if (variation == null || !context.mounted) {
    return;
  }

  final selectedFood = food.copyWith(
    // price: variation.price,
    takeAwayPrice: variation.takeAwayPrice,
    deliveryPrice: variation.deliveryPrice,
    menuVariation: variation,
    choiceGroup: variation.choiceGroups,
  );

  await context.read<CartController>().addToCart(
    selectedFood,
    1,
  );

  // if (!context.mounted) return;
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.primary,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      margin: const EdgeInsets.all(16),
      content: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${food.name ?? 'Item'} added to cart',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  if (context.mounted) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}