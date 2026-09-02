import 'package:flutter/material.dart';

import 'model/menu_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';
import 'widget/food_detail_bottom_sheet.dart';
import 'widget/food_item_card.dart';

class DealsView extends StatelessWidget {
  final List<Menu> deals;

  const DealsView({
    super.key,
    required this.deals,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
              showFoodDetailBottomSheet(
                context,
                food,
              );
            },
          );
        },
      ),
    );
  }
}




