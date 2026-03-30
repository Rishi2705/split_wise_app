import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:split_wise_app/features/Error/errors_screen.dart';
import 'package:split_wise_app/features/auth/screens/auth_screen.dart';
import 'package:split_wise_app/features/auth/screens/auth_wrapper.dart';
import 'package:split_wise_app/features/bottom_nav/screens/bottom_navigation_screen.dart';
import 'package:split_wise_app/core/constants/app_route_constants.dart';
import 'package:split_wise_app/features/expenses/screens/expenses.dart';
import 'package:split_wise_app/features/group/screens/groups_screens.dart';
import 'package:split_wise_app/features/details/screens/user_details_screen.dart';
import 'package:split_wise_app/features/settings/screens/settings_screen.dart';

class MyAppRouter {
  static Page<dynamic> _buildPage(Widget child, GoRouterState state) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    if (isIOS) {
      return CustomTransitionPage(
        key: state.pageKey,
        child: child,
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      );
    }

    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
    );
  }

  GoRouter router = GoRouter(
    routes: [
      GoRoute(
        name: MyAppRouteConstants.authWrapperRouteName,
        path: '/',
        pageBuilder: (context, state) {
          return _buildPage(AuthWrapper(), state);
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.authScreenRouteName,
        path: '/authScreen',
        pageBuilder: (context, state) {
          return _buildPage(AuthScreen(), state);
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.userDetailsRouteName,
        path: '/userDetails',
        pageBuilder: (context, state) {
          return _buildPage(const UserDetailsScreen(), state);
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.bottomNavRouteName,
        path: '/bottomNav',
        pageBuilder: (context, state) {
          return _buildPage(BottomNavigationScreen(), state);
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.homeRouteName,
        path: '/home',
        pageBuilder: (context, state) {
          return _buildPage(Expenses(), state);
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.groupRouteName,
        path: '/group',
        pageBuilder: (context, state) {
          return _buildPage(GroupsScreens(), state);
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.settingsRouteName,
        path: '/settings',
        pageBuilder: (context, state) {
          return _buildPage(const SettingsScreen(), state);
        },
      ),
    ],
    errorPageBuilder: (context, state) {
      return _buildPage(ErrorsScreen(), state);
    },
  );
}
