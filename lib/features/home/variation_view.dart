
import 'package:flutter/material.dart';

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
        const SnackBar(
          content: Text(
            'Please complete the required selections.',
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
      appBar: AppBar(
        title: Text(
          widget.food.name ?? 'Customize',
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: VariationSelector(
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
            ),
          ),

          // ====================================================
          // DONE / UPDATE BUTTON
          // ====================================================

          SafeArea(
            top: false,

            child: Padding(
              padding:
              const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16,
              ),

              child: SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed:
                  isSelectionValid
                      ? _addToCart
                      : null,

                  child: Text(
                    isSelectionValid
                        ? 'Done - Rs ${selectedPrice.toStringAsFixed(0)}'
                        : 'Complete Required Selection',
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