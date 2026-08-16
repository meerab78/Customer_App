import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../base/view.dart';
import '../auth/signin/view.dart';
import 'view.dart';

class ProfileEntryView extends StatefulWidget {
  const ProfileEntryView({super.key});

  @override
  State<ProfileEntryView> createState() =>
      _ProfileEntryScreenState();
}

class _ProfileEntryScreenState extends State<ProfileEntryView> {
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
        builder: (_) => const SignInView(),
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
          const BaseView(
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
      return const ProfileView();
    }

    return const SignInView();
  }
}

