// import 'package:flutter/material.dart';
// import 'package:http/http.dart' show read;
// import 'package:provider/provider.dart' show ReadContext;
// import '../../../core/theme/app_colors.dart';
// import '../../../core/theme/fonts_manager.dart';
// import '../../../core/theme/textfont_styles.dart';
// import '../../cart/controller.dart';
// import '../branch_view.dart';
// import 'delivery_pickup_card.dart';
//
// void showOrderTypeBottomSheet(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isDismissible: false,
//     enableDrag: false,
//     isScrollControlled: true,
//     backgroundColor: AppColors.transparent,
//     builder: (_) {
//       return Container(
//         padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
//         decoration: BoxDecoration(
//           color: AppColors.card,
//           borderRadius: const BorderRadius.vertical(
//             top: Radius.circular(28),
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 50,
//                   height: 5,
//                   decoration: BoxDecoration(
//                     color: AppColors.borderLight,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 14),
//               Text(
//                 "Choose Order Type",
//                 style: getBoldStyle(
//                   fontSize: MyFonts.size22,
//                   color: AppColors.text,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 "Select how you'd like to receive your order.",
//                 style: getRegularStyle(
//                   color: AppColors.greyText,
//                 ),
//               ),
//               const SizedBox(height: 18),
//               DeliveryPickupCard(
//                 icon: Icons.delivery_dining,
//                 title: "Delivery",
//                 subtitle: "Deliver food to your address",
//                 onTap: () {
//                   context.read<CartController>().changeOrderType('Delivery');
//                   Navigator.pop(context);
//                 },
//               ),
//               const SizedBox(height: 10),
//               DeliveryPickupCard(
//                 icon: Icons.storefront,
//                 title: "Pickup",
//                 subtitle: "Collect from restaurant branch",
//                 onTap: () {
//                   context.read<CartController>().changeOrderType('Takeaway');
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const BranchView(),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 8),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../../cart/controller.dart';
import '../controller.dart';
import '../branch_view.dart';
import 'delivery_pickup_card.dart';

void showOrderTypeBottomSheet(BuildContext context) {
  bool isSelecting = false;

  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setState) {
          Future<void> _handlePickup() async {
            if (isSelecting) return;
            setState(() => isSelecting = true);

            final home = sheetContext.read<HomeController>();

            // Agar location/branches abhi tak load nahi hui, load karo
            if (home.branchModel == null) {
              await home.getBranches();
            }
            if (home.userLatitude == null || home.userLongitude == null) {
              await home.loadSavedLocation();
            }

            await home.findNearestBranch();

            if (!sheetContext.mounted) return;

            sheetContext.read<CartController>().changeOrderType('Takeaway');
            Navigator.pop(sheetContext);
            if (home.selectedBranch == null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BranchView(),
                ),
              );
            } else {
              // Menu bhi naye branch ke hisaab se load karo
              await home.getMenu(home.selectedBranch!.id.toString());
            }
          }

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Choose Order Type",
                    style: getBoldStyle(
                      fontSize: MyFonts.size22,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Select how you'd like to receive your order.",
                    style: getRegularStyle(
                      color: AppColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 18),
                  DeliveryPickupCard(
                    icon: Icons.delivery_dining,
                    title: "Delivery",
                    subtitle: "Deliver food to your address",
                    onTap: () async {
                      if (isSelecting) return;
                      setState(() => isSelecting = true);

                      final home = sheetContext.read<HomeController>();

                      if (home.branchModel == null) {
                        await home.getBranches();
                      }
                      if (home.userLatitude == null || home.userLongitude == null) {
                        await home.loadSavedLocation();
                      }

                      await home.findNearestBranch();

                      if (!sheetContext.mounted) return;

                      sheetContext.read<CartController>().changeOrderType('Delivery');
                      Navigator.pop(sheetContext);

                      if (home.selectedBranch != null) {
                        await home.getMenu(home.selectedBranch!.id.toString());
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  DeliveryPickupCard(
                    icon: Icons.storefront,
                    title: "Pickup",
                    subtitle: "Collect from restaurant branch",
                    onTap: isSelecting ? () {} : _handlePickup,
                  ),
                  const SizedBox(height: 8),
                  if (isSelecting) ...[
                    const SizedBox(height: 10),
                    Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );
}