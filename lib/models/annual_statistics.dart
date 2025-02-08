import '../models/employee.dart';

class AnnualStatistics {
  final double totalHours;
  final double growth;
  final double occupancyRate;
  final double averageMonthlyHours;
  final int totalEmployees;
  final double totalCosts;
  final Map<String, double> monthlyTotals;
  final Map<String, double> employeeTotals;
  final DateTime? busiestDay;
  final List<Employee> topEmployees;

  const AnnualStatistics({
    required this.totalHours,
    required this.growth,
    required this.occupancyRate,
    required this.averageMonthlyHours,
    required this.totalEmployees,
    required this.totalCosts,
    required this.monthlyTotals,
    required this.employeeTotals,
    this.busiestDay,
    required this.topEmployees,
  });

  factory AnnualStatistics.empty() {
    return const AnnualStatistics(
      totalHours: 0,
      growth: 0,
      occupancyRate: 0,
      averageMonthlyHours: 0,
      totalEmployees: 0,
      totalCosts: 0,
      monthlyTotals: {},
      employeeTotals: {},
      busiestDay: null,
      topEmployees: [],
    );
  }
}
