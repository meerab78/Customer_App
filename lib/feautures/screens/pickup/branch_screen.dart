import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/provider/home_provider.dart';
import '../../../core/theme/app_colors.dart';

import '../../widgets/branch_card.dart';

class BranchScreen extends StatefulWidget {
  const BranchScreen({super.key});

  @override
  State<BranchScreen> createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchScreen> {
  bool _isSelectingBranch = false;
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<HomeProvider>().getBranches();
      await context.read<HomeProvider>().findNearestBranch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor:AppColors.background,
        title: const Text(
          "Choose Branch",
          style: TextStyle(
            fontWeight: FontWeight.bold,
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
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),

            const SizedBox(height: 6),
            Text(
              "Choose your preferred restaurant branch for pickup.",
              style: TextStyle(
                color: AppColors.greyText,
                fontSize: 15,
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
            const Text(
              "All Branches",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
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