//
// import 'package:flutter/material.dart';
// import 'model/menu_model.dart';
// import '../../core/theme/app_colors.dart';
// import '../../core/theme/fonts_manager.dart';
// import '../../core/theme/textfont_styles.dart';
// import 'widget/food_detail_bottom_sheet.dart';
// import 'widget/food_item_card.dart';
//
// class CategoryItemsView extends StatelessWidget {
//   final RestaurantBranchMenu category;
//
//   const CategoryItemsView({
//     super.key,
//     required this.category,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final items = category.menu;
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         centerTitle: false,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: Text(
//           category.name ?? "Items",
//           style: getBoldStyle(
//             fontSize: MyFonts.size21,
//             color: AppColors.text,
//           ),
//         ),
//       ),
//
//       body: items.isEmpty
//           ? Center(
//         child: Text(
//           "No items available",
//           style: getRegularStyle(
//             color: AppColors.greyText,
//             fontSize: MyFonts.size15,
//           ),
//         ),
//       )
//           : GridView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         itemCount: items.length,
//
//         gridDelegate:
//         const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 12,
//           mainAxisSpacing: 12,
//           childAspectRatio: 0.94, // Fixed: Spikes compact height to remove bottom gap
//         ),
//
//         itemBuilder: (context, index) {
//           final food = items[index];
//
//           return FoodItemCard(
//             food: food,
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller.dart';
import 'model/menu_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';
import 'widget/food_item_card.dart';

class CategoryItemsView extends StatefulWidget {
  final RestaurantBranchMenu category;
  final List<RestaurantBranchMenu>? allCategories;

  const CategoryItemsView({
    super.key,
    required this.category,
    this.allCategories,
  });

  @override
  State<CategoryItemsView> createState() => _CategoryItemsViewState();
}

class _CategoryItemsViewState extends State<CategoryItemsView> {
  final ScrollController _scrollController = ScrollController();

  List<RestaurantBranchMenu> _categories = [];
  List<GlobalKey> _sectionKeys = [];

  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_updateCurrentCategory);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_categories.isNotEmpty) {
      return;
    }

    _categories = _getCategories();

    _sectionKeys = List.generate(
      _categories.length,
          (index) => GlobalKey(),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateCurrentCategory);
    _scrollController.dispose();
    _currentIndex.dispose();

    super.dispose();
  }

  List<RestaurantBranchMenu> _getCategories() {
    List<RestaurantBranchMenu>? categories = widget.allCategories;

    if (categories == null || categories.isEmpty) {
      categories = context
          .read<HomeController>()
          .menuModel
          ?.data
          ?.restaurantBranchMenu;
    }

    final availableCategories = (categories ?? [])
        .where((category) => category.menu.isNotEmpty)
        .toList();

    if (availableCategories.isEmpty) {
      return [widget.category];
    }

    int startIndex = availableCategories.indexOf(widget.category);

    if (startIndex == -1) {
      startIndex = availableCategories.indexWhere(
            (category) => category.name == widget.category.name,
      );
    }

    if (startIndex == -1) {
      startIndex = 0;
    }

    return [
      ...availableCategories.sublist(startIndex),
      ...availableCategories.sublist(0, startIndex),
    ];
  }

  void _updateCurrentCategory() {
    if (_categories.isEmpty || !_scrollController.hasClients) {
      return;
    }

    final topPosition =
        MediaQuery.of(context).padding.top + kToolbarHeight + 4;

    int newIndex = _currentIndex.value;

    for (int i = 0; i < _sectionKeys.length; i++) {
      final sectionContext = _sectionKeys[i].currentContext;

      if (sectionContext == null) {
        continue;
      }

      final box = sectionContext.findRenderObject() as RenderBox?;

      if (box == null || !box.attached) {
        continue;
      }

      final position = box.localToGlobal(Offset.zero).dy;

      if (position <= topPosition) {
        newIndex = i;
      }
    }

    if (newIndex != _currentIndex.value) {
      _currentIndex.value = newIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = _categories.any(
          (category) => category.menu.isNotEmpty,
    );

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
        title: ValueListenableBuilder<int>(
          valueListenable: _currentIndex,
          builder: (context, index, child) {
            String title = widget.category.name ?? "Items";

            if (_categories.isNotEmpty &&
                index < _categories.length) {
              title = _categories[index].name ?? "Items";
            }

            return Text(
              title,
              style: getBoldStyle(
                fontSize: MyFonts.size21,
                color: AppColors.text,
              ),
            );
          },
        ),
      ),
      body: !hasItems
          ? Center(
        child: Text(
          "No items available",
          style: getRegularStyle(
            color: AppColors.greyText,
            fontSize: MyFonts.size15,
          ),
        ),
      )
          : ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return _buildCategorySection(
            _categories[index],
            index,
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(
      RestaurantBranchMenu category,
      int index,
      ) {
    return Container(
      key: _sectionKeys[index],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              index == 0 ? 0 : 20,
              16,
              8,
            ),
            child: Text(
              category.name ?? "Items",
              style: getBoldStyle(
                fontSize: MyFonts.size19,
                color: AppColors.text,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: category.menu.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 200,
            ),
            itemBuilder: (context, index) {
              return FoodItemCard(
                food: category.menu[index],
                categoryImageUrl: category.imageUrl,
              );
            },
          ),
        ],
      ),
    );
  }
}

