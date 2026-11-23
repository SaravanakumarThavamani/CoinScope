import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:crypto_research_app/app/data/models/chart_data.dart';
import 'package:crypto_research_app/app/core/theme/app_theme.dart';
import 'package:crypto_research_app/app/core/utils/formatters.dart';

class PriceChart extends StatelessWidget {
  final ChartData data;
  final bool rangeLong;
  final ValueChanged<ChartPoint?> onSelect;
  const PriceChart({
    super.key,
    required this.data,
    required this.onSelect,
    this.rangeLong = false,
  });

  @override
  Widget build(BuildContext context) {
    final up = data.changePercent >= 0;
    final color = up ? AppColors.up : AppColors.down;
    final minY = data.minPrice;
    final maxY = data.maxPrice;
    final pad = (maxY - minY) * 0.08;
    final spots = [
      for (var i = 0; i < data.points.length; i++)
        FlSpot(i.toDouble(), data.points[i].price),
    ];

    return LineChart(
      LineChartData(
        minY: minY - pad,
        maxY: maxY + pad,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY + pad * 2) / 4,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.border,
            strokeWidth: 0.6,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 58,
              interval: (maxY - minY + pad * 2) / 4,
              getTitlesWidget: (v, meta) {
                if (v == meta.min || v == meta.max) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    Fmt.price(v).replaceAll(RegExp(r'\.00$'), ''),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchCallback: (event, response) {
            if (!event.isInterestedForInteractions ||
                response?.lineBarSpots == null ||
                response!.lineBarSpots!.isEmpty) {
              onSelect(null);
              return;
            }
            final i = response.lineBarSpots!.first.spotIndex;
            if (i >= 0 && i < data.points.length) onSelect(data.points[i]);
          },
          getTouchedSpotIndicator: (bar, indexes) => indexes
              .map(
                (_) => TouchedSpotIndicatorData(
                  FlLine(
                    color: Colors.white54,
                    strokeWidth: 1,
                    dashArray: [3, 3],
                  ),
                  FlDotData(
                    getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                      radius: 5,
                      color: color,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                  ),
                ),
              )
              .toList(),
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF263330),
            tooltipRoundedRadius: 8,
            fitInsideHorizontally: true,
            getTooltipItems: (spots) => spots.map((s) {
              final p = data.points[s.spotIndex];
              return LineTooltipItem(
                '${Fmt.price(p.price)}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                children: [
                  TextSpan(
                    text: Fmt.dateTime(p.time, withTime: !rangeLong),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.normal,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.15,
            color: color,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.28),
                  color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 250),
    );
  }
}
