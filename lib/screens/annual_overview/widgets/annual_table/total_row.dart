import 'package:flutter/material.dart';
import '../../../../models/employee.dart';
import '../../../../providers/time_registration_provider.dart';

class TotalRow {
  final List<Employee> employees;
  final int selectedYear;
  final TimeRegistrationProvider provider;

  const TotalRow({
    required this.employees,
    required this.selectedYear,
    required this.provider,
  });

  DataRow build(BuildContext context) {
    final monthlyTotals = List.generate(
      12,
      (index) => _calculateMonthlyTotal(index + 1),
    );

    final grandTotal = monthlyTotals.fold<double>(
      0,
      (sum, total) => sum + total,
    );

    return DataRow(
      color: WidgetStateProperty.all(
        Theme.of(context).colorScheme.primaryContainer.withAlpha(30),
      ),
      cells: [
        const DataCell(
          Text(
            'Totaal',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...monthlyTotals.map((total) => DataCell(
              Text(
                total.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )),
        DataCell(
          Text(
            grandTotal.toStringAsFixed(1),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  double _calculateMonthlyTotal(int month) {
    double total = 0;
    for (final employee in employees) {
      final registrations = provider.registrations.where((reg) =>
          reg.employeeId == employee.id &&
          reg.date.year == selectedYear &&
          reg.date.month == month);

      for (final reg in registrations) {
        double start = reg.startTime.hour + reg.startTime.minute / 60.0;
        double end = reg.endTime.hour + reg.endTime.minute / 60.0;
        if (end < start) end += 24.0;
        total += end - start;
      }
    }
    return total;
  }
}
