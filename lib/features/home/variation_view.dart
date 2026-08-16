import 'package:flutter/material.dart';
import 'model/menu_model.dart';

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

  @override
  void initState() {
    super.initState();
  }

  // Direct choice groups + selected variation ke choice groups
  List<ChoiceGroup> get choiceGroups {
    final groups = <ChoiceGroup>[];

    groups.addAll(widget.food.choiceGroup);

    if (selectedVariation != null) {
      groups.addAll(selectedVariation!.choiceGroups);
    }

    return groups;
  }

  // Final price
  double get selectedPrice {
    // Agar variation hai to variation price,
    // warna normal food price.
    double total;

    if (selectedVariation != null) {
      total =
          double.tryParse(selectedVariation!.price ?? '0') ??
              0;
    } else {
      total =
          double.tryParse(widget.food.price ?? '0') ??
              0;
    }

    // Selected choices ki prices add karo
    for (final choices in selectedChoices.values) {
      for (final choice in choices) {
        total +=
            double.tryParse(choice.price ?? '0') ?? 0;
      }
    }

    return total;
  }

  // Check whether all required selections are complete
  bool get isSelectionValid {
    // Agar main variations available hain
    // to user ko ek variation select karna hoga.
    if (widget.food.menuVariations.isNotEmpty &&
        selectedVariation == null) {
      return false;
    }

    // Har choice group ka min/max check
    for (final group in choiceGroups) {
      final groupId = group.id;

      if (groupId == null) continue;

      final selectedCount =
          selectedChoices[groupId]?.length ?? 0;

      final minChoices = group.minChoices ?? 0;
      final maxChoices = group.maxChoices ?? 0;

      // Minimum complete nahi
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

    // Selected variation ke andar selected choices
    final selectedGroups = choiceGroups.map((group) {
      final selected =
          selectedChoices[group.id] ?? [];

      return group.copyWith(
        choices: selected,
      );
    }).toList();

    // Agar main variation selected hai
    if (selectedVariation != null) {
      final variation =
      selectedVariation!.copyWith(
        // IMPORTANT:
        // yahan final price save ho rahi hai
        price: selectedPrice.toString(),
        choiceGroups: selectedGroups,
      );

      Navigator.pop(
        context,
        variation,
      );

      return;
    }

    // Agar sirf choice groups hain
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
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  // =========================
                  // MAIN VARIATIONS
                  // =========================
                  if (widget.food.menuVariations.isNotEmpty) ...[
                    const Text(
                      'Select Size',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...widget.food.menuVariations.map(
                          (variation) {
                        return RadioListTile<MenuVariation>(
                          value: variation,
                          groupValue: selectedVariation,

                          title: Text(
                            variation.name ?? '',
                          ),

                          subtitle: Text(
                            'Rs ${variation.price ?? '0'}',
                          ),

                          onChanged: (value) {
                            setState(() {
                              selectedVariation = value;

                              // Variation change hui,
                              // purani choices remove.
                              selectedChoices.clear();
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                  // CHOICE GROUPS
                  ...choiceGroups.map(
                        (group) {
                      final groupId = group.id;

                      final selected =
                      groupId == null
                          ? <MenuVariation>[]
                          : selectedChoices[groupId] ??
                          [];

                      final minChoices =
                          group.minChoices ?? 0;

                      final maxChoices =
                          group.maxChoices ?? 0;

                      return Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          Text(
                            group.name ??
                                'Select Option',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            maxChoices > 0
                                ? 'Select $minChoices-$maxChoices'
                                : 'Select at least $minChoices',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                              Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 8),

                          ...group.choices.map(
                                (choice) {
                              final isSelected =
                              selected.any(
                                    (item) =>
                                item.id ==
                                    choice.id,
                              );

                              return CheckboxListTile(
                                value: isSelected,

                                title: Text(
                                  choice.name ?? '',
                                ),

                                subtitle: Text(
                                  'Rs ${choice.price ?? '0'}',
                                ),

                                onChanged: (_) {
                                  _toggleChoice(
                                    group,
                                    choice,
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 15),
                        ],
                      );
                    },
                  ),
                ],
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
                        : 'Complete Selection',
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