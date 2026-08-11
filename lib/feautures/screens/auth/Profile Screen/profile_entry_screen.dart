import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home/main_navigation_screen.dart';
import '../Login/login_screen.dart';
import 'profile_screen.dart';

class ProfileEntryScreen extends StatefulWidget {
  const ProfileEntryScreen({super.key});

  @override
  State<ProfileEntryScreen> createState() =>
      _ProfileEntryScreenState();
}

class _ProfileEntryScreenState extends State<ProfileEntryScreen> {
  bool _isCheckingLogin = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (!mounted) return;

    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
      _isCheckingLogin = false;
    });
  }

  Future<void> _openLogin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const MainNavigationScreen(
            initialIndex: 0,
          ),
        ),
      );
    } else {
      _checkLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingLogin) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isLoggedIn) {
      return const ProfileScreen();
    }

    return const LoginScreen();
  }
}