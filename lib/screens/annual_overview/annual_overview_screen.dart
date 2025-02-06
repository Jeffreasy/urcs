import 'package:flutter/material.dart';
import '../home/widgets/appbar/custom_app_bar.dart';
import 'package:provider/provider.dart';
import '../../providers/time_registration_provider.dart';
import '../../models/role.dart';
import '../../models/employee.dart';
import '../../models/restaurant.dart';
import 'widgets/restaurant_selector.dart';
import 'widgets/year_selector.dart';
import 'widgets/export_buttons.dart';
import 'widgets/stat_card.dart';
import 'widgets/charts/annual_charts.dart';
import '../../models/period_type.dart';
import '../../services/statistics_cache_service.dart';
import '../../models/statistics_exception.dart';
import '../../services/tooltip_service.dart';
import 'package:flutter/foundation.dart';
import '../../widgets/loading_overlay.dart';
import '../../models/annual_statistics.dart';
import '../../models/time_registration.dart';
import 'package:intl/intl.dart';
import 'widgets/tables/year_table.dart';
import 'widgets/tables/month_table.dart';
import 'widgets/tables/week_table.dart';

class AnnualOverviewScreen extends StatefulWidget {
  const AnnualOverviewScreen({super.key});

  @override
  State<AnnualOverviewScreen> createState() => _AnnualOverviewScreenState();
}

class _AnnualOverviewScreenState extends State<AnnualOverviewScreen> {
  String? _selectedRestaurantId;
  int _selectedYear = DateTime.now().year;
  late TimeRegistrationProvider _provider;
  late List<Restaurant> _restaurants;
  late bool _isSuperAdmin;
  PeriodType _selectedPeriodType = PeriodType.year;
  int? _selectedWeek;
  int? _selectedMonth;
  final _statisticsCache = StatisticsCacheService();
  bool _isLoading = false;
  double _totalHours = 0;
  double _growth = 0;
  double _occupancyRate = 0;
  AnnualStatistics? stats;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = Provider.of<TimeRegistrationProvider>(context);
    _isSuperAdmin = _provider.currentEmployee?.role == Role.superAdmin;
    _restaurants = _provider.restaurants.where((r) => r.isActive).toList();

