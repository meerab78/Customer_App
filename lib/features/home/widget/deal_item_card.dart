
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../model/menu_model.dart';
import 'variation_selector.dart';

class DealItemCard extends StatefulWidget {
  final Menu item;
  final ValueChanged<Menu>? onItemUpdated;
  final ValueChanged<bool>? onCompletionChanged;

  const DealItemCard({
    super.key,
    required this.item,
    this.onItemUpdated,
    this.onCompletionChanged,
  });

  @override
  State<DealItemCard> createState() => _DealItemCardState();
}

class _DealItemCardState extends State<DealItemCard> {
  bool isExpanded = false;
  MenuVariation? selectedVariation;
  double? _originalBasePrice;
  final Map<int, List<MenuVariation>> selectedChoices = {};
  @override
  void initState() {
    super.initState();

    _originalBasePrice =
        double.tryParse(
          widget.item.price ?? '0',
        ) ??
            0;

    _initializeExistingSelection();
  }
// EXISTING SELECTION LOAD KARO
  void _initializeExistingSelection() {
    // EXISTING SELECTED VARIATION
    if (widget.item.menuVariation != null) {
      final existingVariation = widget.item.menuVariation!;

      for (final variation in widget.item.menuVariations) {
        if (variation.id == existingVariation.id) {
          selectedVariation = variation;
          break;
        }
      }

      // Fallback
      selectedVariation ??= existingVariation;

      // Original base price se variation aur choices ki price nikal dein
      // (kyunke widget.item.price total ho sakta hai)
      final variationExtra =
          double.tryParse(existingVariation.price ?? '0') ?? 0;

      double choicesExtra = 0;
      for (final group in existingVariation.choiceGroups) {
        for (final choice in group.choices) {
          choicesExtra += double.tryParse(choice.price ?? '0') ?? 0;
        }
      }

      _originalBasePrice =
          (_originalBasePrice ?? 0) - variationExtra - choicesExtra;
    }
  }

// CHOICES LOAD KARNE KA HELPER
  void _initializeChoices(List<ChoiceGroup> groups) {
    for (final group in groups) {
      final groupId = group.id;

      if (groupId == null) continue;
    }
  }

  @override
  void didUpdateWidget(
      covariant DealItemCard oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item.id != widget.item.id) {
      _originalBasePrice =
          double.tryParse(
            widget.item.price ?? '0',
          ) ??
              0;

      selectedVariation = null;
      selectedChoices.clear();
      _initializeExistingSelection();
    }
  }
  double get basePrice {
    return _originalBasePrice ?? 0;
  }
  double get finalPrice {
    double total = basePrice;

    // Main variation ki EXTRA price
    if (selectedVariation != null) {
      total +=
          double.tryParse(
            selectedVariation!.price ?? '0',
          ) ??
              0;
    }

    // Selected choices ki EXTRA prices
    for (final choices in selectedChoices.values) {
      for (final choice in choices) {
        total +=
            double.tryParse(
              choice.price ?? '0',
            ) ??
                0;
      }
    }

    return total;
  }
// CUSTOMIZATION AVAILABLE?

  bool get hasCustomization {
    return widget.item.menuVariations.isNotEmpty ||
        widget.item.choiceGroup.isNotEmpty ||
        widget.item.menuVariation != null;
  }
// CHOICE GROUPS
  List<ChoiceGroup> get choiceGroups {
    final groups = <ChoiceGroup>[];

    groups.addAll(widget.item.choiceGroup);

    if (selectedVariation != null) {
      groups.addAll(
        selectedVariation!.choiceGroups,
      );
    } else if (widget.item.menuVariation != null) {
      groups.addAll(
        widget.item.menuVariation!.choiceGroups,
      );
    }

    return groups;
  }
// VALIDATION
  bool get isValid {
    // CHOICE GROUP VALIDATION

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
      if (minChoices == 0) {
        if (maxChoices > 0 &&
            selectedCount > maxChoices) {
          return false;
        }

        continue;
      }
      // REQUIRED
      if (selectedCount < minChoices) {
        return false;
      }
      // MAXIMUM
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

// Variation change hone par
// old choices clear.
      selectedChoices.clear();
    });
  }


