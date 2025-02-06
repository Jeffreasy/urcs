import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/restaurant.dart';
import '../models/employee.dart';
import '../models/time_registration.dart';
import 'restaurant_statistics_service.dart';

class RestaurantExportService {
  static Future<void> exportToExcel(
    Restaurant restaurant,
    List<Employee> employees,
    List<TimeRegistration> registrations,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Restaurant ${restaurant.name}'];

    // Restaurant info
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = 'Restaurant Informatie'
      ..cellStyle = CellStyle(
        bold: true,
        fontSize: 14,
      );

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
      ..value = 'Naam:'
      ..cellStyle = CellStyle(bold: true);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1)).value =
        restaurant.name;

    // Medewerkers
    var currentRow = 3;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
      ..value = 'Medewerkers'
      ..cellStyle = CellStyle(
        bold: true,
        fontSize: 12,
      );

    currentRow++;
    for (final employee
        in employees.where((e) => e.restaurantId == restaurant.id)) {
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .value = employee.name;
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
          .value = employee.function;
      currentRow++;
    }

    // Statistieken
    final stats = RestaurantStatistics.calculateStatistics(
      restaurant,
      registrations,
      employees,
    );

    currentRow += 2;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
      ..value = 'Statistieken'
      ..cellStyle = CellStyle(
        bold: true,
        fontSize: 12,
      );

    currentRow++;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = 'Totaal medewerkers:';
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
        .value = stats['totalEmployees'];

    // Sla het bestand op
    final file = File('restaurant_${restaurant.id}_export.xlsx');
    await file.writeAsBytes(excel.encode()!);
  }

  static Future<void> exportToPdf(
    Restaurant restaurant,
    List<Employee> employees,
    List<TimeRegistration> registrations,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Restaurant Rapport: ${restaurant.name}'),
          ),
          pw.Paragraph(
            text: 'Adres: ${restaurant.address}\n'
                'Telefoon: ${restaurant.phoneNumber}\n'
                'Email: ${restaurant.email}',
          ),
          pw.Header(
            level: 1,
            child: pw.Text('Medewerkers'),
          ),
          pw.TableHelper.fromTextArray(
            context: context,
            data: <List<String>>[
              ['Naam', 'Functie', 'Rol'],
              ...employees
                  .where((e) => e.restaurantId == restaurant.id)
                  .map((e) => [e.name, e.function, e.role.toString()]),
            ],
          ),
        ],
      ),
    );

    final file = File('restaurant_${restaurant.id}_rapport.pdf');
    await file.writeAsBytes(await pdf.save());
  }
}
