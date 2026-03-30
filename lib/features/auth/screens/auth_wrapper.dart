import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:split_wise_app/core/constants/firestore_paths.dart';
import 'package:split_wise_app/features/auth/screens/auth_screen.dart';
import 'package:split_wise_app/features/auth/services/auth_services.dart';
import 'package:split_wise_app/features/details/screens/user_details_screen.dart';

import '../../bottom_nav/screens/bottom_navigation_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<bool> _hasSavedProfile(User user) async {
    final email = user.email ?? '';
    final snapshot = await FirebaseFirestore.instance
        .collection(FirestorePaths.users)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().userChanges,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final firebaseUser = snapshot.data;
        if (firebaseUser == null) {
          return AuthScreen();
        }

        return FutureBuilder<bool>(
          future: _hasSavedProfile(firebaseUser),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final hasProfile = profileSnapshot.data ?? false;
            if (hasProfile) {
              return BottomNavigationScreen();
            }

            return const UserDetailsScreen();
          },
        );
      },
    );
  }
}