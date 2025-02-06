import 'package:flutter/material.dart';
import '../../../../models/employee.dart';
import '../../../../providers/time_registration_provider.dart';

class EmployeeRow {
  final Employee employee;
  final int selectedYear;
  final TimeRegistrationProvider provider;
  final bool isSuperAdmin;
  final bool showRestaurant;

  const EmployeeRow({
    required this.employee,
    required this.selectedYear,
    required this.provider,
    required this.isSuperAdmin,
    required this.showRestaurant,
  });

  DataRow build(BuildContext context) {
    final monthlyHours = List.generate(
      12,
      (index) => _calculateMonthlyHours(index + 1),
    );

    final totalHours = monthlyHours.fold<double>(
      0,
      (sum, hours) => sum + hours,
    );

    return DataRow(
      cells: [
        DataCell(Text(employee.name)),
        if (showRestaurant)
          DataCell(Text(
              provider.getRestaurantById(employee.restaurantId ?? '')?.name ??
                  'Geen restaurant')),
        DataCell(Text(employee.function)),
        ...monthlyHours.map((hours) => DataCell(
              Text(
                hours.toStringAsFixed(1),
                style: TextStyle(
                  color: hours > (totalHours / 12)
                      ? Colors.green
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            )),
        DataCell(
          Text(
            totalHours.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  double _calculateMonthlyHours(int month) {
    final registrations = provider.registrations.where((reg) =>
        reg.employeeId == employee.id &&
        reg.date.year == selectedYear &&
        reg.date.month == month);

    double totalHours = 0;
    for (final reg in registrations) {
      double start = reg.startTime.hour + reg.startTime.minute / 60.0;
      double end = reg.endTime.hour + reg.endTime.minute / 60.0;
      if (end < start) end += 24.0;
      totalHours += end - start;
    }

    return totalHours;
  }
}
