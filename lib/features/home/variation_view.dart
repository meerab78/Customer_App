

import 'package:flutter/material.dart';

import 'model/menu_model.dart';
import 'widget/variation_selector.dart';

class VariationView extends StatefulWidget {
  final Menu food;

  const VariationView({
    super.key,
    required this.food,
  });

  @override
  State<VariationView> createState() => _VariationViewState();
}

class _VariationViewState extends State<VariationView> {
  MenuVariation? selectedVariation;

// ChoiceGroup ID -> selected choices
  final Map<int, List<MenuVariation>> selectedChoices = {};

// Direct choices + selected variation ke choices
  List<ChoiceGroup> get choiceGroups {
    final groups = <ChoiceGroup>[];

    groups.addAll(widget.food.choiceGroup);

    if (selectedVariation != null) {
      groups.addAll(selectedVariation!.choiceGroups);
    }

    return groups;
  }

// Final selected price
  double get selectedPrice {
    double total =
        double.tryParse(widget.food.price ?? '0') ?? 0;

    // Variation price ADD hogi
    if (selectedVariation != null) {
      total +=
          double.tryParse(selectedVariation!.price ?? '0') ?? 0;
    }

    // Choices ki prices ADD hongi
    for (final choices in selectedChoices.values) {
      for (final choice in choices) {
        total +=
            double.tryParse(choice.price ?? '0') ?? 0;
      }
    }
    return total;
  }

// Check only REQUIRED selections
  bool get isSelectionValid {
    if (widget.food.menuVariations.isNotEmpty &&
        selectedVariation == null) {
      return false;
    }

// Choice groups ki min/max validation
    for (final group in choiceGroups) {
      final groupId = group.id;

      if (groupId == null) continue;

      final selectedCount =
          selectedChoices[groupId]?.length ?? 0;

      final minChoices = group.minChoices ?? 0;
      final maxChoices = group.maxChoices ?? 0;

// Required choices complete nahi
      if (selectedCount < minChoices) {
        return false;
      }

// Maximum exceed
      if (maxChoices > 0 &&
          selectedCount > maxChoices) {
        return false;
      }
    }

    return true;
  }

  void _selectVariation(MenuVariation variation) {
    setState(() {
      selectedVariation = variation;

// Variation change hone par
// purani variation-specific choices remove.
      selectedChoices.clear();
    });
  }

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
      final maxChoices = group.maxChoices ?? 0;

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
    final selectedGroups = choiceGroups
        .where(
          (group) =>
      selectedChoices[group.id]?.isNotEmpty ?? false,
    )
        .map((group) {
      final selected = selectedChoices[group.id] ?? [];

      return group.copyWith(
        choices: selected,
      );
    })
        .toList();

// Agar main variation selected hai
    if (selectedVariation != null) {
      final variation =
      selectedVariation!.copyWith(
        price: selectedPrice.toString(),
        choiceGroups: selectedGroups,
      );

      Navigator.pop(
        context,
        variation,
      );

      return;
    }

// Sirf choice groups hain, main variation nahi
    final variation = MenuVariation(
      id: null,
      name: widget.food.name,
      price: selectedPrice.toString(),
      takeAwayPrice: widget.food.takeAwayPrice,
      deliveryPrice: widget.food.deliveryPrice,
      choiceGroups: selectedGroups,
    );

    Navigator.pop(
      context,
      variation,
    );
  }

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
                variations: widget.food.menuVariations,
                choiceGroups: choiceGroups,
                selectedVariation: selectedVariation,
                selectedChoices: selectedChoices,
                onVariationSelected: _selectVariation,
                onChoiceSelected: _toggleChoice,
              ),
            ),
          ),

// ADD TO CART
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
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
                        ? 'Add to Cart - Rs ${selectedPrice.toStringAsFixed(0)}'
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

