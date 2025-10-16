import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    fontFamily: "Ubuntu",
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: Constants.primaryColor,
    canvasColor: Constants.greyColor,
    scaffoldBackgroundColor: Constants.whiteColor,
    colorScheme: ColorScheme.light(
      primary: Constants.primaryColor,
      secondary: Constants.secondaryColor,
      tertiary: Constants.ternaryColor,
    ),
    dataTableTheme: DataTableThemeData(
      dataTextStyle: TextStyle(color: Constants.blackColor),
    ),
    cardTheme: CardTheme(color: Constants.whiteColor),
  );

  static final darkTheme = ThemeData(
    fontFamily: "Ubuntu",
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: Constants.primaryColor,
    canvasColor: Constants.canvasColor,
    scaffoldBackgroundColor: Constants.scaffoldBackgroundColor,
    colorScheme: ColorScheme.dark(
      primary: Constants.primaryColor,
      secondary: Constants.secondaryColor,
      tertiary: Constants.ternaryColor,
      surface: Constants.accentCanvasColor,
      background: Constants.scaffoldBackgroundColor,
    ),
    dataTableTheme: DataTableThemeData(
      dataTextStyle: TextStyle(color: Constants.whiteColor),
    ),
    cardTheme: CardTheme(color: Constants.accentCanvasColor),
  );
}
