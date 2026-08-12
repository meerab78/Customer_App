import 'package:flutter/material.dart';
import '../../core/models/menu_model.dart';
import '../../core/theme/app_colors.dart';

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Rs ${price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
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
              color: Colors.grey.shade500,
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
      color: Colors.grey.shade100,
      child: Icon(
        Icons.fastfood_rounded,
        color: AppColors.primary,
        size: 32,
      ),
    );
  }
}