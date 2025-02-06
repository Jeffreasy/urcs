import 'package:flutter/material.dart';
import '../../../../models/employee.dart';
import '../../../../providers/time_registration_provider.dart';

class MonthHeader extends StatelessWidget {
  final int month;
  final List<Employee> employees;
  final int selectedYear;
  final TimeRegistrationProvider provider;

  const MonthHeader({
    super.key,
    required this.month,
    required this.employees,
    required this.selectedYear,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = _getMonthName();
    final average = _calculateMonthlyAverage();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          monthName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Gem: ${average.toStringAsFixed(1)}u',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  String _getMonthName() {
    return switch (month) {
      1 => 'Jan',
      2 => 'Feb',
      3 => 'Mrt',
      4 => 'Apr',
      5 => 'Mei',
      6 => 'Jun',
      7 => 'Jul',
      8 => 'Aug',
      9 => 'Sep',
      10 => 'Okt',
      11 => 'Nov',
      12 => 'Dec',
      _ => '',
    };
  }

  double _calculateMonthlyAverage() {
    if (employees.isEmpty) return 0;

    double totalHours = 0;
    int count = 0;

    for (final employee in employees) {
      final registrations = provider.registrations.where((reg) =>
          reg.employeeId == employee.id &&
          reg.date.year == selectedYear &&
          reg.date.month == month);

      if (registrations.isNotEmpty) {
        for (final reg in registrations) {
          double start = reg.startTime.hour + reg.startTime.minute / 60.0;
          double end = reg.endTime.hour + reg.endTime.minute / 60.0;
          if (end < start) end += 24.0;
          totalHours += end - start;
        }
        count++;
      }
    }

    return count > 0 ? totalHours / count : 0;
  }
}
