import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie/blueloading.json',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  "Please wait...",
                  // style: getSemiBoldStyle(color: AppColors.textColor, fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


