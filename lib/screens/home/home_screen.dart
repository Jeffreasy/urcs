import 'package:flutter/material.dart';
import 'widgets/employee_time_table/employee_time_table.dart';
import 'widgets/appbar/custom_app_bar.dart';
import 'package:provider/provider.dart';
import '../../providers/time_registration_provider.dart';
import '../../screens/debug/api_documentation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TimeRegistrationProvider _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = Provider.of<TimeRegistrationProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeRegistrationProvider>(context);

    // Filter employees based on selected restaurant
    final restaurantId = provider.selectedRestaurantId;
    final employees = provider.getVisibleEmployees().where((employee) {
      if (restaurantId == null) return true;
      return employee.restaurantId == restaurantId;
    }).toList();

    return Scaffold(
      appBar: const CustomAppBar(),
      endDrawer: MediaQuery.of(context).size.width < 600
          ? Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Column(
                      children: [
                        if (provider.currentEmployee != null) ...[
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Text(
                              provider.currentEmployee!.name[0].toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.currentEmployee!.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            provider.currentEmployee!.role
                                .toString()
                                .split('.')
                                .last,
                            style: TextStyle(
                              color: Colors.white.withAlpha(204),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.list),
                    title: const Text('Urenlijst'),
                    onTap: () => Navigator.pushNamed(context, '/'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Jaaroverzicht'),
                    onTap: () =>
                        Navigator.pushNamed(context, '/annual-overview'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Medewerkers'),
                    onTap: () => Navigator.pushNamed(context, '/employees'),
                  ),
                  ListTile(
                    title: const Text('API Documentation'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ApiDocumentationScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Urenregistratie',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          Text(
                            '${employees.length} medewerkers',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // EmployeeTimeTable in Expanded
          Expanded(
            child: EmployeeTimeTable(
              periodType: _provider.selectedPeriodType,
              selectedYear: _provider.selectedYear,
              selectedWeek: _provider.selectedWeek,
              selectedMonth: _provider.selectedMonth,
            ),
          ),
        ],
      ),
    );
  }
}
