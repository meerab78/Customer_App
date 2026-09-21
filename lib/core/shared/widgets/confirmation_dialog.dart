import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/fonts_manager.dart';
import '../../theme/textfont_styles.dart';

class ConfirmationDialog {
  static Future<bool?> show({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    required String confirmText,
    String cancelText = 'Cancel',
    Color? iconColor,
    Color? confirmColor,
  }) {
    final Color effectiveIconColor = iconColor ?? AppColors.primary;
    final Color effectiveConfirmColor = confirmColor ?? AppColors.primary;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: effectiveIconColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 27,
                color: effectiveIconColor,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: getBoldStyle(
                fontSize: MyFonts.size18,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: getRegularStyle(
            fontSize: MyFonts.size13,
            color: AppColors.greyText,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      cancelText,
                      style: getSemiBoldStyle(
                        fontSize: MyFonts.size14,
                        color: AppColors.greyText,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: effectiveConfirmColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: getSemiBoldStyle(
                        fontSize: MyFonts.size14,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}