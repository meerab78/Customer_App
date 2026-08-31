import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';

import '../../base/view.dart';
import '../address/view.dart';

class SplashView extends StatefulWidget {

  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashView> {

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    bool isAddressSaved =
        prefs.getBool("address_saved") ?? false;
    if (isAddressSaved) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BaseView(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AddressView(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.splashGradientStart,
              AppColors.splashGradientEnd,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              const SizedBox(),

              Center(
                child: Image.asset(
                  "assets/images/logo.png",
                  height: 200,
                ),
              ),
              //  Bottom section
              Column(
                children: [

                  Text(
                    "QA Restaurant",
                    style: getBoldStyle(
                      color: AppColors.splashTitleColor,
                      fontSize: MyFonts.size26,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Delicious food, delivered fast ",
                    style: getRegularStyle(
                      color: AppColors.splashSubtitleColor,
                      fontSize: MyFonts.size14,
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.splashAccentColor,
                    ),
                  ),

                  const SizedBox(height: 30),
                ],

              ),
            ],
          ),
        ),
      ),
    );
  }
}




