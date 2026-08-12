import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';

class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ===========================================================================
  // 1. BRAND & PALETTE BASE (Source of Truth)
  // ===========================================================================
  static const Color logoColor1 = Color(0xFF2B396B); // Primary Dark Blue
  static const Color logoColor2 = Color(0xFF090D2B); // Secondary Deep Navy
  static const Color logoColor3 = Color(0xFF9C793F); // Gold / Accent
  static const Color logoColor4 = Color(0xFFF7EBC2); // Cream / Warm White
  static const Color logoColor5 = Color(0xFF000000); // Pure Black

  // Direct Brand Accessors
  static Color get primary => logoColor1;
  static Color get secondary => logoColor2;
  static Color get tertiary => logoColor3;
  static Color get quaternary => logoColor4;
  static Color get quinary => logoColor5;

  // Primary Variants
  static Color get primaryColor =>
      ThemeService.instance.isDarkMode ? const Color(0xFFFFFFFF) : logoColor3;
  static Color get primaryColor1 => logoColor3;

  // ===========================================================================
  // 2. BACKGROUNDS & SURFACES
  // ===========================================================================
  static Color get background =>
      ThemeService.instance.isDarkMode ? const Color(0xFF121212) : Colors.white;
  static Color get bgColor => background; // Alias for backward compatibility
  static Color get bgColor1 =>
      ThemeService.instance.isDarkMode ? Colors.white : logoColor4;

  static Color get card =>
      ThemeService.instance.isDarkMode ? logoColor4 : Colors.white;
  static Color get cardColor => card; // Alias

  // Container Surface Variants
  static Color get containerColor => ThemeService.instance.isDarkMode
      ? logoColor5
      : Colors.grey.withOpacity(.6);

  static Color get containerColor1 => ThemeService.instance.isDarkMode
      ? const Color(0xFF121212).withOpacity(0.1)
      : const Color(0xFFFFFEFB);

  static Color get containerColor2 => ThemeService.instance.isDarkMode
      ? Colors.grey.shade700
      : Colors.grey.withOpacity(.1);

  static Color get containerColor3 => ThemeService.instance.isDarkMode
      ? Colors.grey.shade700
      : Colors.grey.shade300;

  static Color get containerColor4 =>
      ThemeService.instance.isDarkMode ? logoColor5 : Colors.grey.shade200;

  static Color get containerColor5 => ThemeService.instance.isDarkMode
      ? const Color(0xFF252525)
      : Colors.grey.withOpacity(.1);

  static Color get containerColor6 => ThemeService.instance.isDarkMode
      ? const Color(0xFF252525)
      : const Color(0xFFFDFAF4);

  static Color get containerColor7 => ThemeService.instance.isDarkMode
      ? const Color(0xFF252525)
      : logoColor3.withOpacity(0.3);

  static Color get containerColor8 => ThemeService.instance.isDarkMode
      ? const Color(0xFF252525)
      : const Color(0xFFFFFFFF);

  static Color get addRemoveContainerColor => tertiary;

  // ===========================================================================
  // 3. TEXT & ICONS
  // ===========================================================================
  static Color get text =>
      ThemeService.instance.isDarkMode ? Colors.white : Colors.black;
  static Color get textColor => text; // Alias

  static Color get greyText => ThemeService.instance.isDarkMode
      ? const Color(0xFF7E7E7E)
      : const Color(0xFF7C7D7E);
  static Color get textColor2 => greyText; // Alias

  static Color get textColor1 =>
      ThemeService.instance.isDarkMode ? const Color(0xFFB0B0B0) : logoColor5;

  static Color get textColor3 =>
      ThemeService.instance.isDarkMode ? Colors.white : logoColor1;

  static Color get textColorPrimary =>
      ThemeService.instance.isDarkMode ? primary : tertiary;

  static Color get iconColor =>
      ThemeService.instance.isDarkMode ? Colors.white : Colors.black;

  static Color get iconColorBlack =>
      ThemeService.instance.isDarkMode ? Colors.white : Colors.black;

  // Static neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // ===========================================================================
  // 4. BORDERS, DIVIDERS & SHADOWS
  // ===========================================================================
  static Color get border =>
      ThemeService.instance.isDarkMode ? Colors.white : Colors.grey.shade900;
  static Color get borderColor => border; // Alias

  static Color get divider => ThemeService.instance.isDarkMode
      ? Colors.grey.shade900
      : Colors.grey.shade300;
  static Color get borderColor1 => divider; // Alias

  static Color get borderColorGrey => ThemeService.instance.isDarkMode
      ? Colors.transparent
      : Colors.grey.shade300;

  static Color get shadow => ThemeService.instance.isDarkMode
      ? Colors.black.withOpacity(0.4)
      : Colors.black12;

  // ===========================================================================
  // 5. INPUTS & CONTROLS (TextFields, Checkboxes, Radios)
  // ===========================================================================
  static Color get textFieldBorderColor => ThemeService.instance.isDarkMode
      ? borderColorGrey
      : const Color(0xFFA1A1A1);

  static Color get textFieldBorderErrorColor => secondary;
  static Color get textFieldBorderColorSlct => primary;
  static Color get textFieldHintColor => Colors.grey;

  static Color get textFieldPlaceholderColor => ThemeService.instance.isDarkMode
      ? const Color(0xFFF2F2F2)
      : const Color(0xFFB6B7B7);

  static Color get textFieldTextColor =>
      ThemeService.instance.isDarkMode ? Colors.white : logoColor3;

  static Color get textFieldCursorColor => primary;

  static Color get textFieldFillColor => ThemeService.instance.isDarkMode
      ? Colors.grey.shade800
      : const Color(0xFFFFFFFF);

  static Color get textFieldBgColor => background;

  // Selection controls
  static Color get checkboxSelectedBgColor => secondary;
  static Color get checkboxTickColor => tertiary;
  static Color get radioSelectedColor => secondary;

  // ===========================================================================
  // 6. BUTTONS & INTERACTIVES
  // ===========================================================================
  static Color get btnColor => primary;

  static Color get btnTextColor =>
      ThemeService.instance.isDarkMode ? logoColor3 : Colors.white;

  static Color get btnTextColorBlack => logoColor3;
  static Color get btnTextColorWhite => Colors.white;

  static Color get splashColor => primary.withOpacity(0.3);
  static Color get splashColor1 => primary.withOpacity(0.3);

  // ===========================================================================
  // 7. COMPONENT SPECIFICS (Search, Nav, AppBar, Shimmer, Status)
  // ===========================================================================
  // Status Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);

  // System UI Overlay
  static SystemUiOverlayStyle get systemOverlayStyle =>
      ThemeService.instance.isDarkMode
          ? const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      )
          : const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      );

  static Color get statusBarActiveColor => secondary;
  static Color get statusBarInActiveColor => Colors.grey.withOpacity(.7);

  // Search Bar
  static Color get searchBarBackground =>
      ThemeService.instance.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

  static Color get searchBarBorder =>
      ThemeService.instance.isDarkMode ? primary : const Color(0xFFE0E0E0);

  static Color get searchBarIconColor =>
      ThemeService.instance.isDarkMode ? Colors.white70 : Colors.grey;

  // Category Menu
  static Color get categoryMenuSelectedBg => primary;
  static Color get categoryMenuUnselectedBg =>
      ThemeService.instance.isDarkMode ? Colors.transparent : Colors.white;
  static Color get categoryMenuBorderSelected => primary;
  static Color get categoryMenuBorderUnselected => primary;
  static Color get categoryMenuSelectedText => Colors.white;
  static Color get categoryMenuUnselectedText =>
      ThemeService.instance.isDarkMode ? Colors.white : primary;

  // Navigation & App Bar
  static Color get appBarColor => primary;
  static Color get appBarIconColor => logoColor1;
  static Color get horizontalCardActiveBgColor => appBarColor;

  static Color get navBarColor =>
      ThemeService.instance.isDarkMode ? Colors.grey.shade900 : Colors.white;

  static Color get activeNavBarIconColor => primary;
  static Color get inActiveNavBarIconColor =>
      ThemeService.instance.isDarkMode ? Colors.grey.shade400 : Colors.grey;
  static Color get navBarCartBadgeTextColor => const Color(0xFFFFFFFF);

  // Miscellaneous
  static Color get splashScreenBgColor => tertiary;

  static Color get shimmerBaseColor =>
      ThemeService.instance.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;

  static Color get shimmerHighlightColor =>
      ThemeService.instance.isDarkMode ? Colors.grey[600]! : Colors.grey[100]!;
}