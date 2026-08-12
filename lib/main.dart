import 'dart:io';

import 'package:customer_app/feautures/screens/auth/Login/login_screen.dart';
import 'package:customer_app/feautures/screens/auth/OTP/otp_screen.dart';
import 'package:customer_app/feautures/screens/auth/Profile%20Screen/profile_screen.dart';
import 'package:customer_app/feautures/screens/auth/signup/signup_screen.dart';
import 'package:customer_app/feautures/screens/home/home_screenn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import 'core/provider/address_provider.dart';
import 'core/provider/auth_provider.dart';
import 'core/provider/cart_provider.dart';
import 'core/provider/home_provider.dart';
import 'feautures/screens/auth/splash/screen.dart';
import 'feautures/screens/home/main_navigation_screen.dart';
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
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AddressProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Customer App',
        theme: ThemeData(),
        home: const SplashScreen(),
      ),
    );
  }
}
