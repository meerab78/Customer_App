import 'package:flutter/material.dart';
import '../model/menu_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';

class FoodVariationSelector extends StatelessWidget {
  final Menu food;
  final MenuVariation? selectedVariation;
  final ValueChanged<MenuVariation> onSelected;

  const FoodVariationSelector({
    super.key,
    required this.food,
    required this.selectedVariation,
    required this.onSelected,
  });

  bool get hasVariations =>
      food.menuVariations.isNotEmpty ||
          food.choiceGroup.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!hasVariations) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        Text(
          'Choose your option',
          style: getExtraBoldStyle(
            fontSize: MyFonts.size16,
            color: AppColors.text,
          ),
        ),

        const SizedBox(height: 10),

        ...food.menuVariations.map(
              (variation) => _VariationTile(
            variation: variation,
            selected: selectedVariation?.id == variation.id,
            onTap: () => onSelected(variation),
          ),
        ),

        ...food.choiceGroup.map(
              (group) => _ChoiceGroup(
            group: group,
            selectedVariation: selectedVariation,
            onSelected: onSelected,
          ),
        ),
      ],
    );
  }
}

class _ChoiceGroup extends StatelessWidget {
  final ChoiceGroup group;
  final MenuVariation? selectedVariation;
  final ValueChanged<MenuVariation> onSelected;

  const _ChoiceGroup({
    required this.group,
    required this.selectedVariation,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        Text(
          group.name ?? 'Choices',
          style: getBoldStyle(
            fontSize: MyFonts.size15,
            color: AppColors.text,
          ),
        ),

        const SizedBox(height: 8),

        ...group.choices.map(
              (choice) => _VariationTile(
            variation: choice,
            selected: selectedVariation?.id == choice.id,
            onTap: () => onSelected(choice),
          ),
        ),
      ],
    );
  }
}

class _VariationTile extends StatelessWidget {
  final MenuVariation variation;
  final bool selected;
  final VoidCallback onTap;

  const _VariationTile({
    required this.variation,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final price =
        double.tryParse(variation.price ?? '0') ?? 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(.08)
              : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.grey200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                variation.name ?? 'Option',
                style: getBoldStyle(
                  fontSize: MyFonts.size14,
                  color: AppColors.text,
                ),
              ),
            ),

            Text(
              'Rs ${price.toStringAsFixed(0)}',
              style: getExtraBoldStyle(
                fontSize: MyFonts.size14,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(width: 10),

            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.grey400,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}