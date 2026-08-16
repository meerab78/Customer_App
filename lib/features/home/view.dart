
import 'package:customer_app/features/home/widget/add_to_cart_handler.dart';
import 'package:customer_app/features/home/widget/special_deals_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller.dart';
import '../../core/shared/widgets/reusable_loading.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';
import 'widget/food_item_card.dart';
import 'widget/home_header.dart';
import 'widget/menu_category_card.dart';
import 'widget/order_type_bottom_sheet.dart';
import 'category_items_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeView> {
  bool _orderTypeShown = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<HomeController>().loadHomeData();
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
    final provider = Provider.of<HomeController>(context);

    if (provider.isLoading || provider.menuModel == null) {
      return const CustomLoading();
    }

    final categories =
        provider.menuModel!.data!.restaurantBranchMenu;

    if (categories.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No menu available'),
        ),
      );
    }

    final selectedCategory =
    categories[provider.selectedCategoryIndex];

    final selectedCategoryItems =
        selectedCategory.menu;

    // Get all deal items
    final specialDeals = categories
        .expand((category) => category.menu)
        .where((food) => food.isDeal == true)
        .toList();

    // Only show first 4 deals on Home
    final homeSpecialDeals = specialDeals.length > 4
        ? specialDeals.take(4).toList()
        : specialDeals;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // =========================
              // HEADER
              // =========================

              const HomeHeader(),

              const SizedBox(height: 14),

              // =========================
              // MENU HEADING
              // =========================

              Text(
                "Menu",
                style: getBoldStyle(
                  fontSize: MyFonts.size22,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 8),

              // =========================
              // CATEGORIES
              // =========================

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

              // =========================
              // SELECTED CATEGORY
              // =========================

              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedCategory.name ?? "Items",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getBoldStyle(
                        fontSize: MyFonts.size19,
                        color: AppColors.text,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryItemsView(
                            category: selectedCategory,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "See All",
                      style: getSemiBoldStyle(
                        fontSize: MyFonts.size14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // =========================
              // SELECTED CATEGORY ITEMS
              // =========================

              SizedBox(
                height: 205,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedCategoryItems.length,
                  itemBuilder: (context, index) {
                    final food =
                    selectedCategoryItems[index];

                    return FoodItemCard(
                      food: food,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              // SPECIAL DEALS
              if (specialDeals.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Special Deals",
                        style: getBoldStyle(
                          fontSize: MyFonts.size19,
                          color: AppColors.text,
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SpecialDealsView(
                              deals: specialDeals,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "See All",
                        style: getSemiBoldStyle(
                          fontSize: MyFonts.size14,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                SizedBox(
                  height: 205,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,

                    // ALL deals will be horizontally scrollable
                    itemCount: specialDeals.length,

                    itemBuilder: (context, index) {
                      final food = specialDeals[index];
                      return FoodItemCard(
                        food: food,
                        onTap: () {
                          handleFoodTap(context, food);
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