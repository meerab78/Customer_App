import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';

class FoodQuantityCartBar extends StatelessWidget {
  final int quantity;
  final double total;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onAddToCart;
  final bool isAddEnabled;

  const FoodQuantityCartBar({
    super.key,
    required this.quantity,
    required this.total,
    required this.onMinus,
    required this.onPlus,
    required this.onAddToCart,
    this.isAddEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          _QuantityButton(
            icon: Icons.remove_rounded,
            onTap: onMinus,
          ),

          SizedBox(
            width: 34,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: getExtraBoldStyle(
                fontSize: MyFonts.size16,
                color: AppColors.text,
              ),
            ),
          ),

          _QuantityButton(
            icon: Icons.add_rounded,
            onTap: onPlus,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: SizedBox(
              height: 42,
              child: ElevatedButton(
                onPressed: isAddEnabled ? onAddToCart : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAddEnabled
                      ? AppColors.primary
                      : AppColors.grey300,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.grey300,
                  disabledForegroundColor: AppColors.grey600,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Add To Cart • Rs ${total.toStringAsFixed(0)}',
                    maxLines: 1,
                    style: getBoldStyle(
                      fontSize: MyFonts.size14,
                      color: AppColors.white,
                    ),
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

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.grey200,
          ),
        ),
        child: Icon(
          icon,
          size: 17,
          color: AppColors.text,
        ),
      ),
    );
  }
}