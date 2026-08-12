

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/provider/home_provider.dart';
import '../../core/theme/app_colors.dart';
import '../screens/pickup/branch_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  void _openBranchScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BranchScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

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
                  _openBranchScreen(context);
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
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),

                      const SizedBox(height: 2),

                      // Branch name
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Text(
                            selectedBranch?.name ??
                                "Tap to select branch",

                            style: TextStyle(
                              fontSize: 15,
                              color: selectedBranch != null
                                  ? AppColors.text
                                  : Colors.grey,
                              fontWeight: FontWeight.w500,
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

            // Theme Button
            // Align(
            //   alignment: Alignment.centerRight,
            //
            //   child: InkWell(
            //     borderRadius: BorderRadius.circular(14),
            //
            //     onTap: () {
            //       // Theme functionality
            //     },
            //
            //     child: Padding(
            //       padding: const EdgeInsets.all(0),
            //
            //       child: Icon(
            //         Icons.dark_mode_outlined,
            //         size: 40,
            //         color: AppColors.primary,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}