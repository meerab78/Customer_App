
import '../search/view.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';
import '../cart/controller.dart';
import '../cart/view.dart';
import '../profile/profile_entry_view.dart';
import '../home/view.dart';

class BaseView extends StatefulWidget {
  final int initialIndex;

  const BaseView({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<BaseView> createState() =>
      _BaseViewState();
}

class _BaseViewState
    extends State<BaseView> {

  late int _selectedIndex;

  bool _isLoggedIn = false;
  bool _isCheckingLogin = true;

  // Cart tab is always at this fixed position (Home, Search, Cart, ...)
  static const int _cartTabIndex = 2;

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

  // Cart icon with item-count badge
  Widget _cartIcon(int cartCount) {
    final isActive = _selectedIndex == _cartTabIndex;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          Icons.shopping_cart_outlined,
          color: isActive ? AppColors.white : AppColors.grey,
        ),

        if (cartCount > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 1,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.white,
                  width: 1.4,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                cartCount > 9 ? '9+' : '$cartCount',
                style: getBoldStyle(
                  fontSize: MyFonts.size9,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
      ],
    );
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

    final cartCount = context.watch<CartController>().totalItemCount;

    // Screens
    final screens = <Widget>[
      // 0 - Home
      const HomeView(),
      // 1 - Search
      const SearchView(),
      // 2 - Cart
      const CartView(),
      // 3 - History
      if (_isLoggedIn)
        Center(
          child: Text(
            'History',
            style: getBoldStyle(
              fontSize: MyFonts.size24,
              color: AppColors.text,
            ),
          ),
        ),

      // Last - Profile
      const ProfileEntryView(),
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
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.softShadow08,
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
            activeColor: AppColors.white,
            color: AppColors.grey,
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

              // Cart (with item-count badge)
              GButton(
                icon: Icons.shopping_cart_outlined,
                leading: _cartIcon(cartCount),
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