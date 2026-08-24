
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_paddings.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';
import 'model/menu_model.dart';
import 'widget/variation_selector.dart';
class VariationView extends StatefulWidget {
  final Menu food;
  final bool isEditMode;


  const VariationView({
    super.key,
    required this.food,
    this.isEditMode = false,
  });

  @override
  State<VariationView> createState() => _VariationViewState();
}

class _VariationViewState extends State<VariationView> {
  MenuVariation? selectedVariation;

  // ChoiceGroup ID -> selected choices
  final Map<int, List<MenuVariation>> selectedChoices = {};

  @override
  void initState() {
    super.initState();
    // Existing selections SIRF edit mode mein load hongi.
    if (widget.isEditMode) {
      _initializeExistingSelection();
    }
  }
  // INITIALIZE EXISTING SELECTION

  void _initializeExistingSelection() {
    // FIND EXISTING SELECTED VARIATION
    if (widget.food.menuVariation != null) {
      final existingVariation =
      widget.food.menuVariation!;

      for (final variation
      in widget.food.menuVariations) {
        if (variation.id == existingVariation.id) {
          selectedVariation = variation;
          break;
        }
      }

      // Fallback
      selectedVariation ??= existingVariation;
    }
    // DIRECT SELECTED CHOICES


    _initializeChoices(
      widget.food.choiceGroup,
    );
    // EXISTING SELECTED VARIATION CHOICES
    if (widget.food.menuVariation != null) {
      _initializeChoices(
        widget.food.menuVariation!.choiceGroups,
      );
    }
  }

  // INITIALIZE CHOICES
  void _initializeChoices(
      List<ChoiceGroup> groups,
      ) {
    for (final group in groups) {
      final groupId = group.id;

      if (groupId == null) {
        continue;
      }

      // Existing selected choices
      final existingChoices = group.choices;

      if (existingChoices.isEmpty) {
        continue;
      }

      final current =
      List<MenuVariation>.from(
        selectedChoices[groupId] ?? [],
      );

      for (final choice in existingChoices) {
        final alreadyExists = current.any(
              (item) => item.id == choice.id,
        );

        if (!alreadyExists) {
          current.add(choice);
        }
      }

      selectedChoices[groupId] = current;
    }
  }
  // CHOICE GROUPS
  List<ChoiceGroup> get choiceGroups {
    final groups = <ChoiceGroup>[];

    // DIRECT CHOICE GROUPS
    // ==========================================================

    groups.addAll(widget.food.choiceGroup);

    // ==========================================================
    // CURRENT SELECTED VARIATION KE AVAILABLE GROUPS
    // ==========================================================

    if (selectedVariation != null) {
      for (final variation in widget.food.menuVariations) {
        if (variation.id != selectedVariation!.id) {
          continue;
        }
        for (final variationGroup
        in variation.choiceGroups) {
          final existingIndex = groups.indexWhere(
                (group) => group.id == variationGroup.id,
          );

          if (existingIndex == -1) {
            groups.add(variationGroup);
          }
        }
      }
    }
    return groups;
  }
  // FINAL PRICE
  double get selectedPrice {
    final basePrice =
        double.tryParse(widget.food.price ?? '0') ?? 0;

    double variationPrice = 0;

    if (selectedVariation != null) {
      variationPrice =
          double.tryParse(
            selectedVariation!.price ?? '0',
          ) ??
              0;
    }

    double choicesPrice = 0;

    for (final choices in selectedChoices.values) {
      for (final choice in choices) {
        choicesPrice +=
            double.tryParse(
              choice.price ?? '0',
            ) ??
                0;
      }
    }

    final total =
        basePrice +
            variationPrice +
            choicesPrice;

    debugPrint(
      '========== VARIATION VIEW PRICE ==========',
    );
    debugPrint('Food: ${widget.food.name}');
    debugPrint('Food Base Price: $basePrice');
    debugPrint(
      'Selected Variation: ${selectedVariation?.name}',
    );
    debugPrint(
      'Selected Variation Price: $variationPrice',
    );
    debugPrint('Choices Price: $choicesPrice');
    debugPrint('TOTAL: $total');
    debugPrint(
      '==========================================',
    );
    return total;
  }
  // VALIDATION

  bool get isSelectionValid {
    // Main variation required
    if (widget.food.menuVariations.isNotEmpty &&
        selectedVariation == null) {
      return false;
    }

    // Choice groups validation
    for (final group in choiceGroups) {
      final groupId = group.id;

      if (groupId == null) {
        continue;
      }

      final selectedCount =
          selectedChoices[groupId]?.length ?? 0;

      final minChoices =
          group.minChoices ?? 0;

      final maxChoices =
          group.maxChoices ?? 0;

      // Required
      if (selectedCount < minChoices) {
        return false;
      }

      // Maximum
      if (maxChoices > 0 &&
          selectedCount > maxChoices) {
        return false;
      }
    }

    return true;
  }
  // SELECT MAIN VARIATION
  void _selectVariation(
      MenuVariation variation,
      ) {
    setState(() {
      selectedVariation = variation;

      // Direct choices ko preserve karo.
      final directGroupIds = widget.food.choiceGroup
          .map((group) => group.id)
          .whereType<int>()
          .toSet();

      selectedChoices.removeWhere(
            (groupId, choices) =>
        !directGroupIds.contains(groupId),
      );
    });
  }

  // SELECT / UNSELECT CHOICE

