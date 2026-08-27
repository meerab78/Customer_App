import 'dart:io';

import 'package:customer_app/features/profile/profile_entry_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/address/controller.dart';
import 'features/auth/address/manager_controller.dart';
import 'features/auth/address/view.dart';
import 'features/auth/controller.dart';
import 'features/auth/splash/view.dart';
import 'core/db/sqflite/controller.dart';
import 'features/cart/controller.dart';
import 'features/home/controller.dart';
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

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Customer App',
        theme: ThemeData(),
        home: const SplashView(),
      ),
    );
  }
}
