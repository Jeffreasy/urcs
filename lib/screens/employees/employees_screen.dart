import 'package:flutter/material.dart';
import '../home/widgets/appbar/custom_app_bar.dart';
import 'package:provider/provider.dart';
import '../../providers/time_registration_provider.dart';
import '../../models/employee.dart';
import '../../models/role.dart';
import '../../models/permission.dart' as perm;
import 'edit_employee_dialog.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all';
  String? _filterRestaurantName;

  List<Role> _getAvailableRoles(
      bool canManageOwners, bool canManageManagers, bool canManageEmployees) {
    if (canManageOwners) return Role.values;
    if (canManageManagers) return [Role.manager, Role.employee];
    if (canManageEmployees) return [Role.employee];
    return [];
  }

  List<Employee> _filterEmployees(List<Employee> employees) {
    return employees.where((employee) {
      // Filter op zoekterm
      final matchesSearch = employee.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          employee.function.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter op status
      final matchesStatus = switch (_filterStatus) {
        'active' => employee.isActive,
        'inactive' => !employee.isActive,
        _ => true,
      };

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Haal restaurant filter op uit route arguments
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? filterRestaurantId = arguments?['restaurantId'];

    // Update class variabele
    _filterRestaurantName = arguments?['restaurantName'];

    final provider = Provider.of<TimeRegistrationProvider>(context);
    final employees = provider.getVisibleEmployees();

    // Filter employees op restaurant indien nodig
    var filteredEmployees = filterRestaurantId != null
        ? employees
            .where((emp) => emp.restaurantId == filterRestaurantId)
            .toList()
        : employees;

    // Pas zoek en status filters toe
    filteredEmployees = _filterEmployees(filteredEmployees);

    final canManageEmployees =
        provider.hasPermission(perm.Permission.manageEmployees);
    final canManageManagers =
        provider.hasPermission(perm.Permission.manageManagers);
    final canManageOwners =
        provider.hasPermission(perm.Permission.manageOwners);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          _buildHeader(context, filteredEmployees),
          Expanded(
            child: _buildEmployeesList(
              context,
              filteredEmployees,
              canManageEmployees,
              canManageManagers,
              canManageOwners,
            ),
          ),
        ],
      ),
      floatingActionButton: canManageEmployees
          ? FloatingActionButton.extended(
              onPressed: () => _showAddDialog(
                  context,
                  _getAvailableRoles(
                      canManageOwners, canManageManagers, canManageEmployees)),
              icon: const Icon(Icons.person_add),
              label: const Text('Nieuwe Medewerker'),
            )
          : null,
    );
  }

  bool _canEditEmployee(
    Role? currentRole,
    Role employeeRole,
    bool canManageEmployees,
    bool canManageManagers,
    bool canManageOwners,
  ) {
    if (currentRole == null) return false;

    switch (currentRole) {
      case Role.superAdmin:
        return true;
      case Role.owner:
        return employeeRole != Role.superAdmin && employeeRole != Role.owner;
      case Role.manager:
        return employeeRole == Role.employee && canManageEmployees;
      case Role.employee:
        return false;
    }
  }

  void _showEditDialog(
      BuildContext context, Employee employee, List<Role> availableRoles) {
    showDialog(
      context: context,
      builder: (context) => EditEmployeeDialog(
        employee: employee,
        availableRoles: availableRoles,
      ),
    );
  }

  void _showAddDialog(BuildContext context, List<Role> availableRoles) {
    showDialog(
      context: context,
      builder: (context) => AddEmployeeDialog(
        availableRoles: availableRoles,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medewerker verwijderen'),
        content:
            Text('Weet je zeker dat je ${employee.name} wilt verwijderen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuleren'),
          ),
          FilledButton.icon(
            onPressed: () {
              final provider = Provider.of<TimeRegistrationProvider>(
                context,
                listen: false,
              );
              provider.deleteEmployee(employee.id);
              _showFeedback(context, 'Medewerker succesvol verwijderd');
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            icon: const Icon(Icons.delete),
            label: const Text('Verwijderen'),
          ),
        ],
      ),
    );
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildEmployeesList(
    BuildContext context,
    List<Employee> employees,
    bool canManageEmployees,
    bool canManageManagers,
    bool canManageOwners,
  ) {
    // Groepeer medewerkers per restaurant
    final employeesByRestaurant = <String?, List<Employee>>{};
    for (final employee in employees) {
      final restaurantId = employee.restaurantId;
      employeesByRestaurant.putIfAbsent(restaurantId, () => []).add(employee);
    }

    return ListView.builder(
      itemCount: employeesByRestaurant.length,
      itemBuilder: (context, index) {
        final restaurantId = employeesByRestaurant.keys.elementAt(index);
        final restaurantEmployees = employeesByRestaurant[restaurantId]!;
        final provider = Provider.of<TimeRegistrationProvider>(context);
        final restaurant = restaurantId != null
            ? provider.restaurants.firstWhere((r) => r.id == restaurantId)
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                restaurant?.name ?? 'Geen Restaurant',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: restaurantEmployees.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final employee = restaurantEmployees[index];
                final canEditThisEmployee = _canEditEmployee(
                  provider.currentEmployee?.role,
                  employee.role,
                  canManageEmployees,
                  canManageManagers,
                  canManageOwners,
                );

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      employee.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(employee.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(employee.function),
                      Text(
                        employee.role.toString().split('.').last,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                      if (employee.restaurantId != null)
                        Text(
                          'Restaurant ID: ${employee.restaurantId}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  trailing: canEditThisEmployee
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditDialog(
                                context,
                                employee,
                                _getAvailableRoles(canManageOwners,
                                    canManageManagers, canManageEmployees),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _showDeleteDialog(context, employee),
                            ),
                          ],
                        )
                      : null,
                );
              },
            ),
            const Divider(height: 32, thickness: 2),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, List<Employee> employees) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _filterRestaurantName != null
                  ? 'Medewerkers - $_filterRestaurantName'
                  : 'Medewerkers Overzicht',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${employees.length} medewerkers in totaal',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 24),
            // Zoek en filter balk
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Zoek medewerkers...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('Alle')),
                    ButtonSegment(value: 'active', label: Text('Actief')),
                    ButtonSegment(value: 'inactive', label: Text('Inactief')),
                  ],
                  selected: const {'all'},
                  onSelectionChanged: (Set<String> selection) {
                    setState(() => _filterStatus = selection.first);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddEmployeeDialog extends StatefulWidget {
  const AddEmployeeDialog({super.key, required this.availableRoles});

  final List<Role> availableRoles;

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final _nameController = TextEditingController();
  final _functionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Role? _selectedRole;
  String? _selectedRestaurantId;

  @override
  void dispose() {
    _nameController.dispose();
    _functionController.dispose();
    super.dispose();
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeRegistrationProvider>(context);
    final restaurants = provider.restaurants.where((r) => r.isActive).toList();

    return AlertDialog(
      title: const Text('Nieuwe Medewerker'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Naam',
                  hintText: 'Voer de naam in',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vul een naam in';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _functionController,
                decoration: const InputDecoration(
                  labelText: 'Functie',
                  hintText: 'Voer de functie in',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vul een functie in';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Role>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  hintText: 'Selecteer een rol',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.admin_panel_settings),
                ),
                items: widget.availableRoles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (Role? value) {
                  setState(() => _selectedRole = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecteer een rol';
                  }
                  return null;
                },
              ),
              if (_selectedRole != Role.superAdmin) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRestaurantId,
                  decoration: const InputDecoration(
                    labelText: 'Restaurant',
                    hintText: 'Selecteer een restaurant',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  items: restaurants.map((restaurant) {
                    return DropdownMenuItem(
                      value: restaurant.id,
                      child: Text(restaurant.name),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() => _selectedRestaurantId = value);
                  },
                  validator: (value) {
                    if (_selectedRole != Role.superAdmin && value == null) {
                      return 'Selecteer een restaurant';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        FilledButton.icon(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final provider = Provider.of<TimeRegistrationProvider>(
                context,
                listen: false,
              );
              provider.addEmployee(
                _nameController.text,
                _functionController.text,
                _selectedRole!,
                restaurantId: _selectedRestaurantId,
              );
              _showFeedback(context, 'Medewerker succesvol toegevoegd');
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(Icons.save),
          label: const Text('Toevoegen'),
        ),
      ],
    );
  }
}