// SELECT / UNSELECT CHOICE

  void _toggleChoice(
      ChoiceGroup group,
      MenuVariation choice,
      ) {
    final groupId = group.id;

    if (groupId == null) return;

    final selected = List<MenuVariation>.from(
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

// EXPAND / COLLAPSE

  void _toggleExpanded() {
    if (!hasCustomization) return;

    setState(() {
      isExpanded = !isExpanded;
    });
  }

  // BUILD UPDATED ITEM
  Menu _buildUpdatedItem() {
    // Direct choices sirf parent Menu ke choiceGroup mein jayengi
    final directGroups = widget.item.choiceGroup.map((group) {
      final selected = selectedChoices[group.id] ?? [];

      return group.copyWith(
        choices: selected,
      );
    }).toList();

    MenuVariation? finalVariation;

    if (selectedVariation != null) {
      // Variation ke choices sirf variation ke andar jayengi
      final variationGroups =
      selectedVariation!.choiceGroups.map((group) {
        final selected = selectedChoices[group.id] ?? [];

        return group.copyWith(
          choices: selected,
        );
      }).toList();

      finalVariation = selectedVariation!.copyWith(
        price: finalPrice.toString(),
        takeAwayPrice: selectedVariation!.takeAwayPrice,
        deliveryPrice: selectedVariation!.deliveryPrice,
        choiceGroups: variationGroups,
      );
    }

    return widget.item.copyWith(
      price: finalPrice.toString(),
      menuVariation: finalVariation,

      // Sirf direct choices
      choiceGroup: directGroups,
    );
  }
// IMAGE
  Widget _image() {
    final url = widget.item.imageUrl ?? '';

    if (url.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return _placeholder();
      },
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.tertiary.withOpacity(0.1),
      child: Icon(
        Icons.fastfood_outlined,
        color: AppColors.tertiary,
      ),
    );
  }

// BUILD

  @override
  Widget build(BuildContext context) {
    // UI-only flag — purely derived from existing getters,
    // used just to color the status chip below.
    final bool isReady = !hasCustomization || isValid;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded
              ? AppColors.primary
              : AppColors.borderColorGrey,
          width: isExpanded ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.softShadow04,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ITEM HEADER
          InkWell(
            onTap: _toggleExpanded,
            borderRadius:
            BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(14),
                        child: SizedBox(
                          width: 75,
                          height: 75,
                          child: _image(),
                        ),
                      ),
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isReady
                                ? AppColors.success
                                : AppColors.tertiary,
                            border: Border.all(
                              color: AppColors.card,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            isReady
                                ? Icons.check_rounded
                                : Icons.edit_rounded,
                            size: 11,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.item.name ??
                                    'Item',
                                style: getBoldStyle(
                                  fontSize: MyFonts.size16,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets
                                  .symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.tertiary
                                    .withOpacity(0.12),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: Text(
                                'x${widget.item.quantity ?? 1}',
                                style: getBoldStyle(
                                  fontSize: MyFonts.size13,
                                  color: AppColors.tertiary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Rs ${finalPrice.toStringAsFixed(0)}',
                          style: getBoldStyle(
                            fontSize: MyFonts.size15,
                            color:
                            AppColors.primary,
                          ),
                        ),
// SELECTED CHOICES
                        ...selectedChoices.entries.expand(
                              (entry) {
                            final choices = entry.value;

                            return choices.map(
                                  (choice) => Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  '• ${choice.name ?? ''}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: getRegularStyle(
                                    fontSize: MyFonts.size12,
                                    color: AppColors.grey500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        if (hasCustomization) ...[
                          const SizedBox(height: 6),

                          Row(
                            children: [
                              Text(
                                isExpanded
                                    ? 'Close customization'
                                    : (isReady
                                    ? 'Tap to edit'
                                    : 'Tap to customize'),
                                style: getRegularStyle(
                                  fontSize: MyFonts.size12,
                                  color:
                                  AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0,
                                duration: const Duration(
                                  milliseconds: 200,
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
// EXPANDED CUSTOMIZATION

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: (isExpanded && hasCustomization)
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding:
              const EdgeInsets.fromLTRB(
                14,
                0,
                14,
                14,
              ),
              child: Column(
                children: [
                  Divider(color: AppColors.divider),

                  const SizedBox(height: 8),

                  VariationSelector(
                    variations:
                    widget.item.menuVariations,
                    choiceGroups:
                    choiceGroups,
                    selectedVariation:
                    selectedVariation,
                    selectedChoices:
                    selectedChoices,
                    onVariationSelected:
                    _selectVariation,
                    onChoiceSelected:
                    _toggleChoice,
                  ),

                  const SizedBox(height: 8),

// DONE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: isValid
                          ? () {
                        final updatedItem =
                        _buildUpdatedItem();

                        widget.onItemUpdated?.call(
                          updatedItem,
                        );

                        widget.onCompletionChanged?.call(true);

                        setState(() {
                          isExpanded = false;
                        });
                      }
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
                            13,
                          ),
                        ),
                      ),
                      child: Text(
                        isValid
                            ? 'Done - Rs ${finalPrice.toStringAsFixed(0)}'
                            : 'Complete Selection',
                        style: getBoldStyle(
                          fontSize:
                          MyFonts.size14,
                          color:
                          AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox(
              width: double.infinity,
              height: 0,
            ),
          ),
        ],
      ),
    );
  }
}
