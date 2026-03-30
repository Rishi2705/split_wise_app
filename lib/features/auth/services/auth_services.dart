import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get userChanges => _auth.authStateChanges();

  Future<User?> login(String email, String password) async {
    final res = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return res.user;
  }

  Future<User?> signup(String email, String password) async {
    final res = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return res.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}