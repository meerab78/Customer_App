import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';

class FeatureStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String ctaText;
  final VoidCallback onTap;
  final bool isLoading;

  const FeatureStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.ctaText,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: AppColors.greyText,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: getRegularStyle(
                fontSize: MyFonts.size12,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 4),
            isLoading
                ? SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
                : Text(
              value,
              style: getExtraBoldStyle(
                fontSize: MyFonts.size20,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ctaText,
              style: getSemiBoldStyle(
                fontSize: MyFonts.size11,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}