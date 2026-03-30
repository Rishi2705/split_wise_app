import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:split_wise_app/core/constants/firestore_paths.dart';

class FriendsFirestoreServices {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> friendsCol(String userPhone) =>
      _db.collection(FirestorePaths.users).doc(userPhone).collection('friends');

  Future<void> addFriend({
    required String userPhone,
    required String friendPhone,
    required String friendName,
    String? friendEmail,
  }) async {
    await friendsCol(userPhone).doc(friendPhone).set({
      'friendPhone': friendPhone,
      'friendName': friendName,
      'friendEmail': friendEmail,
      'balanceWithFriend': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchFriends(String userPhone) {
    return friendsCol(userPhone).orderBy('friendName').snapshots();
  }

  Future<void> updateFriend({
    required String userPhone,
    required String friendPhone,
    required Map<String, dynamic> patch,
  }) async {
    await friendsCol(userPhone).doc(friendPhone).update({
      ...patch,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteFriend({
    required String userPhone,
    required String friendPhone,
  }) async {
    await friendsCol(userPhone).doc(friendPhone).delete();
  }
}