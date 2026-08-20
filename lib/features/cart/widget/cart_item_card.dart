
import 'package:flutter/material.dart';
import '../../home/model/menu_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';

class CartItemCard extends StatelessWidget {
  final Menu food;
  final VoidCallback onDelete;
  final VoidCallback onPlus;
  final VoidCallback onMinus;
  final VoidCallback? onEdit;

  const CartItemCard({
    super.key,
    required this.food,
    required this.onDelete,
    required this.onPlus,
    required this.onMinus,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final price =
        double.tryParse(food.price ?? '0') ?? 0;

    final quantity = food.quantity ?? 1;

    final hasNormalCustomization =
        food.menuVariation != null ||
            food.choiceGroup
                .any((group) => group.choices.isNotEmpty);

    final hasDealCustomization =
        food.isDeal == true &&
            food.dealMenuDetails.isNotEmpty;

    final showEdit =
        hasNormalCustomization ||
            hasDealCustomization;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.grey200.withOpacity(.65),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE
              _foodImage(),

              const SizedBox(width: 10),

              // DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            food.name ?? 'Food',
                            maxLines: 2,
                            overflow:
                            TextOverflow.ellipsis,
                            style: getExtraBoldStyle(
                              fontSize: MyFonts.size15,
                              color: AppColors.text,
                            ),
                          ),
                        ),

                        const SizedBox(width: 5),

