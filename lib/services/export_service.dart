import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/period_type.dart';
import 'dart:typed_data';
import '../models/time_registration.dart';
import '../models/employee.dart';
import 'package:intl/intl.dart';
import '../providers/time_registration_provider.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart' show FilePicker, FileType;
import 'package:open_file/open_file.dart';

class ExportService {
  Future<void> exportToExcel(
    List<Employee> employees,
    List<DateTime> weekDays,
    TimeRegistrationProvider provider,
    BuildContext context,
  ) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Urenregistratie'];

      // Headers toevoegen
      final headers = [
        'Medewerker',
        'Functie',
        ...weekDays.map((day) => DateFormat('E d MMM').format(day)),
        'Week Totaal'
      ];

      // Voeg headers toe met styling
      for (var i = 0; i < headers.length; i++) {
        final cell =
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = headers[i];
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: '#E0E0E0',
        );
      }

      // Data toevoegen
      var rowIndex = 1;
      for (var employee in employees) {
        // Medewerker naam
        final cellName = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
        cellName.value = employee.name;

        // Functie
        final cellFunction = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex));
        cellFunction.value = employee.function;

        // Dagen
        for (var i = 0; i < weekDays.length; i++) {
          final reg = provider.getRegistrationForDate(weekDays[i], employee.id);
          final hours = reg?.calculateHours();
          final value = hours != null
              ? hours.replaceAll(' uur', '') // Verwijder "uur" uit de string
              : '-';

          final cellDay = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: i + 2, rowIndex: rowIndex),
          );
          cellDay.value = value;
        }

        // Week totaal
        final total = provider.calculateWeekTotal(employee.id, weekDays.first);
        final cellTotal = sheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: weekDays.length + 2,
            rowIndex: rowIndex,
          ),
        );
        cellTotal.value =
            total.toStringAsFixed(1); // Format als nummer met 1 decimaal

        rowIndex++;
      }

      // Auto-size kolommen (gebruik setColWidth i.p.v. setColumnWidth)
      for (var i = 0; i < headers.length; i++) {
        sheet.setColWidth(i, 15.0);
      }

      // Bestand opslaan
      final bytes = excel.save();
      if (bytes != null) {
        final fileName =
            'urenregistratie_${DateFormat('yyyy_MM_dd').format(weekDays.first)}.xlsx';

        // Vraag gebruiker om locatie
        final outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Kies waar je het bestand wilt opslaan',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
        );

        if (outputFile != null) {
          // Sla het bestand op de gekozen locatie op
          final file = File(outputFile);
          await file.writeAsBytes(bytes);

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bestand opgeslagen als: ${file.path}'),
              action: SnackBarAction(
                label: 'Open',
                onPressed: () => OpenFile.open(file.path),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export mislukt: ${e.toString()}')),
      );
    }
  }

  Future<Uint8List> exportToPdf({
    required List<TimeRegistration> registrations,
    required List<Employee> employees,
    required PeriodType periodType,
    required int year,
    int? week,
    int? month,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                _getTitle(periodType, year, week, month),
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              _buildTable(
                  registrations, employees, periodType, year, week, month),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  String _getTitle(PeriodType periodType, int year, int? week, int? month) {
    switch (periodType) {
      case PeriodType.week:
        return 'Weekoverzicht Week $week, $year';
      case PeriodType.month:
        final monthName = _getMonthName(month!);
        return 'Maandoverzicht $monthName $year';
      case PeriodType.year:
        return 'Jaaroverzicht $year';
    }
  }

  Future<void> exportToCsv(
    List<Employee> employees,
    List<DateTime> weekDays,
    TimeRegistrationProvider provider,
    BuildContext context,
  ) async {
    try {
      // Headers
      final headers = [
        'Medewerker',
        'Functie',
        ...weekDays.map((day) => DateFormat('E d MMM').format(day)),
        'Week Totaal'
      ];

      // Data rows
      final rows = <List<String>>[headers];

      for (var employee in employees) {
        final row = <String>[
          employee.name,
          employee.function,
        ];

        // Dagen
        for (var day in weekDays) {
          final reg = provider.getRegistrationForDate(day, employee.id);
          final hours = reg?.calculateHours();
          final value = hours != null ? hours.replaceAll(' uur', '') : '-';
          row.add(value);
        }

        // Week totaal
        final total = provider.calculateWeekTotal(employee.id, weekDays.first);
        row.add(total.toStringAsFixed(1));

        rows.add(row);
      }

      // Convert to CSV string
      final csvData = const ListToCsvConverter().convert(rows);
      final bytes = Uint8List.fromList(csvData.codeUnits);
      final fileName =
          'urenregistratie_${DateFormat('yyyy_MM_dd').format(weekDays.first)}.csv';

      // Vraag gebruiker om locatie
      final outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Kies waar je het bestand wilt opslaan',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputFile != null) {
        // Sla het bestand op de gekozen locatie op
        final file = File(outputFile);
        await file.writeAsBytes(bytes);

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bestand opgeslagen als: ${file.path}'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => OpenFile.open(file.path),
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export mislukt: ${e.toString()}')),
      );
    }
  }

  pw.Widget _buildTable(
    List<TimeRegistration> registrations,
    List<Employee> employees,
    PeriodType periodType,
    int year,
    int? week,
    int? month,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        // Header row
        pw.TableRow(
          children: [
            pw.Text('Medewerker'),
            pw.Text('Functie'),
            pw.Text('Uren'),
            pw.Text('Status'),
          ],
        ),
        // Data rows
        ...employees.map((employee) {
          final employeeRegistrations = registrations
              .where((reg) => reg.employeeId == employee.id)
              .toList();

          // Bereken totale uren
          final totalHours = employeeRegistrations.fold<double>(
            0,
            (total, reg) {
              final hours = reg.calculateHours().replaceAll(' uur', '');
              return total + (double.tryParse(hours) ?? 0);
            },
          );

          return pw.TableRow(
            children: [
              pw.Text(employee.name),
              pw.Text(employee.function),
              pw.Text(totalHours.toStringAsFixed(1)),
              pw.Text(_getStatusText(employeeRegistrations)),
            ],
          );
        }),
      ],
    );
  }

  String _getStatusText(List<TimeRegistration> registrations) {
    if (registrations.isEmpty) return '-';

    final approved = registrations
        .where((r) => r.status == RegistrationStatus.approved)
        .length;
    final rejected = registrations
        .where((r) => r.status == RegistrationStatus.rejected)
        .length;
    final pending = registrations
        .where((r) => r.status == RegistrationStatus.pending)
        .length;

    final parts = <String>[];
    if (approved > 0) parts.add('$approved goedgekeurd');
    if (rejected > 0) parts.add('$rejected afgekeurd');
    if (pending > 0) parts.add('$pending in behandeling');

    return parts.join(', ');
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      // Voeg hier de overige maanden toe...
      default:
        return '';
    }
  }
}
