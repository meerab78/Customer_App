
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      content: Text(
        '${food.name ?? 'Item'} added to cart',
      ),
      duration: const Duration(seconds: 1),
    ),
  );
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

  if (!context.mounted) return;

  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '${food.name ?? 'Item'} added to cart ✓',
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}