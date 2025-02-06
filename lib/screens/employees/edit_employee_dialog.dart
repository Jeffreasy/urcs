import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/employee.dart';
import '../../providers/time_registration_provider.dart';
import '../../models/role.dart';

class EditEmployeeDialog extends StatefulWidget {
  final Employee employee;
  final List<Role> availableRoles;

  const EditEmployeeDialog({
    super.key,
    required this.employee,
    required this.availableRoles,
  });

  @override
  State<EditEmployeeDialog> createState() => _EditEmployeeDialogState();
}

class _EditEmployeeDialogState extends State<EditEmployeeDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _functionController;
  final _formKey = GlobalKey<FormState>();
  late Role _selectedRole;
  String? _selectedRestaurantId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee.name);
    _functionController = TextEditingController(text: widget.employee.function);
    _selectedRole = widget.employee.role;
    _selectedRestaurantId = widget.employee.restaurantId;
  }

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
      title: const Text('Medewerker Bewerken'),
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
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                      // Reset restaurant als we naar superAdmin gaan
                      if (value == Role.superAdmin) {
                        _selectedRestaurantId = null;
                      }
                    });
                  }
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
              provider.updateEmployee(
                widget.employee.id,
                _nameController.text,
                _functionController.text,
                _selectedRole,
                restaurantId: _selectedRestaurantId,
              );
              _showFeedback(context, 'Medewerker succesvol bijgewerkt');
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(Icons.save),
          label: const Text('Opslaan'),
        ),
      ],
    );
  }
}
