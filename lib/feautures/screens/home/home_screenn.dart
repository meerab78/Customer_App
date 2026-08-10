import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/provider/home_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/branch_selector_card.dart';
import '../../widgets/food_detail_bottom_sheet.dart';
import '../../widgets/food_item_card.dart';
import '../../widgets/home_header.dart';
import '../../widgets/menu_category_card.dart';
import '../../widgets/order_type_bottom_sheet.dart';

class HomeScreenn extends StatefulWidget {
  const HomeScreenn({super.key});

  @override
  State<HomeScreenn> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreenn> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<HomeProvider>().loadHomeData();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          showOrderTypeBottomSheet(context);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    if (provider.isLoading || provider.menuModel == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final selectedCategory = provider
        .menuModel!
        .data!
        .restaurantBranchMenu[
    provider.selectedCategoryIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: SizedBox(
        width: MediaQuery.of(context).size.width * .72,
        child: const AppDrawer(),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeHeader(),

            // const HomeWelcome(),
            const SizedBox(height: 10),
            const Text(
              "Menu",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.menuModel?.data?.restaurantBranchMenu.length ?? 0,
                itemBuilder: (context, index) {
                  final category = provider
                      .menuModel!
                      .data!
                      .restaurantBranchMenu[index];
                  return MenuCategoryCard(
                    title: category.name ?? "",
                    selected:
                    provider.selectedCategoryIndex == index,
                    onTap: () {
                      provider.changeCategory(index);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: selectedCategory.menu.length,
                itemBuilder: (context, index) {
                  final food = selectedCategory.menu[index];
                  return  FoodItemCard(
                    name: food.name ?? "",
                    description: food.description ?? "",
                    price: food.price ?? "0",
                    imageUrl: (food.image != null && food.image!.isNotEmpty)
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
            )
          ],
        ),
      ),
    );
  }
}