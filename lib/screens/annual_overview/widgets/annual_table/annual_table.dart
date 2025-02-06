import 'package:flutter/material.dart';
import '../../../../models/employee.dart';
import '../../../../providers/time_registration_provider.dart';
import '../../../../models/period_type.dart';

class AnnualTable extends StatefulWidget {
  final List<Employee> employees;
  final TimeRegistrationProvider provider;
  final int selectedYear;
  final bool showRestaurant;
  final Function(String) onEmployeeSelected;
  final PeriodType periodType;
  final int? selectedWeek;
  final int? selectedMonth;

  const AnnualTable({
    super.key,
    required this.employees,
    required this.provider,
    required this.selectedYear,
    this.showRestaurant = false,
    required this.onEmployeeSelected,
    this.periodType = PeriodType.year,
    this.selectedWeek,
    this.selectedMonth,
  });

  @override
  State<AnnualTable> createState() => _AnnualTableState();
}

class _AnnualTableState extends State<AnnualTable> {
  String? _sortColumnName;
  bool _sortAscending = true;
  int? _selectedRowIndex;
  final _scrollController = ScrollController();
  String? _functionFilter;
  String? _restaurantFilter;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final employees = _sortEmployees(_getFilteredEmployees());

    return Theme(
      data: Theme.of(context).copyWith(
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.outline.withAlpha(25),
            ),
          ),
        ),
      ),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(theme),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      showCheckboxColumn: false,
                      headingRowHeight: 48,
                      dataRowMinHeight: 52,
                      dataRowMaxHeight: 52,
                      horizontalMargin: 16,
                      columnSpacing: 16,
                      headingRowColor: WidgetStateProperty.all(
                        theme.colorScheme.primaryContainer.withAlpha(25),
                      ),
                      headingTextStyle: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      dataTextStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      columns: _buildColumns(theme),
                      rows: employees.asMap().entries.map((entry) {
                        final index = entry.key;
                        final employee = entry.value;
                        final isSelected = index == _selectedRowIndex;

                        return DataRow(
                          selected: isSelected,
                          onSelectChanged: (_) => _onRowTapped(index, employee),
                          color: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return theme.colorScheme.primaryContainer
                                  .withAlpha(50);
                            }
                            return null;
                          }),
                          cells: _buildCells(employee, theme),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            _buildFooter(theme, employees),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Medewerker Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Zoeken',
            onPressed: _showSearchDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, List<Employee> employees) {
    final totalHours = _calculateTotalHours(employees);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${employees.length} medewerkers',
            style: theme.textTheme.bodySmall,
          ),
          const Spacer(),
          Text(
            'Totaal: ${totalHours.toStringAsFixed(1)} uur',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<DataColumn> _buildColumns(ThemeData theme) {
    switch (widget.periodType) {
      case PeriodType.week:
        return [
          _buildSortableColumn('Medewerker', 'name'),
          if (widget.showRestaurant)
            _buildSortableColumn('Restaurant', 'restaurant'),
          _buildSortableColumn('Functie', 'function'),
          ...List.generate(7, (index) {
            return DataColumn(
              label: Text(_getWeekdayAbbreviation(index + 1)),
              numeric: true,
            );
          }),
          const DataColumn(
            label: Text('Totaal'),
            numeric: true,
          ),
        ];

      case PeriodType.month:
        final daysInMonth = DateTime(
          widget.selectedYear,
          widget.selectedMonth! + 1,
          0,
        ).day;

        return [
          _buildSortableColumn('Medewerker', 'name'),
          if (widget.showRestaurant)
            _buildSortableColumn('Restaurant', 'restaurant'),
          _buildSortableColumn('Functie', 'function'),
          ...List.generate(daysInMonth, (index) {
            return DataColumn(
              label: Text('${index + 1}'),
              numeric: true,
            );
          }),
          const DataColumn(
            label: Text('Totaal'),
            numeric: true,
          ),
        ];

      case PeriodType.year:
        return [
          _buildSortableColumn('Medewerker', 'name'),
          if (widget.showRestaurant)
            _buildSortableColumn('Restaurant', 'restaurant'),
          _buildSortableColumn('Functie', 'function'),
          ...List.generate(12, (index) {
            return DataColumn(
              label: Text(_getMonthAbbreviation(index + 1)),
              numeric: true,
            );
          }),
          const DataColumn(
            label: Text('Totaal'),
            numeric: true,
          ),
        ];
    }
  }

  List<DataCell> _buildCells(Employee employee, ThemeData theme) {
    final cells = <DataCell>[
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.primary.withAlpha(25),
              child: Text(
                employee.name.characters.first.toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(employee.name),
          ],
        ),
      ),
    ];

    if (widget.showRestaurant) {
      final restaurant = widget.provider.getRestaurantById(
        employee.restaurantId ?? '',
      );
      cells.add(DataCell(Text(restaurant?.name ?? 'Geen restaurant')));
    }

    cells.add(DataCell(Text(employee.function)));

    switch (widget.periodType) {
      case PeriodType.week:
        final weekHours = List.generate(
          7,
          (index) => _calculateDayHours(
            employee.id,
            _getDateForWeekday(index + 1),
          ),
        );
        cells.addAll(_buildHourCells(weekHours, theme));
        break;

      case PeriodType.month:
        final daysInMonth = DateTime(
          widget.selectedYear,
          widget.selectedMonth! + 1,
          0,
        ).day;
        final monthHours = List.generate(
          daysInMonth,
          (index) => _calculateDayHours(
            employee.id,
            DateTime(widget.selectedYear, widget.selectedMonth!, index + 1),
          ),
        );
        cells.addAll(_buildHourCells(monthHours, theme));
        break;

      case PeriodType.year:
        final yearHours = List.generate(
          12,
          (index) => _calculateMonthlyHours(employee.id, index + 1),
        );
        cells.addAll(_buildHourCells(yearHours, theme));
        break;
    }

    return cells;
  }

  List<DataCell> _buildHourCells(List<String> hours, ThemeData theme) {
    return [
      ...hours.map(
        (hours) => DataCell(
          Text(
            hours,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
      DataCell(
        Text(
          hours
              .map((h) => double.parse(h))
              .reduce((a, b) => a + b)
              .toStringAsFixed(1),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ),
    ];
  }

  String _calculateDayHours(String employeeId, DateTime date) {
    final registrations = widget.provider.registrations.where((reg) =>
        reg.employeeId == employeeId &&
        reg.date.year == date.year &&
        reg.date.month == date.month &&
        reg.date.day == date.day);

    double totalHours = 0;
    for (final reg in registrations) {
      double start = reg.startTime.hour + reg.startTime.minute / 60.0;
      double end = reg.endTime.hour + reg.endTime.minute / 60.0;
      if (end < start) end += 24;
      totalHours += end - start;
    }

    return totalHours.toStringAsFixed(1);
  }

  DateTime _getDateForWeekday(int weekday) {
    // Bereken de datum voor een specifieke weekdag in de geselecteerde week
    final firstDayOfYear = DateTime(widget.selectedYear);
    final firstWeek =
        firstDayOfYear.add(Duration(days: (widget.selectedWeek! - 1) * 7));
    return firstWeek.add(Duration(days: weekday - 1));
  }

  String _getWeekdayAbbreviation(int day) {
    switch (day) {
      case 1:
        return 'Ma';
      case 2:
        return 'Di';
      case 3:
        return 'Wo';
      case 4:
        return 'Do';
      case 5:
        return 'Vr';
      case 6:
        return 'Za';
      case 7:
        return 'Zo';
      default:
        return '';
    }
  }

  DataColumn _buildSortableColumn(String label, String field) {
    return DataColumn(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (_sortColumnName == field)
            Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
            ),
        ],
      ),
      onSort: (_, __) => _sortBy(field),
    );
  }

  List<Employee> _sortEmployees(List<Employee> employees) {
    if (_sortColumnName == null) return employees;

    return [...employees]..sort((a, b) {
        int compare;
        switch (_sortColumnName) {
          case 'name':
            compare = a.name.compareTo(b.name);
            break;
          case 'restaurant':
            final aName =
                widget.provider.getRestaurantById(a.restaurantId ?? '')?.name ??
                    '';
            final bName =
                widget.provider.getRestaurantById(b.restaurantId ?? '')?.name ??
                    '';
            compare = aName.compareTo(bName);
            break;
          case 'function':
            compare = a.function.compareTo(b.function);
            break;
          default:
            return 0;
        }
        return _sortAscending ? compare : -compare;
      });
  }

  void _onRowTapped(int index, Employee employee) {
    setState(() => _selectedRowIndex = index);
    widget.onEmployeeSelected(employee.id);
  }

  List<Employee> _getFilteredEmployees() {
    var filtered = widget.employees;

    // Pas functie filter toe
    if (_functionFilter != null) {
      filtered = filtered.where((e) => e.function == _functionFilter).toList();
    }

    // Pas restaurant filter toe
    if (_restaurantFilter != null) {
      filtered =
          filtered.where((e) => e.restaurantId == _restaurantFilter).toList();
    }

    // Pas zoekquery toe
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((e) {
        return e.name.toLowerCase().contains(query) ||
            e.function.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Future<void> _showFilterDialog() async {
    String? tempFunctionFilter = _functionFilter;
    String? tempRestaurantFilter = _restaurantFilter;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Opties'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String?>(
              decoration: const InputDecoration(labelText: 'Functie'),
              value: tempFunctionFilter,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Alle functies'),
                ),
                ...widget.employees
                    .map((e) => e.function)
                    .toSet()
                    .map((function) => DropdownMenuItem(
                          value: function,
                          child: Text(function),
                        )),
              ],
              onChanged: (value) => tempFunctionFilter = value,
            ),
            if (widget.showRestaurant) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                decoration: const InputDecoration(labelText: 'Restaurant'),
                value: tempRestaurantFilter,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Alle restaurants'),
                  ),
                  ...widget.provider.restaurants
                      .where((r) => r.isActive)
                      .map((restaurant) => DropdownMenuItem(
                            value: restaurant.id,
                            child: Text(restaurant.name),
                          )),
                ],
                onChanged: (value) => tempRestaurantFilter = value,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _functionFilter = tempFunctionFilter;
                _restaurantFilter = tempRestaurantFilter;
              });
              Navigator.pop(context);
            },
            child: const Text('Toepassen'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSearchDialog() async {
    final controller = TextEditingController(text: _searchQuery);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zoeken'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Zoek op naam of functie...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              Navigator.pop(context);
            },
            child: const Text('Wissen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Sluiten'),
          ),
        ],
      ),
    );
  }

  double _calculateTotalHours(List<Employee> employees) {
    double total = 0;
    for (final employee in employees) {
      for (int month = 1; month <= 12; month++) {
        total += double.parse(_calculateMonthlyHours(employee.id, month));
      }
    }
    return total;
  }

  String _calculateMonthlyHours(String employeeId, int month) {
    final registrations = widget.provider.registrations.where((reg) =>
        reg.employeeId == employeeId &&
        reg.date.year == widget.selectedYear &&
        reg.date.month == month);

    double totalHours = 0;
    for (final reg in registrations) {
      double start = reg.startTime.hour + reg.startTime.minute / 60.0;
      double end = reg.endTime.hour + reg.endTime.minute / 60.0;

      if (end < start) {
        end += 24.0;
      }

      totalHours += end - start;
    }

    return totalHours.toStringAsFixed(1);
  }

  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mrt';
      case 4:
        return 'Apr';
      case 5:
        return 'Mei';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Okt';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  void _sortBy(String field) {
    setState(() {
      if (_sortColumnName == field) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnName = field;
        _sortAscending = true;
      }
    });
  }
}
