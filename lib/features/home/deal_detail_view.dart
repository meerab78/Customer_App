
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

    dealItems = List<Menu>.from(widget.food.dealMenuDetails);
    itemCompletion = List<bool>.filled(dealItems.length, false);

    for (int i = 0; i < dealItems.length; i++) {
      final item = dealItems[i];
      final hasCustomization = item.menuVariations.isNotEmpty ||
          item.choiceGroup.isNotEmpty ||
          item.menuVariation != null;

      if (!hasCustomization) {
        itemCompletion[i] = true;
      }
    }
  }

  bool get isDealComplete {
    return itemCompletion.every((completed) => completed);
  }

  double get totalDealPrice {
    final basePrice = double.tryParse(widget.food.price ?? '0') ?? 0;
    double extra = 0;

    for (final item in dealItems) {
      for (final group in item.choiceGroup) {
        for (final choice in group.choices) {
          extra += double.tryParse(choice.price ?? '0') ?? 0;
        }
      }
      if (item.menuVariation != null) {
        for (final group in item.menuVariation!.choiceGroups) {
          for (final choice in group.choices) {
            extra += double.tryParse(choice.price ?? '0') ?? 0;
          }
        }
      }
    }

    return basePrice + extra;
  }

  Future<void> _addDealToCart() async {
    if (!isDealComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required selections.'),
        ),
      );
      return;
    }

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

    await context.read<CartController>().addToCart(updatedDeal, 1);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${widget.food.name ?? 'Item'} added to cart',
                style: getMediumStyle(
                  fontSize: MyFonts.size14,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Dish Detail',
          style: getBoldStyle(
            fontSize: MyFonts.size18,
            color: AppColors.primary,
          ),
        ),
      ),
      body: dealItems.isEmpty
          ? Center(
        child: Text(
          'No items found in this deal',
          style: getRegularStyle(
            color: AppColors.greyText,
            fontSize: MyFonts.size15,
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.food.imageUrl != null &&
                widget.food.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.food.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.food.name ?? 'Deal Items',
                style: getExtraBoldStyle(
                  fontSize: MyFonts.size18,
                  color: AppColors.text,
                ),
              ),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dealItems.length,
              itemBuilder: (context, index) {
                return DealItemCard(
                  key: ValueKey('${dealItems[index].id}_$index'),
                  item: dealItems[index],
                  onItemUpdated: (updatedItem) {
                    setState(() {
                      dealItems[index] = updatedItem;
                    });
                  },
                  onCompletionChanged: (completed) {
                    setState(() {
                      itemCompletion[index] = completed;
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: dealItems.isEmpty
          ? null
          : Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          boxShadow: [
            BoxShadow(
              color: AppColors.softShadow07,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total:',
                    style: getRegularStyle(
                      fontSize: MyFonts.size12,
                      color: AppColors.greyText,
                    ),
                  ),
                  Text(
                    'PKR ${totalDealPrice.toStringAsFixed(2)}',
                    style: getExtraBoldStyle(
                      fontSize: MyFonts.size16,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: isDealComplete ? _addDealToCart : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.grey300,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(
                    isDealComplete
                        ? 'Add to Cart'
                        : 'Complete Selection',
                    style: getBoldStyle(
                      fontSize: MyFonts.size14,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}