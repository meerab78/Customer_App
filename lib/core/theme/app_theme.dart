import 'package:flutter/material.dart';
import '../constant/app_constants.dart';
import '../db/shared_pref.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService instance = ThemeService._internal();

  factory ThemeService() {
    return instance;
  }

  ThemeService._internal();

  final SharedPrefService _prefs = SharedPrefService();

  // Initialize with the constant. If null, default to system,
  // but Splash will overwrite this immediately anyway.
  ThemeMode themeMode = AppConstants.currentTheme ?? ThemeMode.light;

  bool get isDarkMode {
    return themeMode == ThemeMode.dark;
  }
  Future<void> toggleTheme() async {
    if (themeMode == ThemeMode.dark) {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.dark;
    }

    AppConstants.currentTheme = themeMode;

    // Instant UI update
    notifyListeners();

    await _prefs.saveThemeMode(
      themeMode == ThemeMode.dark ? "dark" : "light",
    );
  }

  // Called by Splash Screen to set the initial state
  void setTheme(ThemeMode mode) {
    themeMode = mode;
    AppConstants.currentTheme = mode;
    notifyListeners();
  }

  Future<void> loadSavedTheme() async {
    final saved = await _prefs.getThemeMode();

    if (saved == "dark") {
      setTheme(ThemeMode.dark);
    } else if (saved == "light") {
      setTheme(ThemeMode.light);
    }
  }
}