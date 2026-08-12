import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home/home_screenn.dart';
import '../../home/main_navigation_screen.dart';
import 'address_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

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
          builder: (_) => const MainNavigationScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AddressScreen(),
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
              Color(0xFFFFF8EE),
              Color(0xFFF3E5D3),
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
                    style: TextStyle(
                      color: Colors.brown.shade800,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Delicious food, delivered fast ",
                    style: TextStyle(
                      color: Colors.brown.shade600,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 25),

                  const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.brown,
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