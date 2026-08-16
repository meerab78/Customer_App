import 'package:flutter/material.dart';

import 'model/menu_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';
import 'widget/food_detail_bottom_sheet.dart';
import 'widget/food_item_card.dart';

class CategoryItemsView extends StatelessWidget {
  final RestaurantBranchMenu category;

  const CategoryItemsView({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final items = category.menu;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,

        title: Text(
          category.name ?? "Items",
          style: getBoldStyle(
            fontSize: MyFonts.size21,
            color: AppColors.text,
          ),
        ),
      ),

      body: items.isEmpty
          ? Center(
        child: Text(
          "No items available",
          style: getRegularStyle(
            color: AppColors.greyText,
            fontSize: MyFonts.size15,
          ),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,

        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),

        itemBuilder: (context, index) {
          final food = items[index];

           return FoodItemCard(
            food: food,
          );
        },
      ),
    );
  }
}




