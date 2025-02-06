import 'package:flutter/material.dart';
import '../../../../models/employee.dart';
import '../../../../providers/time_registration_provider.dart';
import '../../../../models/time_registration.dart';

class MonthTable extends StatelessWidget {
  final List<Employee> employees;
  final TimeRegistrationProvider provider;
  final int selectedYear;
  final int selectedMonth;
  final bool isSuperAdmin;
  final String? selectedRestaurantId;

  const MonthTable({
    super.key,
    required this.employees,
    required this.provider,
    required this.selectedYear,
    required this.selectedMonth,
    required this.isSuperAdmin,
    this.selectedRestaurantId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.primaryContainer.withAlpha(76),
          ),
          columns: _buildColumns(),
          rows: employees.map((employee) => _buildRow(employee)).toList(),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    final baseColumns = [
      const DataColumn(label: Text('Medewerker')),
      if (isSuperAdmin && selectedRestaurantId == null)
        const DataColumn(label: Text('Restaurant')),
      const DataColumn(label: Text('Functie')),
    ];

    final daysInMonth = _getWorkdaysInMonth();
    final dayColumns = List.generate(
      daysInMonth,
      (index) => DataColumn(
        label: Text(
          'Dag ${index + 1}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );

    return [
      ...baseColumns,
      ...dayColumns,
      const DataColumn(label: Text('Totaal'))
    ];
  }

  DataRow _buildRow(Employee employee) {
    final baseCells = [
      DataCell(Text(employee.name)),
      if (isSuperAdmin && selectedRestaurantId == null)
        DataCell(Text(
            provider.getRestaurantById(employee.restaurantId ?? '')?.name ??
                'Geen restaurant')),
      DataCell(Text(employee.function)),
    ];

    final dailyHours = _buildDayCells(employee);
    final totalHours = _calculateTotalHours(employee.id);

    return DataRow(
      cells: [
        ...baseCells,
        ...dailyHours,
        DataCell(Text(
          totalHours.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
      ],
    );
  }

  List<DataCell> _buildDayCells(Employee employee) {
    final daysInMonth = _getWorkdaysInMonth();
    return List.generate(daysInMonth, (day) {
      final hours = _calculateDayHours(employee.id, day + 1);
      return DataCell(Text(hours.toStringAsFixed(1)));
    });
  }

  double _calculateDayHours(String employeeId, int day) {
    final registrations = provider.registrations.where((reg) =>
        reg.employeeId == employeeId &&
        reg.date.year == selectedYear &&
        reg.date.month == selectedMonth &&
        reg.date.day == day &&
        (selectedRestaurantId == null ||
            provider.getEmployeeById(reg.employeeId)?.restaurantId ==
                selectedRestaurantId));

    double totalHours = 0;
    for (final reg in registrations) {
      totalHours += _calculateHours(reg);
    }
    return totalHours;
  }

  double _calculateTotalHours(String employeeId) {
    final registrations = provider.registrations.where((reg) =>
        reg.employeeId == employeeId &&
        reg.date.year == selectedYear &&
        reg.date.month == selectedMonth &&
        (selectedRestaurantId == null ||
            provider.getEmployeeById(reg.employeeId)?.restaurantId ==
                selectedRestaurantId));

    double totalHours = 0;
    for (final reg in registrations) {
      totalHours += _calculateHours(reg);
    }
    return totalHours;
  }

  double _calculateHours(TimeRegistration reg) {
    int startMinutes = reg.startTime.hour * 60 + reg.startTime.minute;
    int endMinutes = reg.endTime.hour * 60 + reg.endTime.minute;
    if (endMinutes < startMinutes) endMinutes += 24 * 60;
    return (endMinutes - startMinutes) / 60.0;
  }

  int _getWorkdaysInMonth() {
    final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    int workdays = 0;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(selectedYear, selectedMonth, day);
      if (date.weekday <= 5) workdays++;
    }
    return workdays;
  }
}
