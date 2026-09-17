//
// import '../../core/db/shared_pref.dart';
// import '../../core/theme/app_theme.dart' show ThemeService;
// import '../cart/order_history_view.dart';
// import '../search/view.dart';
// import 'package:flutter/material.dart';
// import 'package:google_nav_bar/google_nav_bar.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../core/theme/app_colors.dart';
// import '../../core/theme/fonts_manager.dart';
// import '../../core/theme/textfont_styles.dart';
// import '../cart/controller.dart';
// import '../cart/view.dart';
// import '../profile/profile_entry_view.dart';
// import '../home/view.dart';
// import 'controller.dart';
//
// class BaseView extends StatefulWidget {
//   final int initialIndex;
//
//   const BaseView({
//     super.key,
//     this.initialIndex = 0,
//   });
//
//   @override
//   State<BaseView> createState() =>
//       _BaseViewState();
// }
//
// class _BaseViewState
//     extends State<BaseView> {
//
//   late int _selectedIndex;
//
//   bool _isLoggedIn = false;
//   bool _isCheckingLogin = true;
//
//   // Cart tab is always at this fixed position (Home, Search, Cart, ...)
//   static const int _cartTabIndex = 2;
//
//   @override
//   void initState() {
//     super.initState();
//     // _selectedIndex = widget.initialIndex;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         context.read<BaseTabController>().changeTab(widget.initialIndex);
//       }
//     });
//     _checkLogin();
//   }
//
//   // Check whether user is logged in
//   Future<void> _checkLogin() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     final isGuest = await SharedPrefService().getIsGuest();
//     if (!mounted) return;
//     setState(() {
//       _isLoggedIn = (token != null && token.isNotEmpty) && !isGuest;
//       _isCheckingLogin = false;
//     });
//   }
//   // Bottom navigation tab change
//   void _onTabTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   // Cart icon with item-count badge
//   Widget _cartIcon(int cartCount) {
//     final isActive = _selectedIndex == _cartTabIndex;
//
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         Icon(
//           Icons.shopping_cart_outlined,
//           color: isActive ? AppColors.white : AppColors.grey,
//         ),
//
//         if (cartCount > 0)
//           Positioned(
//             right: -8,
//             top: -6,
//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 5,
//                 vertical: 1,
//               ),
//               constraints: const BoxConstraints(
//                 minWidth: 16,
//                 minHeight: 16,
//               ),
//               decoration: BoxDecoration(
//                 color: AppColors.error,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: AppColors.white,
//                   width: 1.4,
//                 ),
//               ),
//               alignment: Alignment.center,
//               child: Text(
//                 cartCount > 9 ? '9+' : '$cartCount',
//                 style: getBoldStyle(
//                   fontSize: MyFonts.size9,
//                   color: AppColors.white,
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     // Show loading while checking login
//     if (_isCheckingLogin) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }
//
//     return ListenableBuilder(
//       listenable: ThemeService.instance,
//       builder: (context, _) {
//
//         final cartCount = context.watch<CartController>().totalItemCount;
//         final selectedIndex = context.watch<BaseTabController>().selectedIndex;
//
//         // Screens
//         final screens = <Widget>[
//           // 0 - Home
//           HomeView(),
//           // 1 - Search
//           SearchView(),
//           // 2 - Cart
//           CartView(),
//           // 3 - History
//           if (_isLoggedIn)
//
//             OrderHistoryView(),
//
//           // Last - Profile
//           ProfileEntryView(),
//         ];
//         final safeIndex = selectedIndex.clamp(0, screens.length - 1);
//         return Scaffold(
//           body: IndexedStack(
//             index: safeIndex,
//             children: screens,
//           ),
//           bottomNavigationBar: Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 8,
//             ),
//             decoration: BoxDecoration(
//               color: AppColors.navBarColor,
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.softShadow08,
//                   blurRadius: 10,
//                   offset: const Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: SafeArea(
//               top: false,
//               child: GNav(
//                 selectedIndex: safeIndex,
//                 onTabChange: _onTabTapped,
//                 gap: 6,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 12,
//                 ),
//                 duration: const Duration(
//                   milliseconds: 300,
//                 ),
//                 tabBorderRadius: 20,
//                 activeColor: AppColors.white,
//                 color: AppColors.grey,
//                 tabBackgroundColor: AppColors.primary,
//                 tabs: [
//                   // Home
//                   const GButton(
//                     icon: Icons.home_outlined,
//                     text: 'Home',
//                   ),
//                   // Search
//                   const GButton(
//                     icon: Icons.search,
//                     text: 'Search',
//                   ),
//
//                   // Cart (with item-count badge)
//                   GButton(
//                     icon: Icons.shopping_cart_outlined,
//                     leading: _cartIcon(cartCount),
//                     text: 'Cart',
//                   ),
//
//                   // History
//                   if (_isLoggedIn)
//                     const GButton(
//                       icon: Icons.history_outlined,
//                       text: 'History',
//                     ),
//
//                   // Profile
//                   const GButton(
//                     icon: Icons.person_outline,
//                     text: 'Profile',
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
import '../../core/db/shared_pref.dart';
import '../../core/theme/app_theme.dart' show ThemeService;
import '../cart/order_history_view.dart';
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

        return Scaffold(
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
        );
      },
    );
  }
}