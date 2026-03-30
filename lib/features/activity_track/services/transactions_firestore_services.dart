import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:split_wise_app/core/constants/firestore_paths.dart';

class TransactionsFirestoreServices {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get txCol =>
      _db.collection(FirestorePaths.transactions);

  Future<String> createTransaction({
    required String createdBy,
    required List<String> participants,
    required double amount,
    required String type, // expense / settlement
    String? groupId,
    String? note,
  }) async {
    final ref = txCol.doc();
    await ref.set({
      'createdBy': createdBy,
      'participants': participants,
      'amount': amount,
      'type': type,
      'groupId': groupId,
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCurrentUserTransactions(
      String userPhone,
      ) {
    return txCol
        .where('participants', arrayContains: userPhone)
        .snapshots();
  }

  Future<void> updateTransaction({
    required String txId,
    required Map<String, dynamic> patch,
  }) async {
    await txCol.doc(txId).update({
      ...patch,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTransaction(String txId) async {
    await txCol.doc(txId).delete();
  }
}