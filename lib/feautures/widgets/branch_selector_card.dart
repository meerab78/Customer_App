import 'package:flutter/material.dart';

import '../../core/models/branch_model.dart';
import '../../core/theme/app_colors.dart';
import '../screens/pickup/branch_screen.dart';
class BranchSelectorCard extends StatelessWidget {
  final Branch? branch;
  const BranchSelectorCard({
    super.key,
    required this.branch,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const BranchScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 8,
              offset: const Offset(0,3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child:  Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 25,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    branch?.name ?? "Select Branch",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:  TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    branch?.address ??
                        "Choose your restaurant",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:  TextStyle(
                      fontSize: 12,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.08),
                shape: BoxShape.circle,
              ),
              child:  Icon(
                Icons.arrow_forward_ios,
                size: 13,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}