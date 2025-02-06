import '../models/annual_statistics.dart';
import '../../../models/employee.dart';
import '../../../models/time_registration.dart';
import '../models/role.dart';

class AnnualOverviewService {
  AnnualStatistics calculateStatistics(
    List<TimeRegistration> registrations,
    List<Employee> employees,
    int year,
  ) {
    double totalHours = 0;
    final monthlyTotals = <String, double>{};
    final employeeTotals = <String, double>{};

    // Bereken totalen per maand en per medewerker
    for (final reg in registrations.where((r) => r.date.year == year)) {
      final hours = _calculateHours(reg);
      totalHours += hours;

      // Maand totalen
      final monthKey = '${reg.date.year}-${reg.date.month}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + hours;

      // Medewerker totalen
      employeeTotals[reg.employeeId] =
          (employeeTotals[reg.employeeId] ?? 0) + hours;
    }

    // Sorteer medewerkers op basis van gewerkte uren
    final sortedEmployees = employees.toList()
      ..sort((a, b) =>
          (employeeTotals[b.id] ?? 0).compareTo(employeeTotals[a.id] ?? 0));

    return AnnualStatistics(
      totalHours: totalHours,
      averageMonthlyHours: totalHours / 12,
      totalEmployees: employees.length,
      totalCosts: _calculateTotalCosts(employeeTotals, employees),
      monthlyTotals: monthlyTotals,
      employeeTotals: employeeTotals,
      growth: 0.0,
      occupancyRate: 0.0,
      topEmployees: sortedEmployees.take(3).toList(),
    );
  }

  double _calculateHours(TimeRegistration reg) {
    double start = reg.startTime.hour + reg.startTime.minute / 60.0;
    double end = reg.endTime.hour + reg.endTime.minute / 60.0;
    if (end < start) end += 24.0;
    return end - start;
  }

  double _calculateTotalCosts(
    Map<String, double> employeeTotals,
    List<Employee> employees,
  ) {
    double total = 0;
    for (final entry in employeeTotals.entries) {
      final employee = employees.firstWhere((e) => e.id == entry.key);
      final hourlyRate = _getHourlyRate(employee);
      total += entry.value * hourlyRate;
    }
    return total;
  }

  double _getHourlyRate(Employee employee) {
    return switch (employee.role) {
      Role.owner => 50.0,
      Role.manager => 35.0,
      Role.employee => 25.0,
      _ => 0.0,
    };
  }
}
