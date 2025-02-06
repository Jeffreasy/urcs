import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/role.dart';
import '../../providers/time_registration_provider.dart';

class AddEmployeeDialog extends StatefulWidget {
  final List<Role> availableRoles;

  const AddEmployeeDialog({
    super.key,
    required this.availableRoles,
  });

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final _nameController = TextEditingController();
  final _functionController = TextEditingController();
  Role? _selectedRole;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nieuwe Medewerker'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Naam',
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
              ),
              items: widget.availableRoles.map((role) => DropdownMenuItem(
                value: role,
                child: Text(role.toString().split('.').last),
              )).toList(),
              onChanged: (Role? newRole) {
                setState(() => _selectedRole = newRole);
              },
              validator: (value) {
                if (value == null) {
                  return 'Selecteer een rol';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _selectedRole != null) {
              final provider = Provider.of<TimeRegistrationProvider>(
                context, 
                listen: false
              );
              provider.addEmployee(
                _nameController.text,
                _functionController.text,
                _selectedRole!,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Toevoegen'),
        ),
      ],
    );
  }
} 