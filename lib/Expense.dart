import 'package:flutter/material.dart';
import 'package:basecode/firestore.dart';

class Expense extends StatefulWidget {
  final double currentBalance;
  final String userId;

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
    _firestoreService = FirestoreService(widget.userId);
  }

  @override
  void dispose() {
    _expenseNameController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  void _submit() async {
    final expenseName = _expenseNameController.text.trim();
    final amountText = _expenseAmountController.text.trim();
    final amount = double.tryParse(amountText);

    if (expenseName.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid expense name and amount")),
      );
      return;
    }

    if (amount > widget.currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Insufficient balance")),
      );
      return;
    }

    await _firestoreService.addExpense(expenseName, amount);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Expense added successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Expense",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color.fromRGBO(66, 150, 144, 1),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(42, 124, 118, 1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Available Balance",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "\$${widget.currentBalance.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 5),
                      color: Colors.black.withOpacity(0.06),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Expense Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _expenseNameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: "Expense Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _expenseAmountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Amount",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor:
                              const Color.fromRGBO(66, 150, 144, 1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: const Text(
                          "Add Expense",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