    _calculateStatistics();
  }

  // Maak een statische functie voor de berekeningen
  static Future<AnnualStatistics> _calculateStatisticsIsolate(
      Map<String, dynamic> params) async {
    final registrationsData =
        List<Map<String, dynamic>>.from(params['registrations']);
    final employeesData = List<Map<String, dynamic>>.from(params['employees']);
    final periodType = PeriodType.values[params['periodType']];
    final year = params['year'] as int;
    final week = params['week'] as int?;
    final month = params['month'] as int?;
    final selectedRestaurantId = params['selectedRestaurantId'] as String?;

    // Converteer de data terug naar bruikbare objecten
    final registrations = registrationsData
        .map((data) => TimeRegistration(
              employeeId: data['employeeId'],
              date: DateTime.parse(data['date']),
              startTime: TimeOfDay(
                  hour: data['startHour'], minute: data['startMinute']),
              endTime:
                  TimeOfDay(hour: data['endHour'], minute: data['endMinute']),
            ))
        .toList();

    final employees = employeesData
        .map((data) => Employee(
              id: data['id'],
              name: data['name'],
              function: data['function'] ?? 'Onbekend',
              role: Role.employee,
              restaurantId: data['restaurantId'],
            ))
        .toList();

    // Filter registraties op basis van periode en restaurant
    final filteredRegistrations = registrations.where((reg) {
      if (reg.date.year != year) return false;

      // Filter op periode
      final periodMatch = switch (periodType) {
        PeriodType.week => getWeekNumber(reg.date) == week,
        PeriodType.month => reg.date.month == month,
        PeriodType.year => true,
      };

      if (!periodMatch) return false;

      // Filter op restaurant als er een is geselecteerd
      if (selectedRestaurantId != null) {
        final employee = employees.firstWhere(
          (e) => e.id == reg.employeeId,
          orElse: () => Employee(
            id: '',
            name: '',
            function: '',
            role: Role.employee,
            restaurantId: '',
          ),
        );
        return employee.restaurantId == selectedRestaurantId;
      }

      return true;
    }).toList();

    // Bereken totale uren
    double totalHours = 0;
    for (final reg in filteredRegistrations) {
      final hours = _calculateHoursStatic(reg);
      totalHours += hours;
    }

    // Bereken drukste dag
    final dailyHours = <DateTime, double>{};
    for (final reg in filteredRegistrations) {
      final date = DateTime(reg.date.year, reg.date.month, reg.date.day);
      dailyHours[date] = (dailyHours[date] ?? 0) + _calculateHoursStatic(reg);
    }

    final busiestDay = dailyHours.entries.isEmpty
        ? null
        : dailyHours.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Bereken top medewerkers
    final employeeHours = <String, double>{};
    for (final reg in filteredRegistrations) {
      employeeHours[reg.employeeId] =
          (employeeHours[reg.employeeId] ?? 0) + _calculateHoursStatic(reg);
    }

    final topEmployees = employeeHours.entries
        .map((e) =>
            MapEntry(employees.firstWhere((emp) => emp.id == e.key), e.value))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AnnualStatistics(
      totalHours: totalHours,
      growth: 0, // Implementeer groeiberekening indien nodig
      occupancyRate: 0, // Implementeer bezettingsgraad indien nodig
      averageMonthlyHours: totalHours / 12,
      totalEmployees: employees.length,
      employeeTotals: employeeHours,
      monthlyTotals: {},
      totalCosts: 0,
      busiestDay: busiestDay,
      topEmployees: topEmployees.isEmpty
          ? []
          : topEmployees.take(3).map((e) => e.key).toList(),
    );
  }

  // Statische hulpfunctie voor urenberekening
  static double _calculateHoursStatic(TimeRegistration reg) {
    int startMinutes = reg.startTime.hour * 60 + reg.startTime.minute;
    int endMinutes = reg.endTime.hour * 60 + reg.endTime.minute;
    if (endMinutes < startMinutes) endMinutes += 24 * 60;
    return (endMinutes - startMinutes) / 60.0;
  }

  // Statische hulpfunctie voor weeknummer
  static int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).ceil();
  }

  Future<void> _calculateStatistics() async {
    if (!mounted) return;
    var isLoading = true;
    setState(() => _isLoading = isLoading);

    try {
      final cacheKey =
          '${_selectedPeriodType}_${_selectedYear}_${_selectedWeek ?? ''}_${_selectedMonth ?? ''}_${_selectedRestaurantId ?? 'all'}';
      var stats = _statisticsCache.get<AnnualStatistics>(cacheKey);

      if (stats == null) {
        // Filter registraties op basis van geselecteerd restaurant en jaar
        var filteredRegistrations = _provider.registrations.where(
            (reg) => reg.date.year == _selectedYear); // Filter eerst op jaar

        if (_selectedRestaurantId != null) {
          final restaurantEmployees =
              _provider.getEmployeesByRestaurant(_selectedRestaurantId);
          final employeeIds = restaurantEmployees.map((e) => e.id).toSet();
          filteredRegistrations = filteredRegistrations
              .where((reg) => employeeIds.contains(reg.employeeId))
              .toList();
        }

        final registrationsData = filteredRegistrations
            .map((reg) => {
                  'employeeId': reg.employeeId,
                  'date': reg.date.toIso8601String(),
                  'startHour': reg.startTime.hour,
                  'startMinute': reg.startTime.minute,
                  'endHour': reg.endTime.hour,
                  'endMinute': reg.endTime.minute,
                })
            .toList();

        // Filter employees op basis van geselecteerd restaurant
        var filteredEmployees = _selectedRestaurantId != null
            ? _provider.getEmployeesByRestaurant(_selectedRestaurantId)
            : _provider.employees;

        final employeesData = filteredEmployees
            .map((emp) => {
                  'id': emp.id,
                  'name': emp.name,
                  'function': emp.function,
                  'role': emp.role.toString(),
                  'restaurantId': emp.restaurantId,
                })
            .toList();

        final params = {
          'registrations': registrationsData,
          'employees': employeesData,
          'periodType': _selectedPeriodType.index,
          'year': _selectedYear,
          'week': _selectedWeek,
          'month': _selectedMonth,
          'selectedRestaurantId': _selectedRestaurantId,
        };

        stats = await compute(_calculateStatisticsIsolate, params);
        _statisticsCache.set(cacheKey, stats);
      }

      if (!mounted) return;
      setState(() {
        this.stats = stats;
        _totalHours = stats?.totalHours ?? 0;
        _growth = stats?.growth ?? 0;
        _occupancyRate = stats?.occupancyRate ?? 0;
      });
    } on StatisticsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      isLoading = false;
      if (mounted) {
        setState(() => _isLoading = isLoading);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final employees = _isSuperAdmin
        ? _provider.getEmployeesByRestaurant(_selectedRestaurantId)
        : _provider.getVisibleEmployees();

    return Scaffold(
      appBar: const CustomAppBar(),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Berekeningen worden uitgevoerd...',
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header met filters
              Row(
                children: [
                  // Titel en jaar selector
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          _selectedPeriodType == PeriodType.year
                              ? 'Jaaroverzicht'
                              : _selectedPeriodType == PeriodType.month
                                  ? 'Maandoverzicht'
                                  : 'Weekoverzicht',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(width: 16),
                        YearSelector(
                          selectedYear: _selectedYear,
                          onYearChanged: (year) {
                            setState(() {
                              _selectedYear = year;
                              // Herbereken statistieken wanneer jaar wijzigt
                              _calculateStatistics();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // Export knoppen en restaurant selector
                  Row(
                    children: [
                      if (_isSuperAdmin)
                        SizedBox(
                          width: 300,
                          child: RestaurantSelector(
                            selectedRestaurantId: _selectedRestaurantId,
                            restaurants: _restaurants,
                            onRestaurantChanged: (value) {
                              setState(() {
                                _selectedRestaurantId = value;
                                // Herbereken statistieken wanneer restaurant wijzigt
                                _calculateStatistics();
                              });
                            },
                          ),
                        ),
                      const SizedBox(width: 16),
                      ExportButtons(
                        onExportToPdf: () {},
                        onExportToExcel: () {},
                        onExportToCsv: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Period selector
              _buildPeriodSelector(),

              // Statistieken en grafieken in een grid
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Linker kolom met stats en grafieken
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          // Statistieken cards
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Tooltip(
                                    message: TooltipService.getStatCardTooltip(
                                        'Totaal Uren', _selectedPeriodType),
                                    child: StatCard(
                                      title: 'Totaal Uren',
                                      value:
                                          '${_totalHours.toStringAsFixed(1)}u',
                                      subtitle:
                                          _selectedPeriodType == PeriodType.year
                                              ? 'dit jaar'
                                              : _selectedPeriodType ==
                                                      PeriodType.month
                                                  ? 'deze maand'
                                                  : 'deze week',
                                      icon: Icons.access_time,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatCard(
                                    title: 'Groei',
                                    value: '${_growth.toStringAsFixed(1)}%',
                                    subtitle: 't.o.v. vorig jaar',
                                    icon: Icons.trending_up,
                                    valueColor: _growth >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatCard(
                                    title: 'Bezetting',
                                    value:
                                        '${_occupancyRate.toStringAsFixed(0)}%',
                                    subtitle: 'van beschikbare uren',
                                    icon: Icons.analytics,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatCard(
                                    title: 'Drukste Dag',
                                    value: (stats != null &&
                                            stats!.busiestDay != null)
                                        ? DateFormat('d MMMM')
                                            .format(stats!.busiestDay!)
                                        : '-',
                                    subtitle: 'meeste gewerkte uren',
                                    icon: Icons.event_busy,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatCard(
                                    title: 'Top Medewerker',
                                    value: (stats != null &&
                                            stats!.topEmployees.isNotEmpty)
                                        ? stats!.topEmployees.first.name
                                        : '-',
                                    subtitle: 'meeste uren gewerkt',
                                    icon: Icons.emoji_events,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Grafieken
                          Expanded(
                            child: AnnualCharts(
                              registrations: _provider.registrations,
                              selectedYear: _selectedYear,
                              selectedRestaurantId: _selectedRestaurantId,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Rechter kolom met tabel
                    Expanded(
                      flex: 3,
                      child: Card(
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Tabel header
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withAlpha(25),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Medewerker Details',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Tabel content
                            Expanded(
                              child: _buildAnnualTable(employees),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        SegmentedButton<PeriodType>(
          segments: PeriodType.values
              .map((type) => ButtonSegment(
                    value: type,
                    label: Text(type.label),
                  ))
              .toList(),
          selected: {_selectedPeriodType},
          onSelectionChanged: (selected) {
            setState(() {
              _selectedPeriodType = selected.first;
              // Reset week/month selection when switching period type
              _selectedWeek = null;
              _selectedMonth = null;
              // Herbereken statistieken bij periode wijziging
              _calculateStatistics();
            });
          },
        ),
        const SizedBox(width: 16),
        if (_selectedPeriodType == PeriodType.week)
          DropdownButton<int>(
            value: _selectedWeek ?? 1,
            items: List.generate(
                52,
                (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('Week ${index + 1}'),
                    )),
            onChanged: (value) => setState(() {
              _selectedWeek = value;
              _calculateStatistics(); // Herbereken bij week wijziging
            }),
          )
        else if (_selectedPeriodType == PeriodType.month)
          DropdownButton<int>(
            value: _selectedMonth ?? DateTime.now().month - 1,
            items: List.generate(
                12,
                (index) => DropdownMenuItem(
                      value: index,
                      child: Text(_getMonthName(index + 1)),
                    )),
            onChanged: (value) => setState(() {
              _selectedMonth = value;
              _calculateStatistics(); // Herbereken bij maand wijziging
            }),
          ),
      ],
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      case 3:
        return 'Maart';
      case 4:
        return 'April';
      case 5:
        return 'Mei';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'Augustus';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  Widget _buildAnnualTable(List<Employee> employees) {
    return switch (_selectedPeriodType) {
      PeriodType.year => YearTable(
          employees: employees,
          provider: _provider,
          selectedYear: _selectedYear,
          isSuperAdmin: _isSuperAdmin,
          selectedRestaurantId: _selectedRestaurantId,
        ),
      PeriodType.month => MonthTable(
          employees: employees,
          provider: _provider,
          selectedYear: _selectedYear,
          selectedMonth: _selectedMonth ?? DateTime.now().month,
          isSuperAdmin: _isSuperAdmin,
          selectedRestaurantId: _selectedRestaurantId,
        ),
      PeriodType.week => WeekTable(
          employees: employees,
          provider: _provider,
          selectedYear: _selectedYear,
          selectedWeek: _selectedWeek ?? 1,
          isSuperAdmin: _isSuperAdmin,
          selectedRestaurantId: _selectedRestaurantId,
        ),
    };
  }

  int getWorkdaysInMonth(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    int workdays = 0;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      if (date.weekday <= 5) workdays++;
    }
    return workdays;
  }

  int getWorkdaysInYear(int year) {
    int workdays = 0;
    for (int month = 1; month <= 12; month++) {
      workdays += getWorkdaysInMonth(year, month);
    }
    return workdays;
  }
}