                        _deleteButton(),
                      ],
                    ),

                    const SizedBox(height: 3),

                    // PRICE
                    Text(
                      'Rs ${price.toStringAsFixed(0)}',
                      style: getExtraBoldStyle(
                        fontSize: MyFonts.size14,
                        color: AppColors.primary,
                      ),
                    ),

                    // NORMAL VARIATION
                    if (food.menuVariation != null &&
                        food.menuVariation!.id != null) ...[
                      const SizedBox(height: 5),
                      _smallTag(
                        food.menuVariation!.name ?? '',
                      ),
                    ],

                    // DEAL BADGE
                    if (food.isDeal == true) ...[
                      const SizedBox(height: 5),
                      _dealBadge(),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (food.choiceGroup
              .any((group) => group.choices.isNotEmpty))
            _selectedChoices(),

          if (food.isDeal == true &&
              food.dealMenuDetails.isNotEmpty)
            _dealDetails(),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              // VIEW / EDIT
              if (showEdit)
                InkWell(
                  onTap: onEdit,
                  borderRadius:
                  BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'View / Edit',
                          style: getBoldStyle(
                            fontSize: MyFonts.size11,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox(),

              // QUANTITY
              _quantitySelector(quantity),
            ],
          ),
        ],
      ),
    );
  }

  Widget _foodImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 68,
        height: 68,
        child: food.imageUrl != null &&
            food.imageUrl!.isNotEmpty
            ? Image.network(
          food.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => _placeholder(),
        )
            : _placeholder(),
      ),
    );
  }

  Widget _deleteButton() {
    return InkWell(
      onTap: onDelete,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 29,
        height: 29,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          size: 16,
          color: AppColors.grey500,
        ),
      ),
    );
  }

  Widget _dealBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 11,
            color: AppColors.primary,
          ),
          const SizedBox(width: 3),
          Text(
            'DEAL',
            style: getBoldStyle(
              fontSize: MyFonts.size9,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallTag(String text) {
    if (text.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: getMediumStyle(
          fontSize: MyFonts.size10,
          color: AppColors.grey500,
        ),
      ),
    );
  }


  Widget _selectedChoices() {
    final groups = food.choiceGroup
        .where((group) => group.choices.isNotEmpty)
        .toList();

    if (groups.isEmpty) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune_rounded,
                size: 13,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Selected options',
                style: getBoldStyle(
                  fontSize: MyFonts.size10,
                  color: AppColors.text,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          ...groups.expand(
                (group) => [
              Text(
                group.name ?? '',
                style: getBoldStyle(
                  fontSize: MyFonts.size10,
                  color: AppColors.text,
                ),
              ),

              ...group.choices.map(
                    (choice) => _choiceRow(
                  choice.name ?? '',
                  choice.price,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dealDetails() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.grey200.withOpacity(.55),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.card_giftcard_outlined,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 5),
              Text(
                'Deal includes',
                style: getBoldStyle(
                  fontSize: MyFonts.size11,
                  color: AppColors.text,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          ...food.dealMenuDetails.map(
                (dealItem) => _dealItem(dealItem),
          ),
        ],
      ),
    );
  }


  Widget _dealItem(Menu dealItem) {
    final variation =
        dealItem.menuVariation;

    final variationChoices =
        variation?.choiceGroups ?? [];

    final directChoices = dealItem.choiceGroup
        .where(
          (group) => group.choices.isNotEmpty,
    )
        .toList();

    final hasVariation =
        variation != null &&
            variation.id != null;

    final hasVariationChoices =
    variationChoices.any(
          (group) => group.choices.isNotEmpty,
    );

    final hasDirectChoices =
        directChoices.isNotEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // DEAL ITEM NAME
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  dealItem.name ?? 'Item',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: getBoldStyle(
                    fontSize: MyFonts.size11,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),

          // VARIATION
          if (hasVariation) ...[
            const SizedBox(height: 3),

            Padding(
              padding:
              const EdgeInsets.only(left: 11),
              child: Text(
                variation!.name ?? '',
                style: getMediumStyle(
                  fontSize: MyFonts.size10,
                  color: AppColors.grey500,
                ),
              ),
            ),
          ],

          // DIRECT CHOICES
          if (hasDirectChoices) ...[
            const SizedBox(height: 3),

            Padding(
              padding:
              const EdgeInsets.only(left: 11),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: directChoices.expand(
                      (group) => [
                    Text(
                      group.name ?? '',
                      style: getBoldStyle(
                        fontSize: MyFonts.size10,
                        color: AppColors.text,
                      ),
                    ),

                    ...group.choices.map(
                          (choice) => _choiceRow(
                        choice.name ?? '',
                        choice.price,
                        compact: true,
                      ),
                    ),
                  ],
                ).toList(),
              ),
            ),
          ],

          // VARIATION CHOICES
          if (hasVariationChoices) ...[
            const SizedBox(height: 3),

            Padding(
              padding:
              const EdgeInsets.only(left: 11),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: variationChoices
                    .where(
                      (group) =>
                  group.choices.isNotEmpty,
                )
                    .expand(
                      (group) => [
                    Text(
                      group.name ?? '',
                      style: getBoldStyle(
                        fontSize: MyFonts.size10,
                        color: AppColors.text,
                      ),
                    ),

                    ...group.choices.map(
                          (choice) => _choiceRow(
                        choice.name ?? '',
                        choice.price,
                        compact: true,
                      ),
                    ),
                  ],
                )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _choiceRow(
      String name,
      String? price, {
        bool compact = false,
      }) {
    final hasPrice =
        price != null && price.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 1,
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_rounded,
            size: compact ? 11 : 12,
            color: AppColors.primary,
          ),

          const SizedBox(width: 3),

          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: getRegularStyle(
                fontSize: compact
                    ? MyFonts.size9
                    : MyFonts.size10,
                color: AppColors.grey500,
              ),
            ),
          ),

          if (hasPrice)
            Text(
              '(+Rs $price)',
              style: getMediumStyle(
                fontSize: compact
                    ? MyFonts.size9
                    : MyFonts.size10,
                color: AppColors.grey500,
              ),
            ),
        ],
      ),
    );
  }
  Widget _quantitySelector(int quantity) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(
        horizontal: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _quantityButton(
            Icons.remove_rounded,
            onMinus,
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 9,
            ),
            child: Text(
              '$quantity',
              style: getBoldStyle(
                fontSize: MyFonts.size12,
                color: AppColors.text,
              ),
            ),
          ),

          _quantityButton(
            Icons.add_rounded,
            onPlus,
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(
      IconData icon,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 27,
        height: 30,
        child: Icon(
          icon,
          size: 14,
          color: AppColors.text,
        ),
      ),
    );
  }
  Widget _placeholder() {
    return Container(
      color: AppColors.grey100,
      child: Icon(
        food.isDeal == true
            ? Icons.card_giftcard_outlined
            : Icons.fastfood_rounded,
        color: AppColors.primary,
        size: 27,
      ),
    );
  }
}