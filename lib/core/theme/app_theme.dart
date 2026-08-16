// import 'package:flutter/material.dart';
// import 'app_colors.dart';
//
// class AppTheme {
//   AppTheme._();
//
//   static ThemeData lightTheme = ThemeData(
//     useMaterial3: true,
//
//     scaffoldBackgroundColor: AppColors.background,
//
//     colorScheme: ColorScheme.light(
//       primary: AppColors.primary,
//       secondary: AppColors.secondary,
//       surface: AppColors.background,
//     ),
//
//     appBarTheme: const AppBarTheme(
//       backgroundColor: AppColors.background,
//       foregroundColor: AppColors.text,
//       centerTitle: true,
//       elevation: 0,
//       scrolledUnderElevation: 0,
//     ),
//
//     cardTheme: CardThemeData(
//       color: AppColors.card,
//       elevation: 3,
//       shadowColor: AppColors.shadow,
//       margin: EdgeInsets.zero,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(18),
//       ),
//     ),
//
//     dividerColor: AppColors.divider,
//
//     iconTheme: const IconThemeData(
//       color: AppColors.primary,
//       size: 24,
//     ),
//
//     textTheme: const TextTheme(
//       displayLarge: TextStyle(
//         fontSize: 32,
//         fontWeight: FontWeight.bold,
//         color: AppColors.text,
//       ),
//
//       headlineLarge: TextStyle(
//         fontSize: 26,
//         fontWeight: FontWeight.bold,
//         color: AppColors.text,
//       ),
//
//       titleLarge: TextStyle(
//         fontSize: 22,
//         fontWeight: FontWeight.bold,
//         color: AppColors.text,
//       ),
//
//       titleMedium: TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.w600,
//         color: AppColors.text,
//       ),
//
//       bodyLarge: TextStyle(
//         fontSize: 16,
//         color: AppColors.text,
//       ),
//
//       bodyMedium: TextStyle(
//         fontSize: 14,
//         color: AppColors.greyText,
//       ),
//
//       bodySmall: TextStyle(
//         fontSize: 12,
//         color: AppColors.greyText,
//       ),
//
//       labelLarge: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//         color: Colors.white,
//       ),
//     ),
//
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         minimumSize: const Size(double.infinity, 55),
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),
//     ),
//
//     outlinedButtonTheme: OutlinedButtonThemeData(
//       style: OutlinedButton.styleFrom(
//         foregroundColor: AppColors.primary,
//         minimumSize: const Size(double.infinity, 55),
//         side: const BorderSide(
//           color: AppColors.primary,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),
//     ),
//
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: Colors.white,
//
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: 18,
//         vertical: 16,
//       ),
//
//       hintStyle: const TextStyle(
//         color: AppColors.greyText,
//         fontSize: 14,
//       ),
//
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(16),
//         borderSide: const BorderSide(
//           color: AppColors.border,
//         ),
//       ),
//
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(16),
//         borderSide: const BorderSide(
//           color: AppColors.border,
//         ),
//       ),
//
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(16),
//         borderSide: const BorderSide(
//           color: AppColors.primary,
//           width: 1.5,
//         ),
//       ),
//     ),
//     bottomSheetTheme: const BottomSheetThemeData(
//       backgroundColor: Colors.white,
//       elevation: 10,
//       showDragHandle: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(28),
//         ),
//       ),
//     ),
//   );
// }


import 'package:flutter/material.dart';
import '../constant/app_constants.dart';

class ThemeService extends ChangeNotifier {
  // Singleton pattern
  static final ThemeService instance = ThemeService._internal();

  factory ThemeService() {
    return instance;
  }

  ThemeService._internal();

  // Initialize with the constant. If null, default to system,
  // but Splash will overwrite this immediately anyway.
  ThemeMode themeMode = AppConstants.currentTheme ?? ThemeMode.light;

  bool get isDarkMode {
    return themeMode == ThemeMode.dark;
  }

  void toggleTheme() {
    // STRICT TOGGLE: Only swap between Light and Dark.
    // Never set to .system here.
    if (themeMode == ThemeMode.dark) {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.dark;
    }

    // Keep the constant in sync so other logic works
    AppConstants.currentTheme = themeMode;

    // This triggers the INSTANT UI update in main.dart
    notifyListeners();
  }

  // Called by Splash Screen to set the initial state
  void setTheme(ThemeMode mode) {
    themeMode = mode;
    AppConstants.currentTheme = mode;
    notifyListeners();
  }
}

