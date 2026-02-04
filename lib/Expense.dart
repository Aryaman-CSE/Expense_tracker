import 'package:flutter/material.dart';
import 'package:basecode/firestore.dart';

class Expense extends StatefulWidget {
  final double currentBalance;
  final String userId; // Add userId

  const Expense({super.key, required this.currentBalance, required this.userId});

  @override
  State<Expense> createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  final TextEditingController _expenseNameController = TextEditingController();
  final TextEditingController _expenseAmountController = TextEditingController();
  late final FirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService(widget.userId); // Initialize with userId
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height),
              painter: CurvedRectanglePainter(),
            ),
            Column(
              children: <Widget>[
                const SizedBox(
                  height: 100,
                ),
                Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 10,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      elevation: 1000,
                      backgroundColor: const Color.fromRGBO(66, 150, 144, 1),
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.arrow_back_ios),
                    ),
                    const SizedBox(width: 85),
                    const Text(
                      'Add Expense',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    )
                  ],
                )
              ],
            ),
            Positioned(
                top: 200,
                bottom: 200,
                left: 30,
                right: 30,
                child: Container(
                    height: 300,
                    width: 500,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(40)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(1),
                          spreadRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 40,
                        ),
                        const Row(
                          children: <Widget>[
                            SizedBox(
                              width: 40,
                            ),
                            Text(
                              'Expense',
                              style: TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(
                              width: 100,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            children: <Widget>[
                              TextField(
                                controller: _expenseNameController,
                                decoration: const InputDecoration(
                                    labelText: 'Expense Name'),
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              TextField(
                                controller: _expenseAmountController,
                                decoration: const InputDecoration(
                                    labelText: 'Amount'),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(
                                height: 100,
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    String expenseName =
                                        _expenseNameController.text;
                                    double? amount = double.tryParse(
                                        _expenseAmountController.text);
                                    if (expenseName.isNotEmpty &&
                                        amount != null) {
                                      if (amount <= widget.currentBalance) {
                                        _firestoreService.addExpense(
                                            expenseName, amount);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Expense added successfully')));
                                        _expenseNameController.clear();
                                        _expenseAmountController.clear();
                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Insufficient balance')));
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('Enter valid data')));
                                    }
                                  },
                                  child: const Text('Add Expense'))
                            ],
                          ),
                        ),
                      ],
                    )))
          ],
        ),
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
    path.quadraticBezierTo(size.width / 2, curveHeight + size.height * 0.1,
        size.width, curveHeight);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
