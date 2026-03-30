import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:split_wise_app/core/constants/firestore_paths.dart';

class GroupsFirestoreServices {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get groupsCol =>
      _db.collection(FirestorePaths.groups);

  CollectionReference<Map<String, dynamic>> membersCol(String groupId) =>
      groupsCol.doc(groupId).collection('members');

  Future<String> createGroup({
    required String name,
    required String createdBy,
    required List<String> memberPhones,
  }) async {
    final ref = groupsCol.doc();
    await ref.set({
      'name': name,
      'createdBy': createdBy,
      'memberPhones': memberPhones,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchGroupsForUser(String phone) {
    return groupsCol
        .where('memberPhones', arrayContains: phone)
        .snapshots();
  }

  Future<void> updateGroup({
    required String groupId,
    required Map<String, dynamic> patch,
  }) async {
    await groupsCol.doc(groupId).update({
      ...patch,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteGroup(String groupId) async {
    await groupsCol.doc(groupId).delete();
  }

  Future<void> addMember({
    required String groupId,
    required String phone,
    required String fullName,
    String? email,
  }) async {
    await membersCol(groupId).doc(phone).set({
      'phone': phone,
      'fullName': fullName,
      'email': email,
      'joinedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMembers(String groupId) {
    return membersCol(groupId).snapshots();
  }

  Future<void> updateMember({
    required String groupId,
    required String phone,
    required Map<String, dynamic> patch,
  }) async {
    await membersCol(groupId).doc(phone).update(patch);
  }

  Future<void> removeMember({
    required String groupId,
    required String phone,
  }) async {
    await membersCol(groupId).doc(phone).delete();
  }
}