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


  const CartItemCard({
    super.key,
    required this.food,
    required this.onDelete,
    required this.onPlus,
    required this.onMinus,
  });

  @override
  Widget build(BuildContext context) {
    final price = double.tryParse(food.price ?? '0') ?? 0;
    final quantity = food.quantity ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.softShadow04,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: SizedBox(
              width: 82,
              height: 82,
              child: food.imageUrl != null &&
                  food.imageUrl!.isNotEmpty
                  ? Image.network(
                food.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _placeholder(),
              )
                  : _placeholder(),
            ),
          ),

          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name ?? 'Food',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: getExtraBoldStyle(
                    fontSize: MyFonts.size16,
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Rs ${price.toStringAsFixed(0)}',
                  style: getExtraBoldStyle(
                    fontSize: MyFonts.size15,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    _quantityButton(
                      Icons.remove,
                      onMinus,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: Text(
                        '$quantity',
                        style: getBoldStyle(
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    _quantityButton(
                      Icons.add,
                      onPlus,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete item
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.grey500,
            ),
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
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.grey100,
      child: Icon(
        Icons.fastfood_rounded,
        color: AppColors.primary,
        size: 32,
      ),
    );
  }
}

