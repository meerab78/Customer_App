
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';

class MenuCategoryCard extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const MenuCategoryCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  IconData _getCategoryIcon(String title) {
    final name = title.toLowerCase();

    if (name.contains("burger")) {
      return Icons.lunch_dining_rounded;
    } else if (name.contains("pizza")) {
      return Icons.local_pizza_rounded;
    } else if (name.contains("drink") ||
        name.contains("beverage")) {
      return Icons.local_drink_rounded;
    } else if (name.contains("dessert") ||
        name.contains("sweet")) {
      return Icons.icecream_rounded;
    } else if (name.contains("chicken")) {
      return Icons.restaurant_rounded;
    } else if (name.contains("fries")) {
      return Icons.fastfood_rounded;
    } else if (name.contains("salad")) {
      return Icons.eco_rounded;
    } else {
      return Icons.restaurant_menu_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        width: 105,
        height: 112,

        margin: const EdgeInsets.only(right: 12),

        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.white,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.grey200,
            width: 1,
          ),

          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.black.withOpacity(0.14)
                  : AppColors.softShadow06,
              blurRadius: selected ? 12 : 7,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
// Category Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),

              width: 46,
              height: 46,

              decoration: BoxDecoration(
                color: selected
                    ? AppColors.white.withOpacity(0.18)
                    : AppColors.primary.withOpacity(0.08),

                shape: BoxShape.circle,
              ),

              child: Icon(
                _getCategoryIcon(title),
                size: 25,
                color: selected
                    ? AppColors.white
                    : AppColors.primary,
              ),
            ),

            const SizedBox(height: 8),

// Category Name
            SizedBox(
              width: 88,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: getSemiBoldStyle(
                  fontSize: MyFonts.size12,
                  color: selected
                      ? AppColors.white
                      : AppColors.black87,
                ).copyWith(height: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



