import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:split_wise_app/core/constants/app_colors.dart';
import 'package:split_wise_app/features/auth/provider/auth_provider.dart';
import 'package:split_wise_app/features/bottom_nav/provider/bottom_navigation_provider.dart';
import 'package:split_wise_app/features/expenses/provider/expense_provider.dart';
import 'package:split_wise_app/features/settings/provider/settings_provider.dart';
import 'package:split_wise_app/core/constants/app_route_config.dart';
import 'package:split_wise_app/core/Theme/theme_provider.dart';

import 'core/Theme/app_theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final MyAppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = MyAppRouter();
    initialization();
  }

  void initialization() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => BottomNavigationProvider(),
        ),
        ChangeNotifierProvider(create: (context) => ExpenseProvider()),
        ChangeNotifierProvider(create: (context) => AppThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: Consumer<AppThemeProvider>(
        builder: (context, appThemeProvider, _) {
          return MaterialApp.router(
            theme: AppTheme.lightTheme.copyWith(
              platform: isIOS ? TargetPlatform.iOS : TargetPlatform.android,
              cupertinoOverrideTheme: CupertinoThemeData(
                primaryColor: AppColors.appColor,
                scaffoldBackgroundColor: Colors.white,
              ),
            ),
            darkTheme: AppTheme.darkTheme,
            themeMode: appThemeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: _appRouter.router,
          );
        },
      ),
    );
  }
}
