// import 'package:flutter/material.dart';
// import '../../core/theme/app_colors.dart';
//
// class HomeHeader extends StatelessWidget {
//   const HomeHeader({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       bottom: false,
//       child: Container(
//         height: 55,
//         color: AppColors.background,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             // Drawer Button
//             Positioned(
//               left: 4,
//               child: Builder(
//                 builder: (context) {
//                   return InkWell(
//                     borderRadius: BorderRadius.circular(14),
//                     onTap: () {
//                       Scaffold.of(context).openDrawer();
//                     },
//                     child: const Icon(
//                       Icons.menu_rounded,
//                       size: 35,
//                       color: AppColors.primary,
//                     ),
//                   );
//                 },
//               ),
//             ),
//
//             // Center Title
//             const Center(
//               child: Text(
//                 "QA Restaurant",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w700,
//                   color: AppColors.primary,
//                   letterSpacing: 0.3,
//                 ),
//               ),
//             ),
//
//             // Notification Button
//             Positioned(
//               right: 4,
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(14),
//                 onTap: () {},
//                 child: const Icon(
//                   Icons.notifications_none_rounded,
//                   size: 35,
//                   color: AppColors.primary,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../screens/pickup/branch_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "QA Restaurant",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 2),

                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BranchScreen(),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Tap to select branch",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(width: 4),

                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Drawer Button - Right Side
            Align(
              alignment: Alignment.centerRight,
              child: Builder(
                builder: (context) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                        Scaffold.of(context).openEndDrawer();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.menu_rounded,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}