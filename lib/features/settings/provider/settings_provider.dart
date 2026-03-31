import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:split_wise_app/features/auth/services/auth_services.dart';
import 'package:split_wise_app/features/details/services/user_firestore_services.dart';
import 'package:split_wise_app/core/constants/firestore_paths.dart';

class SettingsProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserFirestoreServices _userService = UserFirestoreServices();
  final _db = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  User? _currentUser;
  Map<String, dynamic>? _userData;
  String? _userPhone;
  String? _errorMessage;
  bool _isUploadingImage = false;
  StreamSubscription<User?>? _authSub;

  bool get isLoading => _isLoading;
  bool get isUploadingImage => _isUploadingImage;
  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userData => _userData;
  String? get errorMessage => _errorMessage;

  SettingsProvider() {
    _bindAuthState();
  }

  void _bindAuthState() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        _currentUser = null;
        _userData = null;
        _userPhone = null;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      await _initializeData();
    });
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = FirebaseAuth.instance.currentUser;
    _userPhone = null;
    _userData = null;
    _errorMessage = null;

    if (_currentUser != null) {
      await _findUserPhoneByEmail();
      if (_userPhone != null) {
        await fetchUserData();
      } else {
        _errorMessage = 'User phone not found';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _findUserPhoneByEmail() async {
    try {
      final email = _currentUser?.email;
      if (email == null) return;
      
      final snapshot = await _db
          .collection(FirestorePaths.users)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _userPhone = snapshot.docs.first.id;
      }
    } catch (e) {
      print('Error finding user phone: $e');
    }
  }

  Future<void> fetchUserData() async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      if (_userPhone == null) {
        _errorMessage = 'User phone not found';
        return;
      }

      final phone = _userPhone;
      if (phone == null) {
        _errorMessage = 'User phone not found';
        return;
      }

      final userData = await _userService.getUser(phone);
      
      if (userData != null) {
        _userData = userData;
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch user data: ${e.toString()}';
      print('Error fetching user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> pickAndUploadImage() async {
    try {
      _errorMessage = null;
      _isUploadingImage = true;
      notifyListeners();

      final XFile? pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        _isUploadingImage = false;
        notifyListeners();
        return false;
      }

      // Read file as bytes
      final File imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes();
      
      // Convert to base64
      final base64Image = base64Encode(bytes);

      final phone = _userPhone;
      if (phone == null) {
        throw Exception('User phone not found');
      }

      // Update Firestore
      await _userService.updateUser(phone, {
        'photoUrl': 'data:image/jpeg;base64,$base64Image',
      });

      // Refresh user data
      await fetchUserData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to upload image: ${e.toString()}';
      print('Error uploading image: $e');
      return false;
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String? fullName,
    required String? email,
  }) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final phone = _userPhone;
      if (phone == null) {
        throw Exception('User phone not found');
      }
      
      // Build update map with only non-null values
      final updateMap = <String, dynamic>{};
      if (fullName != null) updateMap['fullName'] = fullName;
      if (email != null) updateMap['email'] = email;

      if (updateMap.isEmpty) {
        throw Exception('No changes to update');
      }

      // Update Firestore
      await _userService.updateUser(phone, updateMap);

      // Update Firebase Auth email if changed
      if (email != null && _currentUser?.email != email) {
        await _currentUser?.verifyBeforeUpdateEmail(email);
      }

      // Refresh user data
      await fetchUserData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      print('Error updating profile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final currentUser = _currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final email = currentUser.email;
      if (email == null || email.isEmpty) {
        throw Exception('Unable to verify account email');
      }

      // Re-authenticate with old password before allowing password change.
      final credential = EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );
      await currentUser.reauthenticateWithCredential(credential);

      // Update password in Firebase Auth
      await currentUser.updatePassword(newPassword);
      
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        _errorMessage = 'Old password is incorrect';
      } else {
        _errorMessage = 'Failed to update password: ${e.message ?? e.code}';
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update password: ${e.toString()}';
      print('Error updating password: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      await _authService.logout();
      _currentUser = null;
      _userData = null;
      _userPhone = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to logout: ${e.toString()}';
      print('Error during logout: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final phone = _userPhone;
      if (phone == null) {
        throw Exception('User phone not found');
      }

      // Delete from Firestore
      await _userService.deleteUser(phone);

      // Delete Firebase Auth user
      await _currentUser?.delete();

      // Logout
      await _authService.logout();
      _currentUser = null;
      _userData = null;
      _userPhone = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete account: ${e.toString()}';
      print('Error deleting account: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
