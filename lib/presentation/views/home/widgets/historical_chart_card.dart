import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/asset_quote_model.dart';
import '../../../../data/models/history_point_model.dart';

class HistoricalChartCard extends StatelessWidget {
  final AssetQuoteModel quote;
  final List<HistoryPointModel> history;
  final String selectedPeriod;
  final List<String> periods;
  final void Function(String) onPeriodChanged;

  const HistoricalChartCard({
    super.key,
    required this.quote,
    required this.history,
    required this.selectedPeriod,
    required this.periods,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isUp = quote.direction.toLowerCase() == 'subindo';
    final lineColor = isUp ? AppColors.gain : AppColors.loss;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final spots = history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.close);
    }).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.divider : Colors.grey.shade200,
          width: 0.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quote.ticker,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      Formatters.currency(quote.priceUsd),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: lineColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: lineColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUp
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: lineColor,
                      size: 14,
                    ),
                    Text(
                      isUp ? 'Alta' : 'Baixa',
                      style: TextStyle(
                        color: lineColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Period tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: periods.map((p) {
              final selected = p == selectedPeriod;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onPeriodChanged(p);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? lineColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    p,
                    style: TextStyle(
                      color: selected
                          ? (isUp ? Colors.black : Colors.white)
                          : AppColors.textSecondary,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Chart
          SizedBox(
            height: 160,
            child: spots.isEmpty
                ? Center(
                    child: Text(
                      'Sem dados',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _calcInterval(spots),
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: isDark
                              ? AppColors.divider
                              : Colors.grey.shade200,
                          strokeWidth: 0.5,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 52,
                            getTitlesWidget: (val, _) => Text(
                              Formatters.currency(val),
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 9),
                            ),
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (spots) {
                            return spots.map((s) {
                              final idx = s.x.toInt();
                              final dateStr = idx < history.length
                                  ? Formatters.date(history[idx].date)
                                  : '';
                              return LineTooltipItem(
                                '${Formatters.currency(s.y)}\n$dateStr',
                                const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: lineColor,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                lineColor.withOpacity(0.25),
                                lineColor.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  ),
          ),
        ],
      ),
    );
  }

  double _calcInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;
    final max = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final min = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final range = max - min;
    return range <= 0 ? 1 : range / 4;
  }
}
