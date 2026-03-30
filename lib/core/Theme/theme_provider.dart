import 'package:flutter/material.dart';
import 'package:split_wise_app/core/Theme/app_theme.dart';

class AppThemeProvider extends ChangeNotifier{
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  AppBarThemeData get appBarTheme {
    return _themeMode == ThemeMode.dark
        ? AppTheme.darkTheme.appBarTheme
        : AppTheme.lightTheme.appBarTheme;
  }

  void changeTheme(){
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}