// import 'package:lottie/lottie.dart';
// import 'package:flutter/material.dart';
// import '../../theme/app_colors.dart';
//
// class CustomLoading extends StatelessWidget {
//   const CustomLoading({
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.black12,
//       body: Center(
//         child: Material(
//           color: AppColors.white,
//           borderRadius: BorderRadius.circular(10),
//           child: Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: AppColors.white,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Lottie.asset(
//                   'assets/lottie/Food Loading Animation.json',
//                   width: 150,
//                   height: 150,
//                   fit: BoxFit.contain,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   "Please wait...",
//                   // style: getSemiBoldStyle(color: AppColors.textColor, fontSize: 20),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/fonts_manager.dart';
import '../../theme/textfont_styles.dart';

class CustomLoading extends StatelessWidget {
  const CustomLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black12,
      body: Center(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 190,
            padding: const EdgeInsets.symmetric(
              vertical: 22,
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.softShadow08,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRect(
                  child: SizedBox(
                    width: 130,
                    height: 130,
                    child: Transform.scale(
                      scale: 1.6,
                      child: Lottie.asset(
                        'assets/lottie/Food Loading Animation.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Please wait...",
                  style: getSemiBoldStyle(
                    color: AppColors.text,
                    fontSize: MyFonts.size13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}