import 'package:flutter/material.dart';
import 'package:split_wise_app/features/auth/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? user;
  bool _isBusy = false;

  bool get isBusy => _isBusy;

  AuthProvider() {
    listenAuth();
  }

  void listenAuth() {
    _authService.userChanges.listen((u) {
      user = u;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    _setBusy(true);
    try {
      user = await _authService.login(email, password);
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> signup(String email, String password) async {
    _setBusy(true);
    try {
      user = await _authService.signup(email, password);
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    notifyListeners();
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }
}