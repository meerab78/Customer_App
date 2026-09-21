
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';

class MenuCategoryCard extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final String? imageUrl;

  const MenuCategoryCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.imageUrl,
  });

  IconData _getCategoryIcon(String title) {
    final name = title.toLowerCase();

    if (name.contains("burger")) {
      return Icons.lunch_dining_rounded;
    } else if (name.contains("pizza")) {
      return Icons.local_pizza_rounded;
    } else if (name.contains("drink") || name.contains("beverage")) {
      return Icons.local_drink_rounded;
    } else if (name.contains("dessert") || name.contains("sweet")) {
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
  Widget _iconOrImage() {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    if (!hasImage) {
      return Icon(
        _getCategoryIcon(title),
        size: 25,
        color: selected ? AppColors.white : AppColors.primary,
      );
    }

    return ClipOval(
      child: Image.network(
        imageUrl!,
        width: 46,
        height: 46,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          // Image load nahi hui to icon pe fallback
          return Icon(
            _getCategoryIcon(title),
            size: 25,
            color: selected ? AppColors.white : AppColors.primary,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 105,
        height: 110,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected ? AppColors.shadow : AppColors.softShadow06,
              blurRadius: selected ? 10 : 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                color: selected ? AppColors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 88,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: getSemiBoldStyle(
                  fontSize: MyFonts.size12,
                  color: selected ? AppColors.white : AppColors.text,
                ).copyWith(height: 1.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}