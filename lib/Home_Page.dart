import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore.dart';
import 'Expense.dart';
import 'AllExpenses.dart';
import 'Notification.dart';

class Home extends StatefulWidget {
  final String userId;

  const Home({super.key, required this.userId});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double _initialBalance = 110000.0;
  double _totalExpenses = 0.0;

  FirestoreService get _firestoreService => FirestoreService(widget.userId);

  double get _balance => _initialBalance - _totalExpenses;

  void _deleteExpense(DocumentSnapshot document) async {
    final data = document.data() as Map<String, dynamic>?;
    if (data == null) return;

    final amount = (data['amount'] ?? 0).toDouble();

    await _firestoreService.deleteExpense(document.id);

    setState(() {
      _totalExpenses -= amount;
      if (_totalExpenses < 0) _totalExpenses = 0;
    });
  }

  void _addExpense(BuildContext context) {
    if (_balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance to add new expense')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Expense(
          userId: widget.userId,
          currentBalance: _balance,
        ),
      ),
    );
  }

  void _updateBalance() {
    setState(() {
      _initialBalance += 1000.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(42, 124, 118, 1),
        foregroundColor: Colors.white,
        onPressed: () => _addExpense(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _TopHeader(
              onNotificationTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Notify()),
                );
              },
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestoreService.getAllExpensesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _InfoCard(
                      title: "Error",
                      subtitle: snapshot.error.toString(),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const _LoadingCard();
                  }

                  final expenseList = snapshot.data!.docs;

                  double total = 0.0;
                  for (final document in expenseList) {
                    final data = document.data() as Map<String, dynamic>?;
                    if (data == null) continue;
                    total += (data['amount'] ?? 0).toDouble();
                  }

                  _totalExpenses = total;

                  return _BalanceCard(
                    balance: _balance,
                    totalExpenses: _totalExpenses,
                    onUpdateBalance: _updateBalance,
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    "Transaction History",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllExpenses(userId: widget.userId),
                        ),
                      );
                    },
                    child: const Text("See all"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getLatestExpensesStream(),
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
                          onDelete: () => _deleteExpense(document),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;

  const _TopHeader({required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(66, 150, 144, 1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Hi There 👋",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: onNotificationTap,
            icon: const Icon(Icons.notifications_active_rounded),
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  final double totalExpenses;
  final VoidCallback onUpdateBalance;

  const _BalanceCard({
    required this.balance,
    required this.totalExpenses,
    required this.onUpdateBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(42, 124, 118, 1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Balance",
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "\$${balance.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Total Expenses: \$${totalExpenses.toStringAsFixed(2)}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onUpdateBalance,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: const Color.fromRGBO(42, 124, 118, 1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text(
                "Update Balance (+1000)",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
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

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(42, 124, 118, 1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(subtitle),
        ],
      ),
    );
  }
}
