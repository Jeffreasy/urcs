import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import '../../../../providers/time_registration_provider.dart';
import '../../../../models/time_registration.dart';
import '../../../../models/permission.dart' as perm;
import '../../../../models/employee.dart';
import 'employee_row.dart';
import '../../../../services/export_service.dart';
import 'day_header.dart';
import '../../../../models/role.dart';
import '../../../../models/period_type.dart';

class EmployeeTimeTable extends StatefulWidget {
  final PeriodType periodType;
  final int selectedYear;
  final int? selectedWeek;
  final int? selectedMonth;

  const EmployeeTimeTable({
    super.key,
    required this.periodType,
    required this.selectedYear,
    this.selectedWeek,
    this.selectedMonth,
  });

  @override
  State<EmployeeTimeTable> createState() => _EmployeeTimeTableState();
}

class _EmployeeTimeTableState extends State<EmployeeTimeTable> {
  DateTime _selectedDate = DateTime.now();
  RegistrationStatus? _filterStatus;
  String? _selectedRestaurantId;
  late TimeRegistrationProvider _provider;
  static final _logger = Logger('EmployeeTimeTable');
  final _exportService = ExportService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = Provider.of<TimeRegistrationProvider>(context);
    _selectedRestaurantId ??= _provider.restaurants.first.id;
  }

  void _handleApprove(TimeRegistration registration, bool approve) {
    final currentEmployee = _provider.currentEmployee;
    if (approve) {
      _provider.updateRegistrationStatus(
        registration,
        RegistrationStatus.approved,
        approvedById: currentEmployee?.id,
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => _RejectDialog(registration: registration),
      );
    }
  }

  List<Map<String, String>> _buildExportData() {
    return _provider.registrations.map((reg) {
      final employee =
          _provider.employees.firstWhere((e) => e.id == reg.employeeId);
      return {
        'datum': DateFormat('dd-MM-yyyy').format(reg.date),
        'medewerker': employee.name,
        'start': reg.startTime.format(context),
        'eind': reg.endTime.format(context),
        'uren': reg.totalHours.toStringAsFixed(1),
        'status': reg.status.toString(),
      };
    }).toList();
  }

  void _handlePrint() {
    final data = _buildExportData();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Print Preview'),
        content: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Datum')),
              DataColumn(label: Text('Medewerker')),
              DataColumn(label: Text('Start')),
              DataColumn(label: Text('Eind')),
              DataColumn(label: Text('Uren')),
              DataColumn(label: Text('Status')),
            ],
            rows: data.map((row) {
              return DataRow(
                cells: [
                  DataCell(Text(row['datum']!)),
                  DataCell(Text(row['medewerker']!)),
                  DataCell(Text(row['start']!)),
                  DataCell(Text(row['eind']!)),
                  DataCell(Text(row['uren']!)),
                  DataCell(Text(row['status']!)),
                ],
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuleren'),
          ),
          FilledButton.icon(
            onPressed: () {
              _logger.info('Printen van urenregistratie');
              Navigator.pop(context);
            },
            icon: const Icon(Icons.print),
            label: const Text('Printen'),
          ),
        ],
      ),
    );
  }

  void _handleExport() {
    final data = _buildExportData();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exporteren'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel'),
              onTap: () {
                _logger.info('Exporteren naar Excel: $data');
                _exportService.exportToExcel(data);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              onTap: () {
                _logger.info('Exporteren naar PDF: $data');
                _exportService.exportToPdf(
                  registrations: _provider.registrations,
                  employees: _provider.employees,
                  periodType: _provider.selectedPeriodType,
                  year: _provider.selectedYear,
                  week: _provider.selectedWeek,
                  month: _provider.selectedMonth,
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('CSV'),
              onTap: () {
                _logger.info('Exporteren naar CSV: $data');
                _exportService.exportToCsv(data);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Genereert de dagen van de week, startend bij maandag.
  List<DateTime> _getWeekDays(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  /// Controleert of een datum vandaag is.
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Bouwt de weeknavigator met pijltjes en weeknummer.
  Widget _buildWeekNavigator() {
    final weekNumber = DateFormat('w').format(_selectedDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: () => setState(() {
            _selectedDate = _selectedDate.subtract(const Duration(days: 7));
          }),
        ),
        InkWell(
          onTap: () {
            if (!_isToday(_selectedDate)) {
              // Als de geselecteerde datum niet vandaag is, zet deze dan direct op vandaag.
              setState(() {
                _selectedDate = DateTime.now();
              });
            } else {
              // Als de geselecteerde datum al vandaag is, open dan de datumkiezer.
              _showWeekPicker();
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primaryContainer.withAlpha(76),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isToday(_selectedDate)
                      ? 'Week $weekNumber, ${_selectedDate.year}'
                      : 'Naar vandaag',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isToday(_selectedDate) ? Icons.calendar_month : Icons.today,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: () => setState(() {
            _selectedDate = _selectedDate.add(const Duration(days: 7));
          }),
        ),
      ],
    );
  }

  Future<void> _showWeekPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025, 12, 31),
      locale: const Locale('nl', 'NL'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Zoekt een registratie voor een gegeven datum en medewerker.
  TimeRegistration? getRegistrationForDate(DateTime date, String employeeId) {
    try {
      return _provider.registrations.firstWhere((reg) =>
          reg.date.year == date.year &&
          reg.date.month == date.month &&
          reg.date.day == date.day &&
          reg.employeeId == employeeId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _showTimePickerDialog(
      DateTime date, String employeeId, bool isStartTime) async {
    final registration = getRegistrationForDate(date, employeeId);

    // Gebruik de provider voor rechtencontrole
    if (!_provider.canEditRegistration(employeeId, registration)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Je hebt geen rechten om deze tijd aan te passen'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final initialTime = registration != null
        ? (isStartTime ? registration.startTime : registration.endTime)
        : TimeOfDay.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      TimeRegistration newRegistration;
      if (registration != null) {
        newRegistration = registration.copyWith(
          startTime: isStartTime ? picked : registration.startTime,
          endTime: isStartTime ? registration.endTime : picked,
          // Reset status naar pending als een manager/owner de tijd aanpast
          status: _provider.currentEmployee?.role == Role.employee
              ? registration.status
              : RegistrationStatus.pending,
        );
        _provider.updateRegistration(newRegistration);
      } else {
        newRegistration = TimeRegistration(
          employeeId: employeeId,
          date: date,
          startTime:
              isStartTime ? picked : const TimeOfDay(hour: 17, minute: 0),
          endTime: isStartTime ? const TimeOfDay(hour: 17, minute: 0) : picked,
          status: RegistrationStatus.pending,
        );
        _provider.addRegistration(newRegistration);
      }
    }
  }

  List<Employee> _getFilteredEmployees() {
    final employees = <Employee>[];

    // Voor superadmin: groepeer per restaurant
    if (_provider.currentEmployee?.role == Role.superAdmin) {
      if (_selectedRestaurantId != null) {
        // Als een specifiek restaurant is geselecteerd, toon alleen die medewerkers
        employees
            .addAll(_provider.getEmployeesByRestaurant(_selectedRestaurantId));
      } else {
        // Anders, voeg eerst de superadmin(s) toe
        employees.addAll(
          _provider.employees.where((e) => e.role == Role.superAdmin),
        );

        // Voeg dan per restaurant de medewerkers toe, gesorteerd op rol
        for (final restaurant in _provider.restaurants) {
          // Voeg een "header" employee toe om restaurants te scheiden
          employees.add(
            Employee(
              id: 'header_${restaurant.id}',
              name: restaurant.name,
              function: 'Restaurant',
              role: Role.owner, // Dit bepaalt de styling
              restaurantId: restaurant.id,
              isHeader: true, // Nieuwe property om headers te markeren
            ),
          );

          // Voeg medewerkers toe, gesorteerd op rol
          final restaurantEmployees = _provider
              .getEmployeesByRestaurant(restaurant.id)
            ..sort((a, b) {
              // Sorteer eerst op rol (owner -> manager -> employee)
              final roleOrder = {
                Role.owner: 0,
                Role.manager: 1,
                Role.employee: 2,
              };
              final roleCompare =
                  (roleOrder[a.role] ?? 3).compareTo(roleOrder[b.role] ?? 3);
              if (roleCompare != 0) return roleCompare;
              // Bij gelijke rol, sorteer op naam
              return a.name.compareTo(b.name);
            });

          employees.addAll(restaurantEmployees);
        }
      }
    } else {
      // Voor andere gebruikers: gebruik bestaande filter
      employees.addAll(_provider.employees.where((employee) {
        if (_selectedRestaurantId != null &&
            employee.restaurantId != _selectedRestaurantId) {
          return false;
        }
        if (_filterStatus != null) {
          final hasRegistrationWithStatus = _provider.registrations.any((reg) =>
              reg.employeeId == employee.id && reg.status == _filterStatus);
          if (!hasRegistrationWithStatus) return false;
        }
        return true;
      }));
    }

    return employees;
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays(_selectedDate);
    final employees = _getFilteredEmployees();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filter- en actiecard
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildWeekNavigator(),
                  DropdownButton<String?>(
                    value: _selectedRestaurantId,
                    underline: const SizedBox(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Alle Restaurants'),
                      ),
                      ..._provider.restaurants.map((restaurant) {
                        return DropdownMenuItem(
                          value: restaurant.id,
                          child: Text(restaurant.name),
                        );
                      }),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedRestaurantId = value),
                  ),
                  DropdownButton<RegistrationStatus?>(
                    value: _filterStatus,
                    underline: const SizedBox(),
                    hint: const Text('Filter op status'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Alle statussen'),
                      ),
                      ...RegistrationStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            switch (status) {
                              RegistrationStatus.approved => 'Goedgekeurd',
                              RegistrationStatus.rejected => 'Afgekeurd',
                              RegistrationStatus.pending => 'In behandeling',
                            },
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) => setState(() => _filterStatus = value),
                  ),
                  IconButton(
                    icon: const Icon(Icons.print),
                    onPressed: _handlePrint,
                    tooltip: 'Printen',
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_download),
                    onPressed: _handleExport,
                    tooltip: 'Exporteren',
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Weekoverzichtstabel
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 32,
                ),
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowHeight: 80,
                    dataRowMinHeight: 100,
                    dataRowMaxHeight: 100,
                    columnSpacing: 8,
                    horizontalMargin: 8,
                    headingRowColor: WidgetStateProperty.all(
                      Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withAlpha(30),
                    ),
                    columns: [
                      const DataColumn(
                        label: SizedBox(
                          width: 120,
                          child: Row(
                            children: [
                              Icon(Icons.people, size: 16),
                              SizedBox(width: 4),
                              Text('Medewerker'),
                            ],
                          ),
                        ),
                      ),
                      // Gebruik DayHeader voor de dagkolommen
                      ...weekDays.map((day) => DataColumn(
                            label: DayHeader(
                              date: day,
                              isToday: _isToday(day),
                            ),
                          )),
                      DataColumn(
                        label: SizedBox(
                          width: 100,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              const Text('Week\nTotaal'),
                            ],
                          ),
                        ),
                      ),
                    ],
                    rows: employees.expand((employee) {
                      final row = EmployeeRow(
                        employee: employee,
                        weekDays: weekDays,
                        canApproveHours: _provider
                            .hasPermission(perm.Permission.approveHours),
                        onTimeTap: _showTimePickerDialog,
                        onApprove: _handleApprove,
                        getRegistrationForDate: getRegistrationForDate,
                        context: context,
                      );
                      return row.build();
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Dialog voor afkeuringsnotitie
class _RejectDialog extends StatefulWidget {
  final TimeRegistration registration;

  const _RejectDialog({required this.registration});

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Uren Afkeuren'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Geef een reden op voor het afkeuren:'),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              hintText: 'Typ hier de reden...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: () {
            final provider = Provider.of<TimeRegistrationProvider>(
              context,
              listen: false,
            );
            final currentEmployee = provider.currentEmployee;

            provider.updateRegistrationStatus(
              widget.registration,
              RegistrationStatus.rejected,
              note: _noteController.text,
              approvedById: currentEmployee?.id,
            );

            Navigator.of(context).pop();
          },
          child: const Text('Afkeuren'),
        ),
      ],
    );
  }
}
