import 'package:flutter/material.dart';

enum RegistrationStatus {
  pending, // In behandeling
  approved, // Goedgekeurd
  rejected // Afgekeurd
}

class TimeRegistration {
  final String employeeId;
  final DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  final RegistrationStatus status;
  final String? note; // Voor afkeuringsnotities
  final String?
      approvedById; // ID van manager/eigenaar die heeft goed/afgekeurd
  final DateTime? statusDate; // Datum van laatste statuswijziging

  TimeRegistration({
    required this.employeeId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = RegistrationStatus.pending,
    this.note,
    this.approvedById,
    this.statusDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeRegistration &&
          runtimeType == other.runtimeType &&
          employeeId == other.employeeId &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day;

  @override
  int get hashCode => Object.hash(employeeId, date.year, date.month, date.day);

  double get totalHours {
    final start = startTime.hour + (startTime.minute / 60);
    final end = endTime.hour + (endTime.minute / 60);
    return end - start;
  }

  TimeRegistration copyWith({
    String? employeeId,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    RegistrationStatus? status,
    String? note,
    String? approvedById,
    DateTime? statusDate,
  }) {
    return TimeRegistration(
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      note: note ?? this.note,
      approvedById: approvedById ?? this.approvedById,
      statusDate: statusDate ?? this.statusDate,
    );
  }

  String calculateHours() {
    double start = startTime.hour + startTime.minute / 60.0;
    double end = endTime.hour + endTime.minute / 60.0;

    if (end < start) {
      end += 24.0;
    }

    final hours = end - start;
    return '${hours.toStringAsFixed(1)} uur';
  }
}
