import 'package:flutter/material.dart';
import 'package:split_wise_app/features/activity_track/screens/activity_screen.dart';
import 'package:split_wise_app/features/group/screens/groups_screens.dart';
import '../../expenses/screens/expenses.dart';
import '../../settings/screens/settings_screen.dart';

class BottomNavigationProvider extends ChangeNotifier {
  int selectedIndex = 0;

  List<Widget> bottomItems = [
    Expenses(),
    GroupsScreens(),
    ActivityScreen(),
    SettingsScreen()


  ];


  void onItemTapped(int index){
    selectedIndex = index;
    notifyListeners();
  }
}
