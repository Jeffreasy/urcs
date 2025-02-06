import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:logging/logging.dart';
import '../models/period_type.dart';
import 'dart:typed_data';
import '../models/time_registration.dart';
import '../models/employee.dart';

class ExportService {
  static final _logger = Logger('ExportService');

  Future<void> exportToExcel(List<Map<String, String>> data) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Urenregistratie'];

      // Headers toevoegen
      final headers = [
        'Datum',
        'Medewerker',
        'Start',
        'Eind',
        'Uren',
        'Status'
      ];
      for (var i = 0; i < headers.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          ..value = headers[i]
          ..cellStyle = CellStyle(
            bold: true,
            backgroundColorHex: '#E0E0E0',
          );
      }

      // Data toevoegen
      for (var i = 0; i < data.length; i++) {
        final row = data[i];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
            .value = row['datum'];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
            .value = row['medewerker'];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
            .value = row['start'];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
            .value = row['eind'];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
            .value = row['uren'];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
            .value = row['status'];
      }

      // Excel package heeft geen directe methode voor kolom breedtes
      // We laten Excel de breedtes automatisch bepalen
      final columnWidths = {
        0: 15.0, // Datum
        1: 25.0, // Medewerker
        2: 12.0, // Start
        3: 12.0, // Eind
        4: 10.0, // Uren
        5: 15.0, // Status
      };

      columnWidths.forEach((columnIndex, width) {
        for (var rowIndex = 0; rowIndex <= data.length; rowIndex++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(
              columnIndex: columnIndex,
              rowIndex: rowIndex,
            ),
          );
          // Alleen basis cel styling toepassen
          if (rowIndex == 0) {
            cell.cellStyle = CellStyle(
              bold: true,
              backgroundColorHex: '#E0E0E0',
            );
          }
        }
      });

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/urenregistratie.xlsx');
      await file.writeAsBytes(excel.encode()!);

      _logger.info('Excel bestand opgeslagen: ${file.path}');
      await OpenFile.open(file.path);
    } catch (e) {
      _logger.severe('Fout bij exporteren naar Excel: $e');
      rethrow;
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

    // Voeg titel toe
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
              // Voeg tabel toe
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

  Future<void> exportToCsv(List<Map<String, String>> data) async {
    try {
      final headers = [
        'Datum',
        'Medewerker',
        'Start',
        'Eind',
        'Uren',
        'Status'
      ];
      final rows = [
        headers,
        ...data.map((row) => [
              row['datum'],
              row['medewerker'],
              row['start'],
              row['eind'],
              row['uren'],
              row['status'],
            ]),
      ];

      final csvData = const ListToCsvConverter().convert(rows);

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/urenregistratie.csv');
      await file.writeAsString(csvData);

      _logger.info('CSV bestand opgeslagen: ${file.path}');
      await OpenFile.open(file.path);
    } catch (e) {
      _logger.severe('Fout bij exporteren naar CSV: $e');
      rethrow;
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
    // Implementeer tabel opbouw hier
    return pw.Container(); // Placeholder
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      // ... etc
      default:
        return '';
    }
  }
}
