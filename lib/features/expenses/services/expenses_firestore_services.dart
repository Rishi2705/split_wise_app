import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:split_wise_app/core/constants/firestore_paths.dart';
import 'package:split_wise_app/core/constants/strings.dart';

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
    final expenseRef = txCol.doc(transactionId);
    final expenseSnapshot = await expenseRef.get();

    if (!expenseSnapshot.exists) {
      throw Exception('Expense transaction not found');
    }

    final expenseData = expenseSnapshot.data() ?? <String, dynamic>{};
    if (expenseData['settled'] == true) {
      return;
    }

    final rawParticipants = (expenseData['participants'] as List<dynamic>? ?? const []);
    final participants = rawParticipants.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    final createdBy = (expenseData['createdBy'] ?? '').toString();
    if (participants.isEmpty && createdBy.isNotEmpty) {
      participants.add(createdBy);
    }

    final amount = (expenseData['amount'] as num?)?.toDouble() ?? 0;
    final settlementRef = txCol.doc();
    final batch = _db.batch();

    batch.update(expenseRef, {
      'settled': true,
      'settledAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(settlementRef, {
      'createdBy': createdBy,
      'participants': participants,
      'friendPhone': expenseData['friendPhone'],
      'friendName': expenseData['friendName'],
      'amount': amount,
      'type': Strings.settlementTypeLabel.toLowerCase(),
      'note': Strings.expenseSettledUpActivity,
      'sourceTransactionId': transactionId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
