import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyExpenseChart extends StatelessWidget {
  final Map<String, double> monthlyExpenses;

  const MonthlyExpenseChart({super.key, required this.monthlyExpenses});

  @override
  Widget build(BuildContext context) {
    if (monthlyExpenses.isEmpty) {
      return const Center(child: Text("No data"));
    }

    final keys = monthlyExpenses.keys.toList();
    final values = monthlyExpenses.values.toList();

    double maxValue = 0;
    for (final v in values) {
      if (v > maxValue) maxValue = v;
    }

    final maxY = (maxValue <= 0) ? 100 : (maxValue * 1.2);

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: SizedBox(
        height: 260,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            alignment: BarChartAlignment.spaceAround,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(10),
                tooltipMargin: 10,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final month = keys[group.x.toInt()];
                  final value = rod.toY;
                  return BarTooltipItem(
                    "$month\n\$${value.toStringAsFixed(0)}",
                    const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.black.withOpacity(0.06),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= keys.length) {
                      return const SizedBox.shrink();
                    }

                    final label = keys[index];

                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 6,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black.withOpacity(0.55),
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  interval: maxY / 4,
                  getTitlesWidget: (value, meta) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 6,
                      child: Text(
                        "\$${value.toInt()}",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black.withOpacity(0.55),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(keys.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: values[index],
                    width: 16,
                    borderRadius: BorderRadius.circular(6),
                    color: const Color.fromRGBO(66, 150, 144, 1),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: Colors.black.withOpacity(0.04),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
