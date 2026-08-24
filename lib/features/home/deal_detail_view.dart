
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';
import '../cart/controller.dart';
import 'model/menu_model.dart';
import 'widget/deal_item_card.dart';

class DealDetailView extends StatefulWidget {
  final Menu food;

  const DealDetailView({
    super.key,
    required this.food,
  });

  @override
  State<DealDetailView> createState() => _DealDetailViewState();
}

class _DealDetailViewState extends State<DealDetailView> {
  late List<Menu> dealItems;
  late List<bool> itemCompletion;

  @override
  void initState() {
    super.initState();

    dealItems = List<Menu>.from(
      widget.food.dealMenuDetails,
    );

    itemCompletion = List<bool>.filled(
      dealItems.length,
      false,
    );

    // Jis item mein customization nahi hai
    // wo already complete hai
    for (int i = 0; i < dealItems.length; i++) {
      final item = dealItems[i];

      final hasCustomization =
          item.menuVariations.isNotEmpty ||
              item.choiceGroup.isNotEmpty ||
              item.menuVariation != null;

      if (!hasCustomization) {
        itemCompletion[i] = true;
      }
    }
  }
// CHECK REQUIRED CUSTOMIZATIONS
  bool get isDealComplete {
    return itemCompletion.every(
          (completed) => completed,
    );
  }
//   bool get isDealComplete {
//     for (final item in dealItems) {
//       final groups = <ChoiceGroup>[];
//
//       // Direct choice groups
//       groups.addAll(item.choiceGroup);
//
//       // Selected variation ke choice groups
//       if (item.menuVariation != null) {
//         groups.addAll(
//           item.menuVariation!.choiceGroups,
//         );
//       }
//       // REQUIRED GROUP CHECK
//       for (final group in groups) {
//         final minChoices =
//             group.minChoices ?? 0;
//
//         if (minChoices == 0) {
//           continue;
//         }
//
//         final selectedChoices =
//             group.choices;
//
//         // min > 0
//         // means REQUIRED
//         if (selectedChoices.length <
//             minChoices) {
//           return false;
//         }
//       }
//     }
//
//     return true;
//   }

// CALCULATE FINAL DEAL PRICE

  double get totalDealPrice {
    double total = 0;
    for (final item in dealItems) {
      final itemPrice =
          double.tryParse(item.price ?? '0') ?? 0;
      final quantity = item.quantity ?? 1;
      total += itemPrice * quantity;
    }
    return total;
  }
// ADD DEAL TO CART
  Future<void> _addDealToCart() async {
    if (!isDealComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all required selections.',
          ),
        ),
      );

      return;
    }

    final finalPrice = totalDealPrice;

    final updatedDeal = widget.food.copyWith(
      isDeal: true,

      price: finalPrice.toString(),
      takeAwayPrice: finalPrice.toString(),
      deliveryPrice: finalPrice.toString(),

      dealMenuDetails: dealItems,

      menuVariation: null,
      choiceGroup: [],
    );

    await context.read<CartController>().addToCart(
      updatedDeal,
      1,
    );

    if (!mounted) return;

    // DEAL ADD HO GAYA
    // Ab Home screen par wapas jao
    Navigator.popUntil(
      context,
          (route) => route.isFirst,
    );
  }
  // Future<void> _addDealToCart() async {
  //   if (!isDealComplete) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text(
  //           'Please complete all required selections.',
  //         ),
  //       ),
  //     );
  //
  //     return;
  //   }
  //
  //   final finalPrice = totalDealPrice;
  //   // UPDATED DEAL
  //   final updatedDeal = widget.food.copyWith(
  //     isDeal: true,
  //
  //     price: finalPrice.toString(),
  //     takeAwayPrice: finalPrice.toString(),
  //     deliveryPrice: finalPrice.toString(),
  //
  //     // Deal ki customization yahan rahegi
  //     dealMenuDetails: dealItems,
  //
  //     // Deal ke liye variation nahi hoga
  //     menuVariation: null,
  //
  //     // Deal ke direct choices bhi nahi
  //     choiceGroup: [],
  //   );
  //   await context.read<CartController>().addToCart(
  //     updatedDeal,
  //     1,
  //   );
  //
  //   if (!mounted) return;
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         '${widget.food.name ?? 'Deal'} added to cart ✓',
  //       ),
  //       duration: const Duration(seconds: 2),
  //     ),
  //   );
  // }

  // ============================================================
  // UI-ONLY HELPER (purely derived from existing state, for
  // display in the progress header below — does not change
  // any add-to-cart / validation behaviour).
  // ============================================================
  int get _completedCount =>
      itemCompletion.where((completed) => completed).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      AppColors.background,

