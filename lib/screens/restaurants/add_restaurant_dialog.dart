import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/time_registration_provider.dart';

class AddRestaurantDialog extends StatefulWidget {
  const AddRestaurantDialog({super.key});

  @override
  State<AddRestaurantDialog> createState() => _AddRestaurantDialogState();
}

class _AddRestaurantDialogState extends State<AddRestaurantDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nieuw Restaurant'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Naam',
                hintText: 'Voer de naam in',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vul een naam in';
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
            if (_formKey.currentState!.validate()) {
              final provider =
                  Provider.of<TimeRegistrationProvider>(context, listen: false);
              provider.addRestaurant(_nameController.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Toevoegen'),
        ),
      ],
    );
  }
}
