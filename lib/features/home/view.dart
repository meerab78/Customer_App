
import 'package:customer_app/features/home/widget/add_to_cart_handler.dart';
import 'package:customer_app/features/home/widget/special_deals_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'controller.dart';
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

  // ===== ADDED: infinite scroll / auto category switch ke liye =====
  final ScrollController _itemsScrollController = ScrollController();
  final ScrollController _categoriesScrollController = ScrollController();

  double _dragDx = 0;
  bool _switching = false;

  static const double _categoryCardExtent = 91; // 85 card + 6 separator
  // ====================================================================

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<HomeController>().loadHomeData();
    });

    _checkAndShowOrderType();
  }

  @override
  void dispose() {
    _itemsScrollController.dispose();
    _categoriesScrollController.dispose();
    super.dispose();
  }

  void _checkAndShowOrderType() {
    if (_orderTypeShown) return;

    final home = context.read<HomeController>();
    if (home.orderTypeAsked) return; // is session mein already pouch chuke

    _orderTypeShown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          showOrderTypeBottomSheet(context);
        }
      });
    });
  }

  void _onItemsPointerDown(PointerDownEvent e) {
    _dragDx = 0;
  }

  void _onItemsPointerMove(PointerMoveEvent e) {
    _dragDx += e.delta.dx;
  }

  void _onItemsPointerUp(PointerUpEvent e, int length) {
    _evaluateSwipe(length);
  }

  void _evaluateSwipe(int length) {
    if (_switching || length <= 1) return;

    const threshold = 50.0;
    final dx = _dragDx;
    _dragDx = 0;

    if (dx.abs() < threshold) return;

    bool atStart = true;
    bool atEnd = true;

    if (_itemsScrollController.hasClients) {
      final pos = _itemsScrollController.position;
      atStart = pos.pixels <= 0.5;
      atEnd = pos.pixels >= pos.maxScrollExtent - 0.5;
    }

    if (dx < 0 && atEnd) {
      _switchCategory(1, length); // left swipe, list end pe -> next
    } else if (dx > 0 && atStart) {
      _switchCategory(-1, length); // right swipe, list start pe -> previous
    }
  }

  void _switchCategory(int step, int length) {
    final provider = context.read<HomeController>();
    final next = (provider.selectedCategoryIndex + step + length) % length;
    if (next == provider.selectedCategoryIndex) return;

    _switching = true;
    provider.changeCategory(next);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_itemsScrollController.hasClients) {
        _itemsScrollController.jumpTo(0);
      }
      _scrollCategoriesTo(next);

      _switching = false;
    });
  }

  void _scrollCategoriesTo(int index) {
    if (!_categoriesScrollController.hasClients) return;

    final target = (index * _categoryCardExtent)
        .clamp(0.0, _categoriesScrollController.position.maxScrollExtent);

    _categoriesScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeController>(context);

    // Show skeleton while API is loading
    if (provider.isLoading || provider.menuModel == null) {
      return _buildSkeleton();
    }

    final categories = provider.menuModel!.data!.restaurantBranchMenu;

    if (categories.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No menu available'),
        ),
      );
    }

    final selectedCategory = categories[provider.selectedCategoryIndex];

    final selectedCategoryItems = selectedCategory.menu;

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
                child: ListView.separated(
                  controller: _categoriesScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    return MenuCategoryCard(
                      title: category.name ?? "",
                      selected: provider.selectedCategoryIndex == index,
                      imageUrl: category.imageUrl,
                      onTap: () {
                        provider.changeCategory(index);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

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
                            allCategories: categories,
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

              const SizedBox(height: 4),

              // =========================
              // SELECTED CATEGORY ITEMS
              // =========================
              SizedBox(
                height: 200,
                child: Listener(
                  onPointerDown: _onItemsPointerDown,
                  onPointerMove: _onItemsPointerMove,
                  onPointerUp: (e) =>
                      _onItemsPointerUp(e, categories.length),
                  child: ListView.separated(
                    controller: _itemsScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: selectedCategoryItems.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final food = selectedCategoryItems[index];

                      return FoodItemCard(
                        food: food,
                        categoryImageUrl: selectedCategory.imageUrl,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // =========================
              // SPECIAL DEALS
              // =========================
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

                const SizedBox(height: 4),

                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: specialDeals.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
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

                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SKELETON HOME
  // ============================================================
  Widget _buildSkeleton() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Skeletonizer(
          enabled: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Bone.circle(size: 45),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Bone.text(
                            words: 2,
                            fontSize: 13,
                          ),
                          SizedBox(height: 6),
                          Bone.text(
                            words: 3,
                            fontSize: 11,
                          ),
                        ],
                      ),
                    ),
                    const Bone.circle(size: 40),
                  ],
                ),

                const SizedBox(height: 22),

                const Bone.text(
                  words: 1,
                  fontSize: 22,
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, index) {
                      return Container(
                        width: 85,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Bone.circle(size: 48),
                            SizedBox(height: 9),
                            Bone.text(
                              words: 1,
                              fontSize: 11,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: const [
                    Expanded(
                      child: Bone.text(
                        words: 2,
                        fontSize: 19,
                      ),
                    ),
                    Bone.text(
                      words: 1,
                      fontSize: 13,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 185,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, index) {
                      return _foodCardSkeleton();
                    },
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: const [
                    Expanded(
                      child: Bone.text(
                        words: 2,
                        fontSize: 19,
                      ),
                    ),
                    Bone.text(
                      words: 1,
                      fontSize: 13,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 185,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, index) {
                      return _foodCardSkeleton();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _foodCardSkeleton() {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Bone(
            width: double.infinity,
            height: 95,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          const SizedBox(height: 8),
          const Bone.text(
            words: 2,
            fontSize: 12,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Bone.text(
                words: 1,
                fontSize: 12,
              ),
              Bone.circle(size: 28),
            ],
          ),
        ],
      ),
    );
  }
}