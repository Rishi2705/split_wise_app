import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:split_wise_app/core/constants/firestore_paths.dart';

class UserFirestoreServices {
  final _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> userDoc(String phone) =>
      _db.collection(FirestorePaths.users).doc(phone);

  Future<void> createUser({
    required String fullName,
    required String phone,
    required String email,
  }) async {
    await userDoc(phone).set({
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'photoUrl': null,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getUser(String phone) async {
    final snap = await userDoc(phone).get();
    return snap.data();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUser(String phone) {
    return userDoc(phone).snapshots();
  }

  Future<void> updateUser(String phone, Map<String, dynamic> patch) async {
    await userDoc(phone).update({
      ...patch,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteUser(String phone) async {
    await userDoc(phone).delete();
  }


}
