import 'package:basecode/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllExpenses extends StatelessWidget {
  final String userId; // Add userId

  const AllExpenses({super.key, required this.userId}); // Initialize userId

  void _deleteExpense(BuildContext context, DocumentSnapshot document) async {
    Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
    if (data != null && data['amount'] != null) {
      await FirestoreService(userId).deleteExpense(document.id); // Pass userId to FirestoreService

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense deleted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Expenses',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color.fromRGBO(42, 124, 118, 1),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService(userId).getAllExpensesStream(), // Pass userId to FirestoreService
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No expenses added'));
          } else {
            List<DocumentSnapshot> expenseList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: expenseList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = expenseList[index];
                Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

                if (data == null) {
                  return const ListTile(
                    title: Text('No data'),
                  );
                }

                String? expenseName = data['name'] as String?;
                double? expenseAmount = data['amount']?.toDouble();

                if (expenseName == null || expenseAmount == null) {
                  return const ListTile(
                    title: Text('Invalid data'),
                  );
                }

                return ListTile(
                  title: Text(expenseName),
                  subtitle: Text('Amount: \$${expenseAmount.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteExpense(context, document);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
