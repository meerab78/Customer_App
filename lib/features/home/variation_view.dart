

import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext;

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_paddings.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';
import '../../core/utils/order_type_price.dart';
import '../cart/controller.dart';
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
    if (widget.isEditMode) {
      _initializeExistingSelection();
    }
  }

  void _initializeExistingSelection() {
    if (widget.food.menuVariation != null) {
      final existingVariation = widget.food.menuVariation!;

      for (final variation in widget.food.menuVariations) {
        if (variation.id == existingVariation.id) {
          selectedVariation = variation;
          break;
        }
      }
      selectedVariation ??= existingVariation;
    }

    _initializeChoices(widget.food.choiceGroup);

    if (widget.food.menuVariation != null) {
      _initializeChoices(widget.food.menuVariation!.choiceGroups);
    }
  }

  void _initializeChoices(List<ChoiceGroup> groups) {
    for (final group in groups) {
      final groupId = group.id;
      if (groupId == null) continue;

      final existingChoices = group.choices;
      if (existingChoices.isEmpty) continue;

      final current = List<MenuVariation>.from(selectedChoices[groupId] ?? []);

      for (final choice in existingChoices) {
        final alreadyExists = current.any((item) => item.id == choice.id);
        if (!alreadyExists) {
          current.add(choice);
        }
      }

      selectedChoices[groupId] = current;
    }
  }

  List<ChoiceGroup> get choiceGroups {
    final groups = <ChoiceGroup>[];
    groups.addAll(widget.food.choiceGroup);

    if (selectedVariation != null) {
      for (final variation in widget.food.menuVariations) {
        if (variation.id != selectedVariation!.id) continue;
        for (final variationGroup in variation.choiceGroups) {
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

  double get selectedPrice {
    final orderType = context.read<CartController>().orderType;
    double total;

    if (selectedVariation != null) {
      total = pickOrderTypePrice(
        orderType: orderType,
        dinePrice: selectedVariation!.price,
        takeawayPrice: selectedVariation!.takeAwayPrice,
        deliveryPrice: selectedVariation!.deliveryPrice,
      );
    } else {
      total = pickOrderTypePrice(
        orderType: orderType,
        dinePrice: widget.food.price,
        takeawayPrice: widget.food.takeAwayPrice,
        deliveryPrice: widget.food.deliveryPrice,
      );
    }

    for (final choices in selectedChoices.values) {
      for (final choice in choices) {
        total += pickOrderTypePrice(
          orderType: orderType,
          dinePrice: choice.price,
          takeawayPrice: choice.takeAwayPrice,
          deliveryPrice: choice.deliveryPrice,
        );
      }
    }
    return total;
  }

  bool get isSelectionValid {
    if (widget.food.menuVariations.isNotEmpty && selectedVariation == null) {
      return false;
    }

    for (final group in choiceGroups) {
      final groupId = group.id;
      if (groupId == null) continue;

      final selectedCount = selectedChoices[groupId]?.length ?? 0;
      final minChoices = group.minChoices ?? 0;
      final maxChoices = group.maxChoices ?? 0;

      if (selectedCount < minChoices) return false;
      if (maxChoices > 0 && selectedCount > maxChoices) return false;
    }

    return true;
  }

  void _selectVariation(MenuVariation variation) {
    setState(() {
      selectedVariation = variation;

      final directGroupIds = widget.food.choiceGroup
          .map((group) => group.id)
          .whereType<int>()
          .toSet();

      selectedChoices.removeWhere(
            (groupId, choices) => !directGroupIds.contains(groupId),
      );
    });
  }

  void _toggleChoice(ChoiceGroup group, MenuVariation choice) {
    final groupId = group.id;
    if (groupId == null) return;

    final selected = List<MenuVariation>.from(selectedChoices[groupId] ?? []);
    final alreadySelected = selected.any((item) => item.id == choice.id);

    if (alreadySelected) {
      selected.removeWhere((item) => item.id == choice.id);
    } else {
      final maxChoices = group.maxChoices ?? 0;
      if (maxChoices > 0 && selected.length >= maxChoices) return;
      selected.add(choice);
    }

    setState(() {
      selectedChoices[groupId] = selected;
    });
  }

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

    final selectedGroups = choiceGroups
        .where((group) => selectedChoices[group.id]?.isNotEmpty ?? false)
        .map((group) {
      final selected = selectedChoices[group.id] ?? [];
      return group.copyWith(choices: selected);
    }).toList();

    if (selectedVariation != null) {
      final variation = selectedVariation!.copyWith(
        choiceGroups: selectedGroups,
      );
      Navigator.pop(context, variation);
      return;
    }

    final variation = MenuVariation(
      id: null,
      name: widget.food.name,
      price: '0',
      takeAwayPrice: widget.food.takeAwayPrice,
      deliveryPrice: widget.food.deliveryPrice,
      choiceGroups: selectedGroups,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
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
    Navigator.pop(context, variation);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary ?? Colors.red,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditMode ? 'Edit Item' : 'Customize Item',
          style: getBoldStyle(
            fontSize: MyFonts.size18,
            color: AppColors.primary ?? Colors.red,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE DISPLAY AT TOP
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

            // ITEM TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.food.name ?? 'Item Name',
                style: getExtraBoldStyle(
                  fontSize: MyFonts.size20,
                  color: AppColors.text ?? Colors.white,
                ),
              ),
            ),

            padding12,

            // VARIATIONS & EXTRAS OPTIONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: VariationSelector(
                variations: widget.food.menuVariations,
                choiceGroups: choiceGroups,
                selectedVariation: selectedVariation,
                selectedChoices: selectedChoices,
                onVariationSelected: _selectVariation,
                onChoiceSelected: _toggleChoice,
              ),
            ),
          ],
        ),
      ),

      // STICKY BOTTOM NAVIGATION BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          boxShadow: [
            BoxShadow(
              color: AppColors.softShadow07 ?? Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // PRICE DISPLAY ON LEFT
              Column(
                mainAxisSize: MyFonts.size12 > 0 ? MainAxisSize.min : MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total:',
                    style: getRegularStyle(
                      fontSize: MyFonts.size12,
                      color: isDark
                          ? Colors.grey.shade400
                          : (AppColors.greyText ?? Colors.grey),
                    ),
                  ),
                  Text(
                    'PKR ${selectedPrice.toStringAsFixed(2)}',
                    style: getExtraBoldStyle(
                      fontSize: MyFonts.size16,
                      color: AppColors.text ?? Colors.white,
                    ),
                  ),
                ],
              ),

              // ACTION BUTTON ON RIGHT
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: isSelectionValid ? _addToCart : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary ?? Colors.red,
                    disabledBackgroundColor:
                    isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(
                    isSelectionValid
                        ? (widget.isEditMode ? 'Update Item' : 'Add to Cart')
                        : 'Complete Selection',
                    style: getBoldStyle(
                      fontSize: MyFonts.size14,
                      color: isSelectionValid
                          ? AppColors.white
                          : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
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