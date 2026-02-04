import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyExpenseChart extends StatelessWidget {
  final Map<String, double> monthlyExpenses;

  const MonthlyExpenseChart({super.key, required this.monthlyExpenses});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, titleMeta) {
                return SideTitleWidget(
                  axisSide: titleMeta.axisSide,
                  space: 4,
                  child: Text(
                    monthlyExpenses.keys.toList()[value.toInt()],
                    style: const TextStyle(
                      color: Color(0xff778899),
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, titleMeta) {
                return SideTitleWidget(
                  axisSide: titleMeta.axisSide,
                  space: 4,
                  child: Text(
                    '\$${value.toInt()}',
                    style: const TextStyle(
                      color: Color(0xff778899),
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: true),
        barGroups: monthlyExpenses.entries.map((entry) {
          return BarChartGroupData(
            x: monthlyExpenses.keys.toList().indexOf(entry.key),
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Colors.blue,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
