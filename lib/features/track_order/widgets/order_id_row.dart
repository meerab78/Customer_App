import '/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/core/theme/textfont_styles.dart';

class OrderIdRow extends StatelessWidget {
  const OrderIdRow({
    required this.orderId,
    required this.hasArrived,
    required this.onTap,
  });

  final String orderId;
  final bool hasArrived;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color tone = hasArrived ? AppColors.success : AppColors.primary;
    final String label = hasArrived ? 'DELIVERED' : 'OUT FOR DELIVERY';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID',
                    style: getMediumStyle(
                        fontSize: 12, color: AppColors.textColor2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#$orderId',
                    style: getSemiBoldStyle(
                        fontSize: 20, color: AppColors.textColor),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: getBoldStyle(
                  fontSize: 12,
                  color: tone,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
