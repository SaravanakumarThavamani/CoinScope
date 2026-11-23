import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:crypto_research_app/app/core/theme/app_theme.dart';

class Sparkline extends StatelessWidget {
  final List<double> data;
  final bool positive;
  final double width;
  final double height;
  const Sparkline({
    super.key,
    required this.data,
    required this.positive,
    this.width = 64,
    this.height = 28,
  });

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) return SizedBox(width: width, height: height);
    final color = positive ? AppColors.up : AppColors.down;
    return SizedBox(
      width: width,
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i])],
              isCurved: true,
              curveSmoothness: 0.2,
              color: color,
              barWidth: 1.6,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
