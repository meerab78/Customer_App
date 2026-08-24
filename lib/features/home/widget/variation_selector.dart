
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
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
          Text(
            'Select Option',
            style: getBoldStyle(
              fontSize: MyFonts.size17,
              color: AppColors.text,
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
          color: isSelected
              ? AppColors.primary.withOpacity(0.06)
              : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.grey300,
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
                  ? AppColors.primary
                  : AppColors.grey,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                variation.name ?? 'Option',
                style: getSemiBoldStyle(
                  fontSize: MyFonts.size14,
                  color: AppColors.text,
                ),
              ),
            ),

            Text(
              'Rs ${variation.price ?? '0'}',
              style: getBoldStyle(
                fontSize: MyFonts.size14,
                color: AppColors.primary,
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
          style: getBoldStyle(
            fontSize: MyFonts.size17,
            color: AppColors.text,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          maxChoices > 0
              ? 'Select $minChoices-$maxChoices'
              : 'Select at least $minChoices',
          style: getRegularStyle(
            fontSize: MyFonts.size12,
            color: AppColors.greyText,
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
                      ? AppColors.primary.withOpacity(0.08)
                      : AppColors.containerColor2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.grey,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        choice.name ?? 'Choice',
                        style: getRegularStyle(
                          fontSize: MyFonts.size14,
                          color: AppColors.text,
                        ),
                      ),
                    ),

                    Text(
                      '+ Rs ${choice.price ?? '0'}',
                      style: getSemiBoldStyle(
                        fontSize: MyFonts.size13,
                        color: AppColors.primary,
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