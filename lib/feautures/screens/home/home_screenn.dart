
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/provider/home_provider.dart';
import '../../../core/shared/reusable_loading.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/food_detail_bottom_sheet.dart';
import '../../widgets/food_item_card.dart';
import '../../widgets/home_header.dart';
import '../../widgets/menu_category_card.dart';
import '../../widgets/order_type_bottom_sheet.dart';
import 'category_items_screen.dart';
import 'deals_screen.dart';

class HomeScreenn extends StatefulWidget {
  const HomeScreenn({super.key});

  @override
  State<HomeScreenn> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenn> {
  bool _orderTypeShown = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<HomeProvider>().loadHomeData();
    });

    _showOrderType();
  }
  void _showOrderType() {
    if (_orderTypeShown) return;

    _orderTypeShown = true;

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
      return const CustomLoading();
    }
    final categories =
        provider.menuModel!.data!.restaurantBranchMenu;
    final selectedCategory =
    categories[provider.selectedCategoryIndex];
    final specialDeals = categories
        .expand((category) => category.menu)
        .where((food) => food.isDeal == true)
        .toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const HomeHeader(),
              const SizedBox(height: 14),
              // Menu Heading
              const Text(
                "Menu",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Categories
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];

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
              const SizedBox(height: 18),
              // Selected Category Heading
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedCategory.name ?? "Items",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryItemsScreen(
                            category: selectedCategory,
                          ),
                        ),
                      );
                    },
                    child:  Text(
                      "See All",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Selected Category Food Items
              SizedBox(
                height: 205,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedCategory.menu.length,
                  itemBuilder: (context, index) {
                    final food = selectedCategory.menu[index];

                    return FoodItemCard(
                      name: food.name ?? "",
                      description: food.description ?? "",
                      price: food.price ?? "0",
                      imageUrl:
                      (food.image != null &&
                          food.image!.isNotEmpty)
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
              ),

              const SizedBox(height: 24),
              if (specialDeals.isNotEmpty) ...[
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Special Deals",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DealsScreen(
                              deals: specialDeals,
                            ),
                          ),
                        );
                      },
                      child:  Text(
                        "See All",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                SizedBox(
                  height: 205,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: specialDeals.length,
                    itemBuilder: (context, index) {
                      final food = specialDeals[index];

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
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}