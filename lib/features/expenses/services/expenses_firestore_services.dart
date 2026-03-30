import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:split_wise_app/core/constants/firestore_paths.dart';

class ExpensesFirestoreServices {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get txCol =>
      _db.collection(FirestorePaths.transactions);

  Future<String> createExpense({
    required String createdBy,
    required String friendPhone,
    required String friendName,
    required double amount,
    required String splitType,
    required double payerShare,
    required double friendShare,
    String? note,
  }) async {
    final ref = txCol.doc();
    await ref.set({
      'createdBy': createdBy,
      'participants': [createdBy, friendPhone],
      'friendPhone': friendPhone,
      'friendName': friendName,
      'amount': amount,
      'type': 'expense',
      'splitType': splitType,
      'payerShare': payerShare,
      'friendShare': friendShare,
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCurrentUserExpenses(
    String userPhone,
  ) {
    return txCol
        .where('participants', arrayContains: userPhone)
        .snapshots();
  }

  Future<void> settleExpense({required String transactionId}) async {
    await txCol.doc(transactionId).update({
      'settled': true,
      'settledAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
