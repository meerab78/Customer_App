import 'dart:io';
import 'package:customer_app/features/profile/profile_entry_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/address/controller.dart';
import 'features/auth/address/manager_controller.dart';
import 'features/auth/address/view.dart';
import 'features/auth/controller.dart';
import 'features/auth/splash/view.dart';
import 'core/db/sqflite/controller.dart';
import 'features/cart/controller.dart';
import 'features/coupon/controller.dart';
import 'features/home/controller.dart';
import 'features/profile/Loyalty_transactions/controller.dart';
import 'features/profile/Wallet/controller.dart';
import 'features/profile/view.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await ThemeService.instance.loadSavedTheme();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeController(),
        ),
        ChangeNotifierProvider(
          create: (_) => AddressController(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthController(),
        ),
        ChangeNotifierProvider(
          create: (_) => DbController(),
        ),
        ChangeNotifierProvider(
          create: (context) => CartController(
            dbController: context.read<DbController>(),
          )..loadCart(),
        ),
        ChangeNotifierProvider(
          create: (_) => AddressManagerController(),
        ),
        ChangeNotifierProvider(
          create: (_) => CouponController(),
        ),
        ChangeNotifierProvider(
          create: (_) => LoyaltyController(),
        ),
        ChangeNotifierProvider(
          create: (_) => WalletController(),
        ),
      ],
      child: ListenableBuilder(
        listenable: ThemeService.instance,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Customer App',
            themeMode: ThemeService.instance.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF121212),
                elevation: 0,
              ),
            ),
            home: const SplashView(),
          );
        },
      ),
    );
  }
}