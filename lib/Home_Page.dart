import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore.dart'; // Make sure this imports the updated FirestoreService
import 'Expense.dart'; // Ensure this widget accepts userId
import 'AllExpenses.dart'; // Ensure this widget accepts userId
import 'Notification.dart'; // Update if needed

class Home extends StatefulWidget {
  final String userId; // Add userId

  const Home({Key? key, required this.userId}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double _initialBalance = 110000.0;
  double _balance = 1000.0; 
  double _totalExpenses = 0.0;

  FirestoreService get _firestoreService => FirestoreService(widget.userId);

  void _updateBalance(double newBalance) {
    setState(() {
      _balance = newBalance;
    });
  }

  void _deleteExpense(DocumentSnapshot document) async {
    Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
    if (data != null && data['amount'] != null) {
      double amount = data['amount']?.toDouble() ?? 0;
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
          builder: (context) => Expense(userId: widget.userId, currentBalance: _balance),
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
          Positioned(
            top: 200,
            bottom: 480,
            left: 20,
            right: 20,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40)),
                color: Color.fromRGBO(42, 124, 118, 1),
              ),
              height: 50,
              width: 100,
              child: Center(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestoreService.getAllExpensesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _totalExpenses = 0.0;
                      List<DocumentSnapshot> expenseList = snapshot.data!.docs;

                      for (var document in expenseList) {
                        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
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
          Column(
            children: <Widget>[
              const SizedBox(height: 460),
              Row(
                children: <Widget>[
                  const SizedBox(width: 30),
                  const Text(
                    'Transaction History',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
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
                    child: const Text('See all'),
                  ),
                  const SizedBox(width: 30),
                ],
              ),
            ],
          ),
          Positioned(
            top: 70,
            left: 360,
            child: FloatingActionButton(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromRGBO(42, 124, 118, 1),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Notify(),
                  ),
                );
              },
              child: const Icon(Icons.notification_add),
            ),
          ),
          Positioned(
            top: 480,
            left: 20,
            right: 20,
            bottom: 100,
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getLatestExpensesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<DocumentSnapshot> expenseList = snapshot.data!.docs;

                  if (expenseList.isEmpty) {
                    return const Center(
                      child: Text('No expenses added'),
                    );
                  }

                  return Container(
                    height: 400,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
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
                              _deleteExpense(document);
                            },
                          ),
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Positioned(
            bottom: 5,
            right: 185,
            child: Column(
              children: [
                IconButton(
                  onPressed: () => _addExpense(context),
                  icon: const Icon(Icons.add_circle_rounded),
                  color: const Color.fromRGBO(42, 124, 118, 1),
                  iconSize: 60,
                ),
              ],
            ),
          ),
          Positioned(
            top: 370,
            right: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(42, 124, 118, 1),
                elevation: 1000,
              ),
              onPressed: () {
                setState(() {
                  _initialBalance += 1000.0;
                  _balance = _initialBalance - _totalExpenses;
                });
              },
              child: const Text(
                'Update Balance',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const Positioned(
            top: 80,
            left: 20,
            child: Text(
              'Hi There',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
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
    path.quadraticBezierTo(size.width / 2, curveHeight + size.height * 0.1, size.width, curveHeight);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
