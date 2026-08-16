
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

  @override
  void initState() {
    super.initState();

    dealItems = List<Menu>.from(
      widget.food.dealMenuDetails,
    );
  }
// CHECK REQUIRED CUSTOMIZATIONS
  bool get isDealComplete {
    for (final item in dealItems) {
      final groups = <ChoiceGroup>[];

      // Direct choice groups
      groups.addAll(item.choiceGroup);

      // Selected variation ke choice groups
      if (item.menuVariation != null) {
        groups.addAll(
          item.menuVariation!.choiceGroups,
        );
      }
      // REQUIRED GROUP CHECK
      for (final group in groups) {
        final minChoices =
            group.minChoices ?? 0;

        if (minChoices == 0) {
          continue;
        }

        final selectedChoices =
            group.choices;

        // min > 0
        // means REQUIRED
        if (selectedChoices.length <
            minChoices) {
          return false;
        }
      }
    }

    return true;
  }

// CALCULATE FINAL DEAL PRICE

  double get totalDealPrice {
    double total = 0;

    for (final item in dealItems) {
      final itemPrice =
          double.tryParse(
            item.price ?? '0',
          ) ??
              0;

      final quantity =
          item.quantity ?? 1;

      total += itemPrice * quantity;
    }

    return total;
  }
// ADD DEAL TO CART

  Future<void> _addDealToCart() async {
// Safety check
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

    final updatedDeal = widget.food.copyWith(
      dealMenuDetails: dealItems,

// Save final deal price
      price: totalDealPrice.toString(),
    );

    await context
        .read<CartController>()
        .addToCart(
      updatedDeal,
      1,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.food.name ?? 'Deal'} added to cart ✓',
        ),
        duration:
        const Duration(seconds: 2),
      ),
    );
  }

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
        child: Text(
          'No items found in this deal',
          style: getRegularStyle(
            color:
            AppColors.greyText,
            fontSize:
            MyFonts.size15,
          ),
        ),
      )
          : ListView.builder(
        padding:
        const EdgeInsets.all(16),

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
          );
        },
      ),
// ADD DEAL BUTTON


      bottomNavigationBar:
      SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            16,
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

              child: Column(
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
                      AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
