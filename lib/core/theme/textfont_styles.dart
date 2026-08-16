import 'package:flutter/material.dart';
import 'fonts_manager.dart';

TextStyle _getTextStyle(
  double? fontSize,
  FontWeight fontWeight,
  Color color,
) {
  return TextStyle(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
  );
}

TextStyle getRegularStyle({double? fontSize = 16, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.regular, color);
}

TextStyle getMediumStyle({double? fontSize = 16, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.medium, color);
}

TextStyle getLightStyle({double? fontSize = 14, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.light, color);
}

TextStyle getBoldStyle({double? fontSize = 14, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.bold, color);
}

TextStyle getSemiBoldStyle({double? fontSize = 14, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.semiBold, color);
}

TextStyle getExtraBoldStyle({double? fontSize = 14, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.extraBold, color);
}

TextStyle getBlackStyle({double? fontSize = 14, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.black, color);
}
