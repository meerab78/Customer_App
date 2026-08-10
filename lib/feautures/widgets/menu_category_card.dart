// import 'package:flutter/material.dart';
// import '../../core/theme/app_colors.dart';
//
// class MenuCategoryCard extends StatelessWidget {
//   final String title;
//   final bool selected;
//   final VoidCallback onTap;
//
//   const MenuCategoryCard({
//     super.key,
//     required this.title,
//     required this.selected,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(25),
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         margin: const EdgeInsets.only(right: 10),
//         padding: const EdgeInsets.symmetric(
//           horizontal: 20,
//           vertical: 10,
//         ),
//         decoration: BoxDecoration(
//           color: selected
//               ? AppColors.primary
//               : Colors.white,
//           borderRadius: BorderRadius.circular(25),
//           border: Border.all(
//             color: AppColors.primary,
//             width: 1.2,
//           ),
//         ),
//         child: Text(
//           title,
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             color: selected
//                 ? Colors.white
//                 : AppColors.primary,
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

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
      borderRadius: BorderRadius.circular(18),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        width: 82,
        height: 95,

        margin: const EdgeInsets.only(right: 12),

        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : Colors.white,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.grey.shade200,
            width: 1,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                selected ? 0.12 : 0.06,
              ),
              blurRadius: selected ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Category Icon
            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.18)
                    : AppColors.primary.withOpacity(0.08),

                shape: BoxShape.circle,
              ),

              child: Icon(
                _getCategoryIcon(title),
                size: 24,
                color: selected
                    ? Colors.white
                    : AppColors.primary,
              ),
            ),

            const SizedBox(height: 7),

            // Category Name
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}