// APP BAR
      appBar: AppBar(
        backgroundColor:
        AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.textColor,
        ),

        title: Text(
          widget.food.name ??
              'Deal Details',
          style: getBoldStyle(
            fontSize: MyFonts.size21,
            color: AppColors.text,
          ),
        ),
      ),

// DEAL ITEMS
      body: dealItems.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 12),
            Text(
              'No items found in this deal',
              style: getRegularStyle(
                color:
                AppColors.greyText,
                fontSize:
                MyFonts.size15,
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [

          // PROGRESS HEADER (display only — reads existing
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16, 4, 16, 12,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.borderColorGrey,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.softShadow05,
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.tertiary
                              .withOpacity(0.15),
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.local_offer_rounded,
                          color: AppColors.tertiary,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customize your deal',
                              style: getBoldStyle(
                                fontSize: MyFonts.size14,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$_completedCount of ${dealItems.length} items ready',
                              style: getRegularStyle(
                                fontSize: MyFonts.size12,
                                color: AppColors.greyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rs ${totalDealPrice.toStringAsFixed(0)}',
                        style: getExtraBoldStyle(
                          fontSize: MyFonts.size16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: dealItems.isEmpty
                          ? 0
                          : _completedCount /
                          dealItems.length,
                      minHeight: 6,
                      backgroundColor: AppColors.grey200,
                      valueColor: AlwaysStoppedAnimation(
                        isDealComplete
                            ? AppColors.success
                            : AppColors.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding:
              const EdgeInsets.fromLTRB(
                16, 0, 16, 16,
              ),

              itemCount:
              dealItems.length,

              itemBuilder:
                  (context, index) {
                final item =
                dealItems[index];

                return DealItemCard(
                  key: ValueKey(
                    '${item.id}_$index',
                  ),

                  item: item,

                  onItemUpdated:
                      (updatedItem) {
                    setState(() {
                      dealItems[index] =
                          updatedItem;
                    });
                  },

                  onCompletionChanged:
                      (completed) {
                    setState(() {
                      itemCompletion[index] =
                          completed;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
// ADD DEAL BUTTON


      bottomNavigationBar: dealItems.isEmpty
          ? null
          : Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.softShadow07,
              blurRadius: 18,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              14,
              16,
              14,
            ),

            child: SizedBox(
              height: 58,
              width: double.infinity,

              child: ElevatedButton(
                onPressed:
                isDealComplete
                    ? _addDealToCart
                    : null,

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  AppColors.primary,

                  disabledBackgroundColor:
                  AppColors.grey300,

                  foregroundColor:
                  AppColors.white,

                  elevation: 0,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                  ),
                ),

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      isDealComplete
                          ? Icons.shopping_bag_rounded
                          : Icons.error_outline_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Text(
                          isDealComplete
                              ? 'Add Deal to Cart'
                              : 'Complete Required Selections',

                          style:
                          getExtraBoldStyle(
                            fontSize:
                            MyFonts.size14,
                            color:
                            AppColors.white,
                          ),
                        ),

                        const SizedBox(
                          height: 2,
                        ),

                        Text(
                          'Rs ${totalDealPrice.toStringAsFixed(0)}',

                          style:
                          getBoldStyle(
                            fontSize:
                            MyFonts.size13,
                            color:
                            AppColors.white
                                .withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}