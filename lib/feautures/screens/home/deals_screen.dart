import 'package:flutter/material.dart';

import '../../../core/models/menu_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/food_detail_bottom_sheet.dart';
import '../../widgets/food_item_card.dart';

class DealsScreen extends StatelessWidget {
  final List<Menu> deals;

  const DealsScreen({
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

        title:  Text(
          "Special Deals",
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
      ),

      body: deals.isEmpty
          ?  Center(
        child: Text(
          "No deals available",
          style: TextStyle(
            color: AppColors.greyText,
            fontSize: 15,
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