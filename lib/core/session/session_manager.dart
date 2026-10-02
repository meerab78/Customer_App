// core/session/session_manager.dart
import 'package:flutter/material.dart';
import '../db/shared_pref.dart';
import '../../features/base/view.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SessionManager {
  static bool _isHandling = false;
  static const int _profileTabIndex = 3;

  static Future<void> handleUnauthorized() async {
    if (_isHandling) return;
    _isHandling = true;

    try {
      final prefs = SharedPrefService();
      final token = await prefs.getToken();
      if (token == null) return;

      await prefs.clearAuth();

      final ctx = navigatorKey.currentContext;
      if (ctx == null) return;

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const BaseView(initialIndex: _profileTabIndex),
        ),
            (route) => false,
      );

      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Session expired. Please login again.')),
      );
    } finally {
      _isHandling = false;
    }
  }
}