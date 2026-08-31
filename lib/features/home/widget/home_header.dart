
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../branch_view.dart';


class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  void _openBranchView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BranchView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeController>();

    final selectedBranch = provider.selectedBranch;

    return SafeArea(
      bottom: false,
      child: Container(
        height: 70,
        color: AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 12),

        child: Stack(
          children: [

            // QA Restaurant + Branch Selector
            Align(
              alignment: Alignment.centerLeft,

              child: InkWell(
                borderRadius: BorderRadius.circular(10),

                // QA Restaurant par click
                onTap: () {
                  _openBranchView(context);
                },

                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(
                        "QA Restaurant",
                        style: getBoldStyle(
                          fontSize: MyFonts.size23,
                          color: AppColors.primary,
                        ).copyWith(letterSpacing: 0.3),
                      ),

                      const SizedBox(height: 2),

                      // Branch name
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Text(
                            selectedBranch?.name ??
                                "Tap to select branch",

                            style: getMediumStyle(
                              fontSize: MyFonts.size15,
                              color: selectedBranch != null
                                  ? AppColors.text
                                  : AppColors.grey,
                            ),

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(width: 4),

                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




