import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final Map<String, Color> categoryColors;
  final String title;

  const PieChartWidget({
    super.key,
    required this.data,
    required this.categoryColors,
    this.title = 'Expense Breakdown',
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No expense data available',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final chartData = data.entries
        .where((e) => e.value > 0)
        .map((e) => PieChartSectionData(
              value: e.value,
              title: '${e.key}\n₹${e.value.toStringAsFixed(0)}',
              color: categoryColors[e.key] ?? Colors.grey,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: chartData,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ],
    );
  }
}
