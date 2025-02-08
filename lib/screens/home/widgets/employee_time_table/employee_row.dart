import 'package:flutter/material.dart';
import '../../../../models/employee.dart';
import '../../../../models/time_registration.dart';
import 'employee_cell.dart';
import 'time_display.dart';
import 'hours_display.dart';
import 'week_total_cell.dart';
import 'approval_buttons.dart';

/// Callback voor wanneer er op een tijd wordt getapt.
/// [day] geeft de betreffende dag, [employeeId] de medewerker en [isStartTime]
/// geeft aan of het om de starttijd gaat.
typedef TimeTapCallback = void Function(
    DateTime day, String employeeId, bool isStartTime);

/// Callback voor het goedkeuren of afkeuren van een registratie.
typedef ApproveCallback = void Function(
    TimeRegistration registration, bool approved);

/// Callback om de registratie voor een bepaalde dag en medewerker op te halen.
typedef GetRegistrationCallback = TimeRegistration? Function(
    DateTime day, String employeeId);

class EmployeeRow {
  final Employee employee;
  final List<DateTime> weekDays;
  final bool canApproveHours;
  final TimeTapCallback onTimeTap;
  final ApproveCallback onApprove;
  final GetRegistrationCallback getRegistrationForDate;
  final BuildContext context;

  const EmployeeRow({
    required this.employee,
    required this.weekDays,
    required this.canApproveHours,
    required this.onTimeTap,
    required this.onApprove,
    required this.getRegistrationForDate,
    required this.context,
  });

  /// Bouwt de DataRow(s) voor een medewerker. Indien er een registratie is
  /// die nog goedgekeurd moet worden en de gebruiker hiervoor bevoegd is,
  /// wordt er een extra goedkeuringsrij toegevoegd.
  List<DataRow> build() {
    // Als dit een header is, toon dan alleen de restaurant naam
    if (employee.isHeader) {
      return [
        DataRow(
          color: MaterialStateProperty.all(
            Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
          ),
          cells: [
            DataCell(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  employee.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ),
            // Lege cellen voor de dagen
            ...List.generate(
                weekDays.length, (_) => const DataCell(SizedBox())),
            // Lege cel voor week totaal
            const DataCell(SizedBox()),
          ],
        ),
      ];
    }

    // Haal voor iedere dag de registratie op en bewaar in een lijst.
    final registrations = weekDays
        .map((day) => getRegistrationForDate(day, employee.id))
        .toList();

    // Bereken het weektotaal via een fold.
    final weekTotal = registrations.fold<double>(
      0,
      (total, reg) => total + (reg?.totalHours ?? 0),
    );

    // Bouw de hoofdrij: medewerker-gegevens en de tijden per dag.
    final mainRow = DataRow(
      cells: [
        DataCell(EmployeeCell(employee: employee)),
        ...weekDays.asMap().entries.map((entry) {
          final day = entry.value;
          final registration = registrations[entry.key];
          return DataCell(_buildTimeCell(day, registration));
        }),
        DataCell(WeekTotalCell(weekTotal: weekTotal)),
      ],
    );

    // Controleer of er nog goedkeuringen nodig zijn.
    final needsApproval =
        registrations.any((reg) => reg?.status == RegistrationStatus.pending);

    // Als er geen goedkeuring nodig is of de gebruiker niet bevoegd is,
    // retourneren we alleen de hoofdrij.
    if (!needsApproval || !canApproveHours) {
      return [mainRow];
    }

    // Bouw de goedkeuringsrij: per dag een cel met de goedkeuringsknop (indien van toepassing).
    final approvalRow = DataRow(
      cells: [
        const DataCell(SizedBox()), // Lege cel voor de medewerkerkolom.
        ...weekDays.asMap().entries.map((entry) {
          final registration = registrations[entry.key];
          return DataCell(
            Container(
              width: 120,
              alignment: Alignment.centerRight,
              child: registration?.status == RegistrationStatus.pending
                  ? ApprovalButtons(
                      registration: registration!,
                      onApprove: onApprove,
                    )
                  : const SizedBox(),
            ),
          );
        }),
        const DataCell(SizedBox()), // Lege cel voor het weektotaal.
      ],
    );

    // Retourneer de twee rijen.
    return [mainRow, approvalRow];
  }

  /// Bouwt een cel waarin de start- en eindtijden (en de berekende uren)
  /// voor een bepaalde dag worden weergegeven.
  Widget _buildTimeCell(DateTime day, TimeRegistration? registration) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TimeDisplay(
            date: day,
            employeeId: employee.id,
            registration: registration,
            isStartTime: true,
            onTap: onTimeTap,
          ),
          const SizedBox(height: 4),
          TimeDisplay(
            date: day,
            employeeId: employee.id,
            registration: registration,
            isStartTime: false,
            onTap: onTimeTap,
          ),
          const SizedBox(height: 4),
          Flexible(
            child: HoursDisplay(registration: registration),
          ),
        ],
      ),
    );
  }
}
