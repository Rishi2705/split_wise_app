import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dart:async';
import 'package:split_wise_app/core/constants/firestore_paths.dart';
import 'package:split_wise_app/features/expenses/services/friends_firestore_services.dart';
import 'package:split_wise_app/features/group/services/groups_firestore_services.dart';

class GroupProvider extends ChangeNotifier {
  final GroupsFirestoreServices _groupsService = GroupsFirestoreServices();
  final FriendsFirestoreServices _friendsService = FriendsFirestoreServices();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isBusy = false;
  String? _error;
  String? _currentUserPhone;
  String _currentUserName = 'You';
  List<Contact> _contacts = const [];
  StreamSubscription<User?>? _authSub;

  bool get isBusy => _isBusy;
  String? get error => _error;
  String? get currentUserPhone => _currentUserPhone;
  String get currentUserName => _currentUserName;
  List<Contact> get contacts => _contacts;

  GroupProvider() {
    _bindAuthState();
  }

  void _bindAuthState() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        _currentUserPhone = null;
        _currentUserName = 'You';
        _contacts = const [];
        _error = null;
        _isBusy = false;
        notifyListeners();
        return;
      }

      _currentUserPhone = null;
      await init();
    });
  }

  Future<void> init() async {
    if (_currentUserPhone != null) return;
    _setBusy(true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email;
      if (userEmail == null) {
        throw Exception('Current user email not found');
      }

      final snapshot = await _db
          .collection(FirestorePaths.users)
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('User profile not found');
      }

      _currentUserPhone = snapshot.docs.first.id;
      _currentUserName = (snapshot.docs.first.data()['fullName'] ?? 'You').toString();
      _error = null;
    } catch (e) {
      _error = 'Failed to initialize group module: $e';
    } finally {
      _setBusy(false);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchGroups() {
    final currentUserPhone = _currentUserPhone;
    if (currentUserPhone == null) return const Stream.empty();
    return _groupsService.watchGroupsForUser(currentUserPhone);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchFriends() {
    final currentUserPhone = _currentUserPhone;
    if (currentUserPhone == null) return const Stream.empty();
    return _friendsService.watchFriends(currentUserPhone);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchGroupExpenses(String groupId) {
    return _db
        .collection(FirestorePaths.transactions)
        .where('groupId', isEqualTo: groupId)
        .snapshots();
  }

  Future<bool> loadContacts() async {
    try {
      final hasPermission = await FlutterContacts.requestPermission(readonly: true);
      if (!hasPermission) {
        _error = 'Contacts permission denied';
        notifyListeners();
        return false;
      }

      _contacts = await FlutterContacts.getContacts(withProperties: true);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to load contacts: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addFriendFromContact(Contact contact) async {
    final currentUserPhone = _currentUserPhone;
    if (currentUserPhone == null) return false;
    final number = contact.phones.isNotEmpty
        ? contact.phones.first.number.replaceAll(RegExp(r'\s+'), '')
        : '';
    if (number.isEmpty) {
      _error = 'Selected contact has no phone number';
      notifyListeners();
      return false;
    }

    try {
      await _friendsService.addFriend(
        userPhone: currentUserPhone,
        friendPhone: number,
        friendName: contact.displayName,
      );
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add friend from contact: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createGroup({
    required String groupName,
    required List<Map<String, String>> selectedMembers,
  }) async {
    final currentUserPhone = _currentUserPhone;
    if (currentUserPhone == null) {
      _error = 'User not initialized';
      notifyListeners();
      return false;
    }

    _setBusy(true);
    try {
      final members = <Map<String, String>>[
        {
          'phone': currentUserPhone,
          'name': _currentUserName,
        },
        ...selectedMembers
            .where(
              (m) =>
                  (m['phone'] ?? '').trim().isNotEmpty &&
                  (m['phone'] ?? '').trim() != currentUserPhone,
            )
            .map(
              (m) => {
                'phone': (m['phone'] ?? '').trim(),
                'name': (m['name'] ?? 'Friend').trim().isEmpty
                    ? 'Friend'
                    : (m['name'] ?? 'Friend').trim(),
              },
            ),
      ];

      final memberPhones = members
          .map((e) => (e['phone'] ?? '').trim())
          .where((p) => p.isNotEmpty)
          .toSet()
          .toList();

      if (memberPhones.isEmpty) {
        throw Exception('No valid group members selected');
      }

      final groupId = await _groupsService.createGroup(
        name: groupName,
        createdBy: currentUserPhone,
        memberPhones: memberPhones,
      );

      for (final m in members) {
        final phone = (m['phone'] ?? '').trim();
        if (phone.isEmpty) continue;
        await _groupsService.addMember(
          groupId: groupId,
          phone: phone,
          fullName: (m['name'] ?? 'Friend').trim().isEmpty ? 'Friend' : (m['name'] ?? 'Friend').trim(),
        );
      }

      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to create group: $e';
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<bool> addGroupExpense({
    required String groupId,
    required String groupName,
    required List<String> memberPhones,
    required double amount,
    required String splitType,
    required double creatorPercent,
    String? note,
  }) async {
    final currentUserPhone = _currentUserPhone;
    if (currentUserPhone == null) {
      _error = 'User not initialized';
      notifyListeners();
      return false;
    }

    _setBusy(true);
    try {
      if (memberPhones.isEmpty) {
        throw Exception('No members in this group');
      }

      final shares = <String, double>{};
      if (splitType == 'equal') {
        final share = amount / memberPhones.length;
        for (final p in memberPhones) {
          shares[p] = share;
        }
      } else {
        if (creatorPercent <= 0 || creatorPercent >= 100) {
          throw Exception('Creator percent must be between 1 and 99');
        }
        final others = memberPhones.where((p) => p != currentUserPhone).toList();
        if (others.isEmpty) {
          shares[currentUserPhone] = amount;
        } else {
          final creatorShare = amount * (creatorPercent / 100);
          final remainingShare = amount - creatorShare;
          final eachOther = remainingShare / others.length;
          shares[currentUserPhone] = creatorShare;
          for (final p in others) {
            shares[p] = eachOther;
          }
        }
      }

      await _db.collection(FirestorePaths.transactions).add({
        'createdBy': currentUserPhone,
        'participants': memberPhones,
        'amount': amount,
        'type': 'expense',
        'groupId': groupId,
        'groupName': groupName,
        'splitType': splitType,
        'creatorPercent': splitType == 'proportions' ? creatorPercent : null,
        'shares': shares,
        'note': note,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _groupsService.updateGroup(groupId: groupId, patch: {});
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to add group expense: $e';
      return false;
    } finally {
      _setBusy(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
