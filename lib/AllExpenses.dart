import 'package:basecode/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllExpenses extends StatelessWidget {
  final String userId;

  const AllExpenses({super.key, required this.userId});

  void _deleteExpense(BuildContext context, DocumentSnapshot document) async {
    await FirestoreService(userId).deleteExpense(document.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Expenses",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color.fromRGBO(42, 124, 118, 1),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService(userId).getAllExpensesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenseList = snapshot.data!.docs;

          if (expenseList.isEmpty) {
            return const Center(child: Text("No expenses added"));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            itemCount: expenseList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final document = expenseList[index];
              final data = document.data() as Map<String, dynamic>?;

              if (data == null) return const SizedBox.shrink();

              final name = (data['name'] ?? "").toString();
              final amount = (data['amount'] ?? 0).toDouble();

              return _ExpenseTile(
                name: name.isEmpty ? "Unnamed Expense" : name,
                amount: amount,
                onDelete: () => _deleteExpense(context, document),
              );
            },
          );
        },
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final String name;
  final double amount;
  final VoidCallback onDelete;

  const _ExpenseTile({
    required this.name,
    required this.amount,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(66, 150, 144, 1).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color.fromRGBO(66, 150, 144, 1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Amount: \$${amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_rounded),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
