import 'package:flutter/material.dart';
import '../models/time_registration.dart';

class TimeRegistrationService {
  static double calculateHours(TimeOfDay start, TimeOfDay end) {
    double startHours = start.hour + start.minute / 60.0;
    double endHours = end.hour + end.minute / 60.0;
    if (endHours < startHours) {
      endHours += 24.0;
    }
    return endHours - startHours;
  }

  static Map<String, Map<int, double>> calculateMonthlyHours(
    List<TimeRegistration> registrations,
    int year,
  ) {
    final Map<String, Map<int, double>> monthlyHours = {};

    for (var registration in registrations) {
      if (registration.date.year == year) {
        final employeeId = registration.employeeId;
        final month = registration.date.month;
        final hours =
            calculateHours(registration.startTime, registration.endTime);

        monthlyHours[employeeId] ??= {};
        monthlyHours[employeeId]![month] =
            (monthlyHours[employeeId]![month] ?? 0) + hours;
      }
    }

    return monthlyHours;
  }

  static double calculateTotalHours(
      List<TimeRegistration> registrations, String employeeId) {
    return registrations
        .where((reg) => reg.employeeId == employeeId)
        .map((reg) => calculateHours(reg.startTime, reg.endTime))
        .fold(0, (sum, hours) => sum + hours);
  }
}
