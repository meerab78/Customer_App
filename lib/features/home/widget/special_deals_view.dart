import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../deal_detail_view.dart';
import '../model/menu_model.dart';
import '../variation_view.dart';
import 'food_detail_bottom_sheet.dart';
import 'food_item_card.dart';

class SpecialDealsView extends StatelessWidget {
  final List<Menu> deals;

  const SpecialDealsView({
    super.key,
    required this.deals,
  });
  Future<void> handleFoodTap(
      BuildContext context,
      Menu food,
      ) async {

    // DEAL ITEM
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

    showFoodDetailBottomSheet(
      context,
      food,
    );
  }
  Future<void> _openVariationView(
      BuildContext context,
      Menu food,
      ) async {
    final variation = await Navigator.push<MenuVariation>(
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
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,

        title: Text(
          "Special Deals",
          style: getBoldStyle(
            fontSize: MyFonts.size21,
            color: AppColors.text,
          ),
        ),
      ),

      body: deals.isEmpty
          ? Center(
        child: Text(
          "No deals available",
          style: getRegularStyle(
            color: AppColors.greyText,
            fontSize: MyFonts.size15,
          ),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: deals.length,

        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),

        itemBuilder: (context, index) {
          final food = deals[index];

          return FoodItemCard(
            food: food,
            onTap: () {
              handleFoodTap(context, food);
            },
          );
        },
      ),
    );
  }
}