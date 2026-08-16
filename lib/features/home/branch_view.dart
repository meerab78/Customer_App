import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';

import 'widget/branch_card.dart';

class BranchView extends StatefulWidget {
  const BranchView({super.key});

  @override
  State<BranchView> createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchView> {
  bool _isSelectingBranch = false;
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<HomeController>().getBranches();
      await context.read<HomeController>().findNearestBranch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor:AppColors.background,
        title: Text(
          "Choose Branch",
          style: getBoldStyle(
            fontSize: MyFonts.size22,
            color: AppColors.text,
          ),
        ),
      ),

      body: provider.branchModel == null
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const SizedBox(height: 5),
            Text(
              "Pickup Branch",
              style: getBoldStyle(
                fontSize: MyFonts.size28,
                color: AppColors.text,
              ),
            ),

            const SizedBox(height: 6),
            Text(
              "Choose your preferred restaurant branch for pickup.",
              style: getRegularStyle(
                color: AppColors.greyText,
                fontSize: MyFonts.size15,
              ),
            ),
            const SizedBox(height: 20),
            if (provider.recommendedBranch != null) ...[
              BranchCard(
                branch: provider.recommendedBranch!,
                recommended: true,
                distance: provider.getDistanceFromUser(
                  provider.recommendedBranch!,
                ),
                onTap: () async {
                  if (_isSelectingBranch) return;
                  setState(() {
                    _isSelectingBranch = true;
                  });
                  await provider.selectBranch(
                    provider.recommendedBranch!,
                  );
                  if (!mounted) return;
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 15),
            ],
            Text(
              "All Branches",
              style: getBoldStyle(
                fontSize: MyFonts.size22,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 10),
            ...provider.branchModel!.data
                .where(
                  (branch) =>
              branch.id != provider.recommendedBranch?.id,
            )
                .map(
                  (branch) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: BranchCard(
                  branch: branch,
                  distance: provider.getDistanceFromUser(
                    branch,
                  ),
                  onTap: () async {
                    if (_isSelectingBranch) return;
                    setState(() {
                      _isSelectingBranch = true;
                    });
                    await provider.selectBranch(branch);
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


