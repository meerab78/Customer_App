import 'dart:developer' as developer;
import 'dart:io';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';


class AppConstants {
  static String googleMapBaseUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static String kPlacesApiKey = 'AIzaSyBUbCbmkNfSvQ8nflO64lgaIowblekfTrc';
  // static String kPlacesApiKey = 'AIzaSyBqgE_Gu8x26dFBZBcZvprKOef-X_aiAX4';


  static ThemeMode? currentTheme;

  static String branchId = '';
  static String branchName = '';
  static String restaurantName = '';

  static String deviceId = '';
  static String deviceToken = '';

  static String restaurantId = '1248';


  static String orderResourceId = '3';

  static String currency = 'RS.';

  static String bearerToken = '';
  // static UserResponse? userResponse;


  // static CategoriesResponse? categoriesResponse;
  // static bData? currentBranch;

  static GlobalKey bottomBarKey = GlobalKey();


  static ValueNotifier<double> totalPrice = ValueNotifier(0);
  static ValueNotifier<double> deliveryTotalPrice = ValueNotifier(0);
  static ValueNotifier<double> takeAwayTotalPrice = ValueNotifier(0);
  static ValueNotifier<double> totalPriceAfterCalculatingDiscount =
  ValueNotifier(0);

  static ValueNotifier<String> orderType = ValueNotifier('');
  static ValueNotifier<double> deliveryTotalPriceAfterCalculatingDiscount =
  ValueNotifier(0);
  static ValueNotifier<double> takeAwayTotalPriceAfterCalculatingDiscount =
  ValueNotifier(0);




  static String uppercaseToLowercase(String value) {
    if (value.isEmpty) return "";
    return value
        .split(' ')
        .map((word) => word.isEmpty
        ? ""
        : "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}")
        .join(' ');
  }


  static void printPrettyJson(dynamic data, {String title = 'Menu Response'}) {
    try {
      final object = data is String ? jsonDecode(data) : data;
      final prettyString = const JsonEncoder.withIndent('  ').convert(object);

      developer.log('\n$prettyString', name: title);
    } catch (e) {
      developer.log('Raw output: $data', name: title);
    }
  }



  static Future<T?> navigate<T>(
      BuildContext context,
      Widget page, {
        String type = 'rightToLeft',
        bool keep = false,
        bool replacement = false,
        RoutePredicate? removeUntil,
      }) {
    Offset startOffset;

    switch (type) {
      case 'leftToRight':
        startOffset = const Offset(-2.0, 0.0);
        break;
      case 'bottomToTop':
        startOffset = const Offset(0.0, 2.0);
        break;
      case 'topToBottom':
        startOffset = const Offset(0.0, -2.0);
        break;
      case 'rightToLeft':
      default:
        startOffset = const Offset(2.0, 0.0);
        break;
    }

    final route = PageRouteBuilder<T>(
      settings: RouteSettings(name: page.runtimeType.toString()),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        final tween = Tween(begin: startOffset, end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOut));

        return SlideTransition(position: anim.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );

    if (replacement) {
      return Navigator.pushReplacement<T, T>(context, route);
    }
    if (keep) {
      return Navigator.push<T>(context, route);
    }
    return Navigator.pushAndRemoveUntil<T>(
      context,
      route,
      removeUntil ?? (_) => false,
    );
  }
}
