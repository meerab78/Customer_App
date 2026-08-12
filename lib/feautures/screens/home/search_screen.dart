import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/provider/home_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/food_item_card.dart';
import '../../widgets/food_detail_bottom_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

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
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
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
                    hintStyle: TextStyle(
                      color: AppColors.greyText,
                      fontSize: 14,
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
                    name: food.name ?? '',
                    description: food.description ?? '',
                    price: food.price ?? '0',
                    imageUrl: food.imageUrl ?? '',
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
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Search for delicious food and discover\nsomething you love.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.greyText,
                height: 1.4,
              ),
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
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'We couldn\'t find anything for "$query"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}