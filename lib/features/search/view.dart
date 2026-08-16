import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home/controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';
import '../home/widget/food_item_card.dart';
import '../home/widget/food_detail_bottom_sheet.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeController>();

    final query = _searchController.text.trim().toLowerCase();

    final items = provider.menuModel?.data?.restaurantBranchMenu
        .expand((category) => category.menu)
        .where(
          (food) => (food.name ?? '').toLowerCase().contains(query),
    )
        .toList() ??
        [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
              child: Text(
                'Search Food',
                style: getExtraBoldStyle(
                  fontSize: MyFonts.size26,
                  color: AppColors.text,
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.softShadow05,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search burgers, pizza, drinks...',
                    hintStyle: getRegularStyle(
                      color: AppColors.greyText,
                      fontSize: MyFonts.size14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 25,
                    ),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 17,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Results
            Expanded(
              child: query.isEmpty
                  ? _emptySearch()
                  : items.isEmpty
                  ? _noResults(query)
                  : GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  0,
                  18,
                  20,
                ),
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: items.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                  childAspectRatio: .72,
                ),
                itemBuilder: (context, index) {
                  final food = items[index];

                  return FoodItemCard(
                    food: food,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptySearch() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                size: 45,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Find your favourite food',
              style: getBoldStyle(
                fontSize: MyFonts.size19,
                color: AppColors.text,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Search for delicious food and discover\nsomething you love.',
              textAlign: TextAlign.center,
              style: getRegularStyle(
                fontSize: MyFonts.size13,
                color: AppColors.greyText,
              ).copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noResults(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fastfood_outlined,
              size: 55,
              color: AppColors.greyText,
            ),

            const SizedBox(height: 14),

            Text(
              'No food found',
              style: getBoldStyle(
                fontSize: MyFonts.size19,
                color: AppColors.text,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'We couldn\'t find anything for "$query"',
              textAlign: TextAlign.center,
              style: getRegularStyle(
                fontSize: MyFonts.size13,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

