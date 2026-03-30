import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_wise_app/core/constants/app_icons.dart';
import 'package:split_wise_app/core/constants/strings.dart';
import 'package:split_wise_app/core/widgets/common_app_bar.dart';
import 'package:split_wise_app/features/bottom_nav/provider/bottom_navigation_provider.dart';

import '../../../core/constants/app_colors.dart';

class BottomNavigationScreen extends StatelessWidget {
  const BottomNavigationScreen({super.key});

  Widget _animatedBody(Widget body, int index) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: const Offset(0.03, 0),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(index),
        child: body,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    return Consumer<BottomNavigationProvider>(
      builder: (context, bottomNavigationProviderModel, child) {
        final selectedIndex = bottomNavigationProviderModel.selectedIndex;
        final selectedBody = bottomNavigationProviderModel.bottomItems.elementAt(selectedIndex);

        if (isIOS) {
          return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text(Strings.appName),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: _animatedBody(selectedBody, selectedIndex),
                  ),
                  CupertinoTabBar(
                    currentIndex: selectedIndex,
                    onTap: bottomNavigationProviderModel.onItemTapped,
                    activeColor: AppColors.selectedItemColor,
                    inactiveColor: Colors.grey,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(AppIcons.homeIcon),
                        label: Strings.bottomNavItem1,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(AppIcons.groupIcon),
                        label: Strings.bottomNavItem2,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(AppIcons.activityIcon),
                        label: Strings.bottomNavItem3,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(AppIcons.settingsIcon),
                        label: Strings.bottomNavItem4,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: CommonAppBar(title: Strings.appName.toString()),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(AppIcons.homeIcon),
                label: Strings.bottomNavItem1,
              ),
              BottomNavigationBarItem(
                icon: Icon(AppIcons.groupIcon),
                label: Strings.bottomNavItem2,
              ),
              BottomNavigationBarItem(
                icon: Icon(AppIcons.activityIcon),
                label: Strings.bottomNavItem3,
              ),
              BottomNavigationBarItem(
                icon: Icon(AppIcons.settingsIcon),
                label: Strings.bottomNavItem4,
              ),
            ],
            currentIndex: selectedIndex,
            selectedItemColor: AppColors.selectedItemColor,
            unselectedItemColor: AppColors.unselectedItemColor,
            onTap: bottomNavigationProviderModel.onItemTapped,
          ),
          body: _animatedBody(selectedBody, selectedIndex),
        );
      },
    );
  }
}
