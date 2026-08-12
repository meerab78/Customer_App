import 'package:flutter/material.dart';

import '../../../core/models/menu_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/food_detail_bottom_sheet.dart';
import '../../widgets/food_item_card.dart';

class CategoryItemsScreen extends StatelessWidget {
  final RestaurantBranchMenu category;

  const CategoryItemsScreen({
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
          style:  TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
      ),

      body: items.isEmpty
          ?  Center(
        child: Text(
          "No items available",
          style: TextStyle(
            color: AppColors.greyText,
            fontSize: 15,
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
            name: food.name ?? "",
            description: food.description ?? "",
            price: food.price ?? "0",
            imageUrl:
            (food.image != null && food.image!.isNotEmpty)
                ? (food.imageUrl ?? "")
                : "",
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