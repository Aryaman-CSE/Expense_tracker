import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final String userId; // Add userId to FirestoreService

  FirestoreService(this.userId);

  // Collection reference with userId
  CollectionReference get expenses => FirebaseFirestore.instance
      .collection('users')
      .doc('userId')
      .collection('expenses');

  Future<void> addExpense(String name, double amount) async {
    await expenses.add({
      'name': name,
      'amount': amount,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> updateExpense(String docId, String name, double amount) {
    return expenses.doc(docId).update({
      'name': name,
      'amount': amount,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> deleteExpense(String docId) {
    return expenses.doc(docId).delete();
  }

  Stream<QuerySnapshot> getLatestExpensesStream() {
    return expenses
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllExpensesStream() {
    return expenses
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<Map<String, double>> getMonthlyExpenses() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final snapshot = await expenses
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    final Map<String, double> monthlyExpenses = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] as num).toDouble();
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final monthYear =
          '${timestamp.month}-${timestamp.year}'; // Use month-year format for aggregation

      if (monthlyExpenses.containsKey(monthYear)) {
        monthlyExpenses[monthYear] = monthlyExpenses[monthYear]! + amount;
      } else {
        monthlyExpenses[monthYear] = amount;
      }
    }

    return monthlyExpenses;
  }

  Stream<Map<String, double>> getDailyExpenses() {
    return expenses.snapshots().map((snapshot) {
      final Map<String, double> dailyExpenses = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['timestamp'] as Timestamp).toDate();
        final dateString =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'; // Format as YYYY-MM-DD

        final amount = (data['amount'] as num).toDouble();
        if (dailyExpenses.containsKey(dateString)) {
          dailyExpenses[dateString] = dailyExpenses[dateString]! + amount;
        } else {
          dailyExpenses[dateString] = amount;
        }
      }
      return dailyExpenses;
    });
  }
}