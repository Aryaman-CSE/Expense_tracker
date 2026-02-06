import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore.dart';
import 'Expense.dart';
import 'AllExpenses.dart';
import 'Notification.dart';

class Home extends StatefulWidget {
  final String userId;

  const Home({Key? key, required this.userId}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double _initialBalance = 0.0;
  double _balance = 0.0;
  double _totalExpenses = 0.0;

  FirestoreService get _firestoreService => FirestoreService(widget.userId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialBalance();
    });
  }

  Future<void> _setInitialBalance() async {
    final controller = TextEditingController(
      text: _initialBalance == 0 ? "" : _initialBalance.toStringAsFixed(0),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Balance"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Enter balance (example: 50000)",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              if (val == null || val < 0) return;
              Navigator.pop(context, val);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _initialBalance = result;
        _balance = _initialBalance - _totalExpenses;
      });
    }
  }

  void _deleteExpense(DocumentSnapshot document) async {
    final data = document.data() as Map<String, dynamic>?;
    if (data != null && data['amount'] != null) {
      final amount = data['amount']?.toDouble() ?? 0;
      await _firestoreService.deleteExpense(document.id);

      setState(() {
        _totalExpenses -= amount;
        _balance = _initialBalance - _totalExpenses;
      });
    }
  }

  void _addExpense(BuildContext context) {
    if (_balance > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Expense(
            userId: widget.userId,
            currentBalance: _balance,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance to add new expense')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: CurvedRectanglePainter(),
          ),

          // Greeting
          const Positioned(
            top: 80,
            left: 20,
            child: Text(
              'Hi There',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
            ),
          ),

          // Notification button
          Positioned(
            top: 70,
            right: 20,
            child: FloatingActionButton(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromRGBO(42, 124, 118, 1),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Notify()),
                );
              },
              child: const Icon(Icons.notification_add),
            ),
          ),

          // Balance card
          Positioned(
            top: 200,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                color: Color.fromRGBO(42, 124, 118, 1),
              ),
              child: Center(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getAllExpensesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _totalExpenses = 0.0;
                      final expenseList = snapshot.data!.docs;

                      for (final document in expenseList) {
                        final data = document.data() as Map<String, dynamic>?;
                        if (data != null && data['amount'] != null) {
                          _totalExpenses += data['amount']?.toDouble() ?? 0;
                        }
                      }

                      _balance = _initialBalance - _totalExpenses;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Balance: \$${_balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Total Expenses: \$${_totalExpenses.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          ),

          // Update balance button
          Positioned(
            top: 360,
            right: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(42, 124, 118, 1),
                elevation: 10,
              ),
              onPressed: _setInitialBalance,
              child: const Text(
                'Update Balance',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          // Transaction header
          Positioned(
            top: 440,
            left: 20,
            right: 20,
            child: Row(
              children: [
                const Text(
                  'Transaction History',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllExpenses(userId: widget.userId),
                      ),
                    );
                  },
                  child: const Text(
                    'See all',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          // Latest transactions
          Positioned(
            top: 490,
            left: 10,
            right: 10,
            bottom: 90,
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getLatestExpensesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final expenseList = snapshot.data!.docs;

                  if (expenseList.isEmpty) {
                    return const Center(child: Text('No expenses added'));
                  }

                  return ListView.builder(
                    itemCount: expenseList.length,
                    itemBuilder: (context, index) {
                      final document = expenseList[index];
                      final data = document.data() as Map<String, dynamic>?;

                      if (data == null) {
                        return const ListTile(title: Text('No data'));
                      }

                      final expenseName = data['name'] as String?;
                      final expenseAmount = data['amount']?.toDouble();

                      if (expenseName == null || expenseAmount == null) {
                        return const ListTile(title: Text('Invalid data'));
                      }

                      return Card(
                        elevation: 2,
                        child: ListTile(
                          title: Text(expenseName),
                          subtitle: Text(
                            'Amount: \$${expenseAmount.toStringAsFixed(2)}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteExpense(document),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),

          // Add expense button
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: IconButton(
                onPressed: () => _addExpense(context),
                icon: const Icon(Icons.add_circle_rounded),
                color: const Color.fromRGBO(42, 124, 118, 1),
                iconSize: 70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CurvedRectanglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color.fromRGBO(66, 150, 144, 1)
      ..style = PaintingStyle.fill;

    Path path = Path();
    double curveHeight = size.height * 0.3;

    path.moveTo(0, 0);
    path.lineTo(0, curveHeight);
    path.quadraticBezierTo(
      size.width / 2,
      curveHeight + size.height * 0.1,
      size.width,
      curveHeight,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
