import 'package:flutter/material.dart';
import '../../../../models/employee.dart';
import '../../../../providers/time_registration_provider.dart';
import '../../../../models/time_registration.dart';

class WeekTable extends StatelessWidget {
  final List<Employee> employees;
  final TimeRegistrationProvider provider;
  final int selectedYear;
  final int selectedWeek;
  final bool isSuperAdmin;
  final String? selectedRestaurantId;

  const WeekTable({
    super.key,
    required this.employees,
    required this.provider,
    required this.selectedYear,
    required this.selectedWeek,
    required this.isSuperAdmin,
    this.selectedRestaurantId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
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

    final dayColumns = List.generate(
      7,
      (index) => DataColumn(
        label: Text(
          _getDayName(index + 1),
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

    final weekDays = _buildWeekDayCells(employee);
    final totalHours = _calculateTotalHours(employee.id);

    return DataRow(
      cells: [
        ...baseCells,
        ...weekDays,
        DataCell(Text(
          totalHours.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
      ],
    );
  }

  List<DataCell> _buildWeekDayCells(Employee employee) {
    final firstDayOfWeek = _getFirstDayOfWeek();
    return List.generate(7, (day) {
      final date = firstDayOfWeek.add(Duration(days: day));
      final hours = _calculateDayHours(employee.id, date);
      return DataCell(Text(hours.toStringAsFixed(1)));
    });
  }

  double _calculateDayHours(String employeeId, DateTime date) {
    final registrations = provider.registrations.where((reg) =>
        reg.employeeId == employeeId &&
        reg.date.year == date.year &&
        reg.date.month == date.month &&
        reg.date.day == date.day &&
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
    final firstDayOfWeek = _getFirstDayOfWeek();
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

    final registrations = provider.registrations.where((reg) =>
        reg.employeeId == employeeId &&
        reg.date.isAfter(firstDayOfWeek.subtract(const Duration(days: 1))) &&
        reg.date.isBefore(lastDayOfWeek.add(const Duration(days: 1))) &&
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

  String _getDayName(int day) {
    return switch (day) {
      1 => 'Maandag',
      2 => 'Dinsdag',
      3 => 'Woensdag',
      4 => 'Donderdag',
      5 => 'Vrijdag',
      6 => 'Zaterdag',
      7 => 'Zondag',
      _ => '',
    };
  }

  DateTime _getFirstDayOfWeek() {
    final firstDayOfYear = DateTime(selectedYear, 1, 1);
    final daysToAdd = ((selectedWeek - 1) * 7) - (firstDayOfYear.weekday - 1);
    return firstDayOfYear.add(Duration(days: daysToAdd));
  }
}
