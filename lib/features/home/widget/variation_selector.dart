
import 'package:flutter/material.dart';

import '../model/menu_model.dart';

class VariationSelector extends StatelessWidget {
  final List<MenuVariation> variations;
  final List<ChoiceGroup> choiceGroups;

  final MenuVariation? selectedVariation;

  final Map<int, List<MenuVariation>> selectedChoices;

  final ValueChanged<MenuVariation> onVariationSelected;

  final void Function(
      ChoiceGroup group,
      MenuVariation choice,
      ) onChoiceSelected;

  const VariationSelector({
    super.key,
    required this.variations,
    required this.choiceGroups,
    required this.selectedVariation,
    required this.selectedChoices,
    required this.onVariationSelected,
    required this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (variations.isNotEmpty) ...[
          const Text(
            'Select Option',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ...variations.map(
                (variation) {
              final isSelected =
                  selectedVariation?.id == variation.id;

              return _VariationTile(
                variation: variation,
                isSelected: isSelected,
                onTap: () {
                  onVariationSelected(variation);
                },
              );
            },
          ),

          const SizedBox(height: 14),
        ],

        ...choiceGroups.map(
              (group) {
            return _ChoiceGroupWidget(
              group: group,
              selectedChoices:
              selectedChoices[group.id] ?? [],
              onChoiceSelected: (choice) {
                onChoiceSelected(
                  group,
                  choice,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// VARIATION TILE
class _VariationTile extends StatelessWidget {
  final MenuVariation variation;
  final bool isSelected;
  final VoidCallback onTap;

  const _VariationTile({
    required this.variation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                variation.name ?? 'Option',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Text(
              'Rs ${variation.price ?? '0'}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CHOICE GROUP

class _ChoiceGroupWidget extends StatelessWidget {
  final ChoiceGroup group;
  final List<MenuVariation> selectedChoices;

  final ValueChanged<MenuVariation> onChoiceSelected;

  const _ChoiceGroupWidget({
    required this.group,
    required this.selectedChoices,
    required this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final minChoices = group.minChoices ?? 0;
    final maxChoices = group.maxChoices ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.name ?? 'Select Choice',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          maxChoices > 0
              ? 'Select $minChoices-$maxChoices'
              : 'Select at least $minChoices',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 8),

        ...group.choices.map(
              (choice) {
            final isSelected = selectedChoices.any(
                  (item) => item.id == choice.id,
            );

            return InkWell(
              onTap: () {
                onChoiceSelected(choice);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 7),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context)
                      .primaryColor
                      .withOpacity(0.08)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        choice.name ?? 'Choice',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),

                    Text(
                      '+ Rs ${choice.price ?? '0'}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}

