import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home/home_screen.dart';
import 'screens/annual_overview/annual_overview_screen.dart';
import 'screens/employees/employees_screen.dart';
import 'screens/restaurants/restaurants_screen.dart';
import 'screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'providers/time_registration_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('nl_NL', null);
  Intl.defaultLocale = 'nl_NL';

  runApp(
    ChangeNotifierProvider(
      create: (_) => TimeRegistrationProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URCS',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('nl', 'NL'),
      ],
      locale: const Locale('nl', 'NL'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => const HomeScreen(title: 'URCS'),
        '/login': (context) => const LoginScreen(),
        '/annual-overview': (context) => const AnnualOverviewScreen(),
        '/employees': (context) => const EmployeesScreen(),
        '/restaurants': (context) => const RestaurantsScreen(),
      },
    );
  }
}

/// Deze widget is een voorbeeldpagina waarop tijdregistraties per medewerker worden getoond.
/// Mogelijk gebruik je deze niet direct in je routes, maar de code laat zien hoe je een kalender‐achtige weergave kunt maken.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Employee {
  final String id;
  final String name;
  final String function;

  const Employee({
    required this.id,
    required this.name,
    required this.function,
  });
}

class TimeRegistration {
  final String employeeId;
  final DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;

  TimeRegistration({
    required this.employeeId,
    required this.date,
    required this.startTime,
    required this.endTime,
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

  String calculateHours() {
    double start = startTime.hour + startTime.minute / 60.0;
    double end = endTime.hour + endTime.minute / 60.0;

    // Behandel tijden die over middernacht gaan
    if (end < start) {
      end += 24.0;
    }

    final hours = end - start;
    return '${hours.toStringAsFixed(1)} uur';
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late DateTime _selectedMonth;
  final List<TimeRegistration> _registrations = [];
  final List<Employee> _employees = const [
    Employee(id: '1', name: 'Cemil Sahinturk', function: 'Manager'),
    Employee(id: '2', name: 'Jan Janssen', function: 'Medewerker'),
    Employee(id: '3', name: 'Piet Peters', function: 'Medewerker'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();

    // Voorbeeldregistratie
    _registrations.add(
      TimeRegistration(
        employeeId: '1',
        date: DateTime.now(),
        startTime: const TimeOfDay(hour: 17, minute: 0),
        endTime: const TimeOfDay(hour: 21, minute: 0),
      ),
    );
  }

  List<DateTime> _getDaysInMonth() {
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    return List.generate(
      lastDay.day,
      (index) => DateTime(_selectedMonth.year, _selectedMonth.month, index + 1),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  int _getWeekNumber(DateTime date) {
    return (date.difference(DateTime(date.year, 1, 1)).inDays ~/ 7) + 1;
  }

  TimeRegistration _getRegistrationForDateAndEmployee(
      DateTime date, String employeeId) {
    return _registrations.firstWhere(
      (reg) =>
          reg.date.year == date.year &&
          reg.date.month == date.month &&
          reg.date.day == date.day &&
          reg.employeeId == employeeId,
      orElse: () => TimeRegistration(
        employeeId: employeeId,
        date: date,
        startTime: const TimeOfDay(hour: 17, minute: 0),
        endTime: const TimeOfDay(hour: 21, minute: 0),
      ),
    );
  }

  Future<void> _showTimePickerDialog(
      TimeRegistration registration, bool isStartTime) async {
    final initialTime =
        isStartTime ? registration.startTime : registration.endTime;
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        if (isStartTime) {
          registration.startTime = selectedTime;
        } else {
          registration.endTime = selectedTime;
        }
        if (!_registrations.contains(registration)) {
          _registrations.add(registration);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left),
              onPressed: () {
                setState(() {
                  _selectedMonth =
                      DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                });
              },
            ),
            Text(DateFormat('MMMM yyyy').format(_selectedMonth)),
            IconButton(
              icon: const Icon(Icons.arrow_right),
              onPressed: () {
                setState(() {
                  _selectedMonth =
                      DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                });
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: _employees.map((employee) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${employee.name} - ${employee.function}',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      theme.colorScheme.primaryContainer.withAlpha(76),
                    ),
                    columns: const [
                      DataColumn(label: Text('Dag')),
                      DataColumn(label: Text('Week')),
                      DataColumn(label: Text('Start')),
                      DataColumn(label: Text('Eind')),
                      DataColumn(label: Text('Uren')),
                    ],
                    rows: days.map((day) {
                      final registration =
                          _getRegistrationForDateAndEmployee(day, employee.id);
                      return DataRow(
                        color: _isToday(day)
                            ? MaterialStateProperty.all(
                                theme.colorScheme.onPrimary.withAlpha(204),
                              )
                            : null,
                        cells: [
                          DataCell(
                            Text(
                              DateFormat('E d MMM').format(day),
                              style: _isToday(day)
                                  ? const TextStyle(fontWeight: FontWeight.bold)
                                  : null,
                            ),
                          ),
                          DataCell(Text(_getWeekNumber(day).toString())),
                          DataCell(
                            Text(registration.startTime.format(context)),
                            onTap: () =>
                                _showTimePickerDialog(registration, true),
                          ),
                          DataCell(
                            Text(registration.endTime.format(context)),
                            onTap: () =>
                                _showTimePickerDialog(registration, false),
                          ),
                          DataCell(Text(registration.calculateHours())),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
              ],
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Voeg hier eventueel functionaliteit toe voor het toevoegen van medewerkers of registraties.
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
