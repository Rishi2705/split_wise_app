import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dart:async';
import 'package:split_wise_app/core/constants/firestore_paths.dart';
import 'package:split_wise_app/features/expenses/services/expenses_firestore_services.dart';
import 'package:split_wise_app/features/expenses/services/friends_firestore_services.dart';

class ExpenseProvider extends ChangeNotifier {
	final ExpensesFirestoreServices _expensesService = ExpensesFirestoreServices();
	final FriendsFirestoreServices _friendsService = FriendsFirestoreServices();
	final FirebaseFirestore _db = FirebaseFirestore.instance;

	bool _isBusy = false;
	String? _error;
	String? _currentUserPhone;
	List<Contact> _contacts = const [];
	StreamSubscription<User?>? _authSub;

	bool get isBusy => _isBusy;
	String? get error => _error;
	String? get currentUserPhone => _currentUserPhone;
	List<Contact> get contacts => _contacts;

	ExpenseProvider() {
		_bindAuthState();
	}

	void _bindAuthState() {
		_authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
			if (user == null) {
				_currentUserPhone = null;
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
				throw Exception('Current user email is missing');
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
			_error = null;
		} catch (e) {
			_error = e.toString();
		} finally {
			_setBusy(false);
		}
	}

	Stream<QuerySnapshot<Map<String, dynamic>>> watchFriends() {
		final currentUserPhone = _currentUserPhone;
		if (currentUserPhone == null) {
			return const Stream.empty();
		}
		return _friendsService.watchFriends(currentUserPhone);
	}

	Stream<QuerySnapshot<Map<String, dynamic>>> watchExpenses() {
		final currentUserPhone = _currentUserPhone;
		if (currentUserPhone == null) {
			return const Stream.empty();
		}
		return _expensesService.watchCurrentUserExpenses(currentUserPhone);
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

	Future<bool> addExpense({
		required String friendPhone,
		required String friendName,
		required double amount,
		required String splitType,
		required double payerShare,
		required double friendShare,
		String? note,
	}) async {
		final currentUserPhone = _currentUserPhone;
		if (currentUserPhone == null) {
			_error = 'User is not initialized yet';
			notifyListeners();
			return false;
		}

		_setBusy(true);
		try {
			await _friendsService.addFriend(
				userPhone: currentUserPhone,
				friendPhone: friendPhone,
				friendName: friendName,
			);

			await _expensesService.createExpense(
				createdBy: currentUserPhone,
				friendPhone: friendPhone,
				friendName: friendName,
				amount: amount,
				splitType: splitType,
				payerShare: payerShare,
				friendShare: friendShare,
				note: note,
			);

			final netFriendOwes = friendShare - payerShare;
			await _friendsService.updateFriend(
				userPhone: currentUserPhone,
				friendPhone: friendPhone,
				patch: {'balanceWithFriend': netFriendOwes},
			);

			_error = null;
			return true;
		} catch (e) {
			_error = 'Failed to add expense: $e';
			return false;
		} finally {
			_setBusy(false);
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

	Future<bool> settleExpense({required String transactionId}) async {
		_setBusy(true);
		try {
			await _expensesService.settleExpense(transactionId: transactionId);
			_error = null;
			return true;
		} catch (e) {
			_error = 'Failed to settle expense: $e';
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
