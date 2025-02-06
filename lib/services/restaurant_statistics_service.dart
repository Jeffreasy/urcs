import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../models/employee.dart';
import '../models/time_registration.dart';
import '../models/role.dart';

class RestaurantStatistics {
  static Map<String, dynamic> calculateStatistics(
    Restaurant restaurant,
    List<TimeRegistration> registrations,
    List<Employee> employees,
  ) {
    final restaurantEmployees =
        employees.where((e) => e.restaurantId == restaurant.id).toList();

    final restaurantRegistrations = registrations
        .where((r) => restaurantEmployees.any((e) => e.id == r.employeeId))
        .toList();

    return {
      'totalEmployees': restaurantEmployees.length,
      'activeEmployees': restaurantEmployees.where((e) => e.isActive).length,
      'totalHours': restaurantRegistrations.fold(
        0.0,
        (sum, reg) => sum + _calculateHours(reg.startTime, reg.endTime),
      ),
      'averageHoursPerEmployee': restaurantEmployees.isEmpty
          ? 0.0
          : restaurantRegistrations.fold(
                0.0,
                (sum, reg) => sum + _calculateHours(reg.startTime, reg.endTime),
              ) /
              restaurantEmployees.length,
      'employeesByRole': _groupEmployeesByRole(restaurantEmployees),
      'hoursPerDay': _calculateHoursPerDay(restaurantRegistrations),
      'hoursPerEmployee': _calculateHoursPerEmployee(
        restaurantRegistrations,
        restaurantEmployees,
      ),
    };
  }

  static double _calculateHours(TimeOfDay start, TimeOfDay end) {
    double startHours = start.hour + start.minute / 60.0;
    double endHours = end.hour + end.minute / 60.0;
    if (endHours < startHours) {
      endHours += 24.0;
    }
    return endHours - startHours;
  }

  static Map<Role, int> _groupEmployeesByRole(List<Employee> employees) {
    final roleCount = <Role, int>{};
    for (final employee in employees) {
      roleCount[employee.role] = (roleCount[employee.role] ?? 0) + 1;
    }
    return roleCount;
  }

  static Map<DateTime, double> _calculateHoursPerDay(
      List<TimeRegistration> registrations) {
    final hoursPerDay = <DateTime, double>{};
    for (final reg in registrations) {
      final date = DateTime(reg.date.year, reg.date.month, reg.date.day);
      hoursPerDay[date] = (hoursPerDay[date] ?? 0) +
          _calculateHours(reg.startTime, reg.endTime);
    }
    return hoursPerDay;
  }

  static Map<String, double> _calculateHoursPerEmployee(
    List<TimeRegistration> registrations,
    List<Employee> employees,
  ) {
    final hoursPerEmployee = <String, double>{};
    for (final employee in employees) {
      final employeeRegs =
          registrations.where((reg) => reg.employeeId == employee.id);
      double totalHours = 0;
      for (final reg in employeeRegs) {
        totalHours += _calculateHours(reg.startTime, reg.endTime);
      }
      hoursPerEmployee[employee.id] = totalHours;
    }
    return hoursPerEmployee;
  }
}
