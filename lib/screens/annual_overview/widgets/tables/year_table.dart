import 'package:flutter/material.dart';
import '../../../../models/employee.dart';
import '../../../../providers/time_registration_provider.dart';
import '../../../../models/time_registration.dart';

class YearTable extends StatelessWidget {
  final List<Employee> employees;
  final TimeRegistrationProvider provider;
  final int selectedYear;
  final bool isSuperAdmin;
  final String? selectedRestaurantId;

  const YearTable({
    super.key,
    required this.employees,
    required this.provider,
    required this.selectedYear,
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

    final monthColumns = List.generate(
      12,
      (index) => DataColumn(
        label: Text(
          _getMonthName(index + 1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );

    return [
      ...baseColumns,
      ...monthColumns,
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

    final monthlyHours = List.generate(
      12,
      (index) => DataCell(Text(_calculateMonthlyHours(employee.id, index + 1))),
    );

    final totalHours = _calculateTotalHours(employee.id);

    return DataRow(
      cells: [
        ...baseCells,
        ...monthlyHours,
        DataCell(Text(
          totalHours.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
      ],
    );
  }

  String _calculateMonthlyHours(String employeeId, int month) {
    final registrations = provider.registrations.where((reg) =>
        reg.employeeId == employeeId &&
        reg.date.year == selectedYear &&
        reg.date.month == month &&
        (selectedRestaurantId == null ||
            provider.getEmployeeById(reg.employeeId)?.restaurantId ==
                selectedRestaurantId));

    double totalHours = 0;
    for (final reg in registrations) {
      totalHours += _calculateHours(reg);
    }
    return totalHours.toStringAsFixed(1);
  }

  double _calculateTotalHours(String employeeId) {
    final registrations = provider.registrations.where((reg) =>
        reg.employeeId == employeeId &&
        reg.date.year == selectedYear &&
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

  String _getMonthName(int month) {
    return switch (month) {
      1 => 'Januari',
      2 => 'Februari',
      3 => 'Maart',
      4 => 'April',
      5 => 'Mei',
      6 => 'Juni',
      7 => 'Juli',
      8 => 'Augustus',
      9 => 'September',
      10 => 'Oktober',
      11 => 'November',
      12 => 'December',
      _ => '',
    };
  }
}
