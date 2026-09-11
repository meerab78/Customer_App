
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';
import '../../core/utils/order_type_price.dart';
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

  double get totalDealPrice {
    final basePrice = double.tryParse(widget.food.price ?? '0') ?? 0;
    double extra = 0;

    for (final item in dealItems) {
      // Direct choices
      for (final group in item.choiceGroup) {
        for (final choice in group.choices) {
          extra += double.tryParse(choice.price ?? '0') ?? 0;
        }
      }
      // Variation ke andar wali NESTED choices — pehle yeh miss ho rahi thi
      if (item.menuVariation != null) {
        for (final group in item.menuVariation!.choiceGroups) {
          for (final choice in group.choices) {
            extra += double.tryParse(choice.price ?? '0') ?? 0;
          }
        }
      }
      // NOTE: item.menuVariation!.price yahan JAAN-BUJH KAR add nahi ki —
      // deal ki fixed price mein variation ki apni base cost shamil hai.
    }

    return basePrice + extra;
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

    final orderType = context.read<CartController>().orderType;

    double totalDealPriceFor(String type) {
      final basePrice = pickOrderTypePrice(
        orderType: type,
        dinePrice: widget.food.price,
        takeawayPrice: widget.food.takeAwayPrice,
        deliveryPrice: widget.food.deliveryPrice,
      );

      double extra = 0;
      for (final item in dealItems) {
        for (final group in item.choiceGroup) {
          for (final choice in group.choices) {
            extra += pickOrderTypePrice(
              orderType: type,
              dinePrice: choice.price,
              takeawayPrice: choice.takeAwayPrice,
              deliveryPrice: choice.deliveryPrice,
            );
          }
        }
        if (item.menuVariation != null) {
          for (final group in item.menuVariation!.choiceGroups) {
            for (final choice in group.choices) {
              extra += pickOrderTypePrice(
                orderType: type,
                dinePrice: choice.price,
                takeawayPrice: choice.takeAwayPrice,
                deliveryPrice: choice.deliveryPrice,
              );
            }
          }
        }
      }
      return basePrice + extra;
    }

    final updatedDeal = widget.food.copyWith(
      isDeal: true,
      price: totalDealPriceFor('DineIn').toString(),
      takeAwayPrice: totalDealPriceFor('Takeaway').toString(),
      deliveryPrice: totalDealPriceFor('Delivery').toString(),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
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
                    debugPrint('BEFORE total: $totalDealPrice');
                    setState(() {
                      dealItems[index] =
                          updatedItem;
                    });
                    debugPrint('AFTER total: $totalDealPrice');
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