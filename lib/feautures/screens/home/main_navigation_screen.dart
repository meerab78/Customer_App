
import 'package:customer_app/feautures/screens/home/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../widgets/cart_screen.dart';
import '../auth/Profile Screen/profile_entry_screen.dart';
import 'home_screenn.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {

  late int _selectedIndex;

  bool _isLoggedIn = false;
  bool _isCheckingLogin = true;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.initialIndex;

    _checkLogin();
  }

  // Check whether user is logged in
  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (!mounted) return;
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
      _isCheckingLogin = false;
    });
  }

  // Bottom navigation tab change
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    // Show loading while checking login
    if (_isCheckingLogin) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Screens
    final screens = <Widget>[
      // 0 - Home
      const HomeScreenn(),
      // 1 - Search
      const SearchScreen(),
      // 2 - Cart
      const CartScreen(),
      // 3 - History
      if (_isLoggedIn)
        const Center(
          child: Text(
            'History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

      // Last - Profile
      const ProfileEntryScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: GNav(
            selectedIndex: _selectedIndex,
            onTabChange: _onTabTapped,
            gap: 6,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            duration: const Duration(
              milliseconds: 300,
            ),
            tabBorderRadius: 20,
            activeColor: Colors.white,
            color: Colors.grey,
            tabBackgroundColor: AppColors.primary,
            tabs: [
              // Home
              const GButton(
                icon: Icons.home_outlined,
                text: 'Home',
              ),
              // Search
              const GButton(
                icon: Icons.search,
                text: 'Search',
              ),

              // Cart
              const GButton(
                icon: Icons.shopping_cart_outlined,
                text: 'Cart',
              ),

              // History
              if (_isLoggedIn)
                const GButton(
                  icon: Icons.history_outlined,
                  text: 'History',
                ),

              // Profile
              const GButton(
                icon: Icons.person_outline,
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}