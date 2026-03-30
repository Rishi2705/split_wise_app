import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(

    primaryColor: AppColors.appColor,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      primary: AppColors.appColor,
      secondary: AppColors.appColor,
      seedColor: AppColors.appColor,
      surface: AppColors.backgroundColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.appColor,
      foregroundColor: AppColors.backgroundColor,
    ),
  );

  static final darkTheme = ThemeData(

    primaryColor: AppColors.appColor,
    scaffoldBackgroundColor: AppColors.backgroundColorDark,
    colorScheme: ColorScheme.fromSeed(
      primary: AppColors.appColor,
      secondary: AppColors.appColor,
      surface: AppColors.backgroundColor,
      seedColor: AppColors.appColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.appColor,
      foregroundColor: AppColors.backgroundColor,
    ),
  );
}
