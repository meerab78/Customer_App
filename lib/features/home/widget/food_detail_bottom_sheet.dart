import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/page_transitions.dart' show PageTransitions;
import '../model/menu_model.dart';
import '../variation_view.dart';
import '../../cart/controller.dart';
import '../../../core/theme/app_colors.dart';
import 'food_detail_content.dart';

void showFoodDetailBottomSheet(
    BuildContext context,
    Menu food,
    ) {
  int quantity = 1;

  final bool hasCustomization =
      food.menuVariations.isNotEmpty ||
          food.choiceGroup.isNotEmpty;

  MenuVariation? selectedVariation;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setState) {
          final double basePrice = double.tryParse(food.price ?? '0') ?? 0;

          final double variationExtra = selectedVariation != null
              ? double.tryParse(selectedVariation!.price ?? '0') ?? 0
              : 0;

          double choicesExtra = 0;
          if (selectedVariation != null) {
            for (final group in selectedVariation!.choiceGroups) {
              for (final choice in group.choices) {
                choicesExtra += double.tryParse(choice.price ?? '0') ?? 0;
              }
            }
          }

          final double selectedPrice = basePrice + variationExtra + choicesExtra;
          final double total = selectedPrice * quantity;
          return Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 3,
                  sigmaY: 3,
                ),
                child: Container(
                  color: AppColors.black.withOpacity(.10),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight:
                    MediaQuery.of(sheetContext).size.height * .72,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),

                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.grey300,
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          10,
                          16,
                          4,
                        ),
                        child: Row(
                          children: [
                            const Spacer(),

                            InkWell(
                              onTap: () {
                                Navigator.pop(sheetContext);
                              },
                              borderRadius:
                              BorderRadius.circular(50),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.grey100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Flexible(
                        child: SingleChildScrollView(
                          physics:
                          const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            4,
                            20,
                            18,
                          ),
                          child:  FoodDetailContent(
                            food: selectedVariation != null
                                ? food.copyWith(
                              menuVariation: selectedVariation,
                              takeAwayPrice:
                              selectedVariation!.takeAwayPrice ??
                                  food.takeAwayPrice,
                              deliveryPrice:
                              selectedVariation!.deliveryPrice ??
                                  food.deliveryPrice,
                            )
                                : food,
                            quantity: quantity,
                            total: total,
                            isAddEnabled:
                            !hasCustomization ||
                                selectedVariation != null,
                            onQuantityChanged: (value) {
                              setState(() {
                                quantity = value;
                              });
                            },
                            onAddToCart: () async {
                              Menu selectedFood = food;

                              if (selectedVariation != null) {
                                selectedFood = food.copyWith(
                                  takeAwayPrice:
                                  selectedVariation!.takeAwayPrice ??
                                      food.takeAwayPrice,

                                  deliveryPrice:
                                  selectedVariation!.deliveryPrice ??
                                      food.deliveryPrice,

                                  menuVariation: selectedVariation,

                                  // IMPORTANT:
                                  // selected variation ke selected choices bhi preserve
                                  choiceGroup: selectedVariation!.choiceGroups,
                                );
                              }
                              await sheetContext
                                  .read<CartController>()
                                  .addToCart(
                                selectedFood,
                                quantity,
                              );

                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                            },
                          ),
                        ),
                      ),

                      if (hasCustomization)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            20,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: OutlinedButton(
                              onPressed: () async {
                                final variation = await Navigator.push<MenuVariation>(
                                  sheetContext,
                                  PageTransitions.slideFromRight<MenuVariation>(
                                    VariationView(food: food),
                                  ),
                                );
                                if (variation != null &&
                                    sheetContext.mounted) {
                                  setState(() {
                                    selectedVariation =
                                        variation;
                                  });
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.primary,
                                ),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    14,
                                  ),
                                ),
                              ),
                              child: Text(
                                selectedVariation == null
                                    ? 'Select Variation'
                                    : 'Change Variation',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}