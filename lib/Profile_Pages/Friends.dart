import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Friend extends StatelessWidget {
  const Friend({super.key});

  static const String repoUrl = "https://github.com/Aryaman-CSE/Expense_tracker";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invite Friends")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Share this project",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              "Copy the GitHub repo link and send it to your friends.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),

            SelectableText(
              repoUrl,
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () async {
                await Clipboard.setData(const ClipboardData(text: repoUrl));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Repo link copied!")),
                  );
                }
              },
              icon: const Icon(Icons.copy),
              label: const Text("Copy Repo Link"),
            ),
          ],
        ),
      ),
    );
  }
}