  void _toggleChoice(
      ChoiceGroup group,
      MenuVariation choice,
      ) {
    final groupId = group.id;

    if (groupId == null) {
      return;
    }

    final selected =
    List<MenuVariation>.from(
      selectedChoices[groupId] ?? [],
    );

    final alreadySelected = selected.any(
          (item) => item.id == choice.id,
    );

    if (alreadySelected) {
      selected.removeWhere(
            (item) => item.id == choice.id,
      );
    } else {
      final maxChoices =
          group.maxChoices ?? 0;

      if (maxChoices > 0 &&
          selected.length >= maxChoices) {
        return;
      }

      selected.add(choice);
    }

    setState(() {
      selectedChoices[groupId] = selected;
    });
  }

  // ============================================================
  // ADD / UPDATE
  // ============================================================

  void _addToCart() {
    if (!isSelectionValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.logoColor2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
          content: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.white,
                size: 20,
              ),
              padding10,
              Expanded(
                child: Text(
                  'Please complete the required selections.',
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

      return;
    }

    // ----------------------------------------------------------
    // BUILD SELECTED GROUPS
    // ----------------------------------------------------------

    final selectedGroups = choiceGroups
        .where(
          (group) =>
      selectedChoices[group.id]?.isNotEmpty ?? false,
    )
        .map((group) {
      final selected =
          selectedChoices[group.id] ?? [];

      return group.copyWith(
        choices: selected,
      );
    })
        .toList();

    // MAIN VARIATION SELECTED

    if (selectedVariation != null) {
      final variation =
      selectedVariation!.copyWith(
        choiceGroups: selectedGroups,
      );
      Navigator.pop(
        context,
        variation,
      );
      return;
    }
    // ONLY CHOICE GROUPS

    final variation = MenuVariation(
      id: null,
      name: widget.food.name,
      price: '0',
      takeAwayPrice:
      widget.food.takeAwayPrice,
      deliveryPrice:
      widget.food.deliveryPrice,
      choiceGroups: selectedGroups,
    );

    Navigator.pop(
      context,
      variation,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ==========================================================
      // APP BAR — brand navy, gold-accent back button
      // ==========================================================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.appBarColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.softShadow08,
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.food.name ?? 'Customize',
                      overflow: TextOverflow.ellipsis,
                      style: getExtraBoldStyle(
                        fontSize: MyFonts.size18,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  padding16,
                ],
              ),
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16, 16, 16, 24,
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // FOOD SUMMARY CARD
                  // ------------------------------------------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius:
                      BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.borderColorGrey,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.softShadow05,
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.tertiary
                                .withOpacity(0.15),
                            borderRadius:
                            BorderRadius.circular(13),
                          ),
                          child: Icon(
                            Icons.restaurant_menu_rounded,
                            color: AppColors.tertiary,
                            size: 22,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.food.name ?? '',
                                style: getExtraBoldStyle(
                                  fontSize: MyFonts.size16,
                                  color: AppColors.textColor,
                                ),
                              ),
                              padding4,
                              Text(
                                'Make it yours',
                                style: getRegularStyle(
                                  fontSize: MyFonts.size12,
                                  color: AppColors.greyText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tertiary
                                .withOpacity(0.12),
                            borderRadius:
                            BorderRadius.circular(24),
                          ),
                          child: Text(
                            'Rs ${selectedPrice.toStringAsFixed(0)}',
                            style: getExtraBoldStyle(
                              fontSize: MyFonts.size14,
                              color: AppColors.tertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  padding20,

                  // ------------------------------------------------
                  // Section label
                  // ------------------------------------------------
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 4, bottom: 10,
                    ),
                    child: Text(
                      'CUSTOMIZE',
                      style: getExtraBoldStyle(
                        fontSize: MyFonts.size12,
                        color: AppColors.greyText,
                      ).copyWith(letterSpacing: 1.2),
                    ),
                  ),

                  // ------------------------------------------------
                  // VARIATION SELECTOR (logic untouched)
                  // ------------------------------------------------
                  VariationSelector(
                    // IMPORTANT:
                    // FULL variations list pass hogi.
                    //
                    // Sirf selected variation nahi.
                    variations:
                    widget.food.menuVariations,

                    // Full available choice groups
                    choiceGroups:
                    choiceGroups,

                    // Existing selected variation
                    selectedVariation:
                    selectedVariation,

                    // Existing selected choices
                    selectedChoices:
                    selectedChoices,

                    onVariationSelected:
                    _selectVariation,

                    onChoiceSelected:
                    _toggleChoice,
                  ),

                  // Extra bottom breathing room so content
                  // never hides behind the sticky button bar.
                  padding12,
                ],
              ),
            ),
          ),

          // ====================================================
          // DONE / UPDATE BUTTON (sticky bottom bar)
          // ====================================================

          Container(
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
                  16,
                  16,
                  14,
                ),

                child: SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton(
                    onPressed:
                    isSelectionValid
                        ? _addToCart
                        : null,

                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.btnColor,
                      disabledBackgroundColor:
                      AppColors.grey300,
                      foregroundColor:
                      AppColors.btnTextColorWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Text(
                          isSelectionValid
                              ? (widget.isEditMode
                              ? 'Update Item'
                              : 'Add to Cart')
                              : 'Complete Required Selection',
                          style: getExtraBoldStyle(
                            fontSize: MyFonts.size16,
                            color: isSelectionValid
                                ? AppColors.btnTextColorWhite
                                : AppColors.grey500,
                          ),
                        ),
                        if (isSelectionValid) ...[
                          padding10,
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white
                                  .withOpacity(0.2),
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Rs ${selectedPrice.toStringAsFixed(0)}',
                              style: getExtraBoldStyle(
                                fontSize: MyFonts.size14,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}