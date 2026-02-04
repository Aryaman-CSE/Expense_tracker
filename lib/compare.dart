import 'package:basecode/firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Compare extends StatefulWidget {
  final String userId; // Add userId

  const Compare({super.key, required this.userId});

  @override
  State<Compare> createState() => _CompareState();
}

class _CompareState extends State<Compare> {
  late final FirestoreService firestoreService;

  @override
  void initState() {
    super.initState();
    firestoreService = FirestoreService(widget.userId); // Initialize with userId
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Expenses')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<Map<String, double>>(
          stream: firestoreService.getDailyExpenses(), // Fetch daily expenses based on userId
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data available.'));
            } else {
              return DailyExpenseChart(dailyExpenses: snapshot.data!);
            }
          },
        ),
      ),
    );
  }
}

class DailyExpenseChart extends StatelessWidget {
  final Map<String, double> dailyExpenses;

  const DailyExpenseChart({super.key, required this.dailyExpenses});

  @override
  Widget build(BuildContext context) {
    final List<String> dates = dailyExpenses.keys.toList();
    final List<double> values = dailyExpenses.values.toList();

    return SizedBox(
      height: 900,  // Adjust height as needed
      width: double.infinity,  // Use full width available
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, titleMeta) {
                  final date = dates[value.toInt()];
                  return SideTitleWidget(
                    axisSide: titleMeta.axisSide,
                    space: 4,
                    child: Text(
                      date.substring(5), // Show MM-DD format for better readability
                      style: const TextStyle(
                        color: Color(0xff778899),
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, titleMeta) {
                  return SideTitleWidget(
                    axisSide: titleMeta.axisSide,
                    space: 4,
                    child: Text(
                      '\$${value.toInt()}',
                      style: const TextStyle(
                        color: Color(0xff778899),
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: const Color(0xff37434d),
              width: 1,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                dates.length,
                (index) => FlSpot(index.toDouble(), values[index]),
              ),
              isCurved: true,
              color: Colors.blue,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
