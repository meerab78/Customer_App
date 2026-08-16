import 'package:flutter/material.dart';
import '../model/branch_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';


class BranchCard extends StatelessWidget {
  final Branch branch;
  final double distance;
  final bool recommended;
  final VoidCallback onTap;

  const BranchCard({
    super.key,
    required this.branch,
    required this.distance,
    required this.onTap,
    this.recommended = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.softShadow04,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if (recommended)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                         Text(
                          "Recommended",
                          style: getBoldStyle(
                            fontSize: MyFonts.size11,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (recommended)
                  const SizedBox(height: 10),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                      AppColors.primary.withOpacity(.10),
                      child:  Icon(
                        Icons.storefront_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          Text(
                            branch.name ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: getBoldStyle(
                              fontSize: MyFonts.size16,
                              color: AppColors.text,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.grey100,
                                  borderRadius:
                                  BorderRadius.circular(18),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                     Icon(
                                      Icons.near_me_rounded,
                                      size: 13,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${distance.toStringAsFixed(1)} km",
                                      style: getSemiBoldStyle(
                                        fontSize: MyFonts.size11,
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: branch.restaurantOpen == true
                                      ? AppColors.openStatusBg
                                      : AppColors.closedStatusBg,
                                  borderRadius:
                                  BorderRadius.circular(18),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    Icon(
                                      branch.restaurantOpen == true
                                          ? Icons.check_circle_rounded
                                          : Icons.schedule_rounded,
                                      size: 13,
                                      color:
                                      branch.restaurantOpen == true
                                          ? AppColors.openStatus
                                          : AppColors.closedStatus,
                                    ),

                                    const SizedBox(width: 4),

                                    Text(
                                      branch.restaurantOpen == true
                                          ? "Open"
                                          : "Closed",
                                      style: getSemiBoldStyle(
                                        fontSize: MyFonts.size11,
                                        color:
                                        branch.restaurantOpen == true
                                            ? AppColors.openStatus
                                            : AppColors.closedStatus,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.grey,
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        branch.address ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: getRegularStyle(
                          fontSize: MyFonts.size13,
                          color: AppColors.greyText,
                        ).copyWith(height: 1.3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



