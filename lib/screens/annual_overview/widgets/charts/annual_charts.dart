import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../models/time_registration.dart';

class AnnualCharts extends StatelessWidget {
  final List<TimeRegistration> registrations;
  final int selectedYear;
  final String? selectedRestaurantId;

  const AnnualCharts({
    super.key,
    required this.registrations,
    required this.selectedYear,
    this.selectedRestaurantId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withAlpha(25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uren Analyse',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Uren per Maand',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _buildMonthlyChart(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verdeling per Dag',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _buildWeekdayChart(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context) {
    final theme = Theme.of(context);
    final monthlyData = _calculateMonthlyHours();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outline.withAlpha(25),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _getMonthAbbreviation(value.toInt()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: monthlyData.asMap().entries.map((entry) {
              return FlSpot(entry.key + 1, entry.value);
            }).toList(),
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withAlpha(25),
            ),
          ),
        ],
      ),
    );
  }

  List<double> _calculateMonthlyHours() {
    final monthlyHours = List<double>.filled(12, 0);

    for (final reg in registrations.where((r) => r.date.year == selectedYear)) {
      final month = reg.date.month - 1;
      double hours = reg.endTime.hour + reg.endTime.minute / 60.0;
      double start = reg.startTime.hour + reg.startTime.minute / 60.0;

      if (hours < start) hours += 24;
      monthlyHours[month] += hours - start;
    }

    return monthlyHours;
  }

  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mrt';
      case 4:
        return 'Apr';
      case 5:
        return 'Mei';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Okt';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  Widget _buildWeekdayChart(BuildContext context) {
    final weekdayData = _calculateWeekdayHours();

    return BarChart(
      BarChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0) return const Text('');
                return Text(_getWeekdayAbbreviation(value.toInt()));
              },
            ),
          ),
        ),
        barGroups: weekdayData.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getWeekdayAbbreviation(int day) {
    switch (day) {
      case 1:
        return 'Ma';
      case 2:
        return 'Di';
      case 3:
        return 'Wo';
      case 4:
        return 'Do';
      case 5:
        return 'Vr';
      case 6:
        return 'Za';
      case 7:
        return 'Zo';
      default:
        return '';
    }
  }

  List<double> _calculateWeekdayHours() {
    final weekdayHours = List<double>.filled(7, 0);

    for (final reg in registrations.where((r) => r.date.year == selectedYear)) {
      final weekday = reg.date.weekday - 1;
      double hours = reg.endTime.hour + reg.endTime.minute / 60.0;
      double start = reg.startTime.hour + reg.startTime.minute / 60.0;

      if (hours < start) hours += 24;
      weekdayHours[weekday] += hours - start;
    }

    return weekdayHours;
  }
}
