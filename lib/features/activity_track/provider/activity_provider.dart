import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:split_wise_app/core/constants/firestore_paths.dart';
import 'package:split_wise_app/features/activity_track/services/transactions_firestore_services.dart';

class ActivityProvider extends ChangeNotifier {
  final TransactionsFirestoreServices _transactionsService =
      TransactionsFirestoreServices();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _error;
  String? _currentUserPhone;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUserPhone => _currentUserPhone;

  Future<void> init() async {
    if (_currentUserPhone != null) return;
    _setLoading(true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user?.email == null) {
        throw Exception('User email not found');
      }

      final snapshot = await _db
          .collection(FirestorePaths.users)
          .where('email', isEqualTo: user!.email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('User profile not found');
      }

      _currentUserPhone = snapshot.docs.first.id;
      _error = null;
    } catch (e) {
      _error = 'Failed to initialize activity: $e';
    } finally {
      _setLoading(false);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchTransactions() {
    if (_currentUserPhone == null) {
      return const Stream.empty();
    }
    return _transactionsService.watchCurrentUserTransactions(_currentUserPhone!);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
