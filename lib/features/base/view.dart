
import '../../core/db/shared_pref.dart';
import '../../core/shared/widgets/confirmation_dialog.dart';
import '../../core/theme/app_theme.dart' show ThemeService;
import '../Order/order_history_view.dart';
import '../search/view.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';
import '../cart/controller.dart';
import '../cart/view.dart';
import '../profile/profile_entry_view.dart';
import '../home/view.dart';
import 'controller.dart';

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

  bool _isLoggedIn = false;
  bool _isCheckingLogin = true;

  static const int _cartTabIndex = 2;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BaseTabController>().changeTab(widget.initialIndex);
      }
    });

    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final isGuest = await SharedPrefService().getIsGuest();
    if (!mounted) return;
    setState(() {
      _isLoggedIn = (token != null && token.isNotEmpty) && !isGuest;
      _isCheckingLogin = false;
    });
  }

  void _onTabTapped(int index) {
    context.read<BaseTabController>().changeTab(index);
  }

  Widget _cartIcon(int cartCount, int selectedIndex) {
    final isActive = selectedIndex == _cartTabIndex;

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

    if (_isCheckingLogin) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {

        final cartCount = context.watch<CartController>().totalItemCount;
        final selectedIndex = context.watch<BaseTabController>().selectedIndex;

        final screens = <Widget>[
          HomeView(),
          SearchView(),
          CartView(),
          if (_isLoggedIn)
            OrderHistoryView(),
          ProfileEntryView(),
        ];

        final safeIndex = selectedIndex.clamp(0, screens.length - 1);

        return PopScope(
            canPop: false,
          onPopInvoked: (didPop) async {
              if (didPop) return;

              if (safeIndex != 0) {
                context.read<BaseTabController>().changeTab(0);
                return;
              }

              final shouldExit = await ConfirmationDialog.show(
                context: context,
                icon: Icons.exit_to_app_rounded,
                title: 'Exit App?',
                message: 'Are you sure you want to exit?',
                confirmText: 'Exit',
              );
              if (shouldExit == true) {
                exit(0);
              }
            },
            child: Scaffold(
              body: IndexedStack(
                index: safeIndex,
                children: screens,
              ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.navBarColor,
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
                selectedIndex: safeIndex,
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
                  const GButton(
                    icon: Icons.home_outlined,
                    text: 'Home',
                  ),
                  const GButton(
                    icon: Icons.search,
                    text: 'Search',
                  ),
                  GButton(
                    icon: Icons.shopping_cart_outlined,
                    leading: _cartIcon(cartCount, safeIndex),
                    text: 'Cart',
                  ),
                  if (_isLoggedIn)
                    const GButton(
                      icon: Icons.history_outlined,
                      text: 'History',
                    ),
                  const GButton(
                    icon: Icons.person_outline,
                    text: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
        );
      },
    );
  }
}