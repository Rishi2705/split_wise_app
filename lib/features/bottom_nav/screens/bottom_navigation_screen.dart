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

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    return Consumer<BottomNavigationProvider>(
      builder: (context, bottomNavigationProviderModel, child) {
        final selectedIndex = bottomNavigationProviderModel.selectedIndex;
        final bottomItems = bottomNavigationProviderModel.bottomItems;

        if (isIOS) {
          return CupertinoPageScaffold(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: IndexedStack(
                      index: selectedIndex,
                      children: bottomItems,
                    ),
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
          body: IndexedStack(
            index: selectedIndex,
            children: bottomItems,
          ),
        );
      },
    );
  }
}
