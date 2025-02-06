import 'package:flutter/material.dart';
import '../../../../models/annual_note.dart';
import 'package:intl/intl.dart';

class AnnualNotes extends StatelessWidget {
  final List<AnnualNote> notes;
  final ValueChanged<String> onNoteAdded;
  final VoidCallback onNoteDeleted;

  const AnnualNotes({
    super.key,
    required this.notes,
    required this.onNoteAdded,
    required this.onNoteDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Notities'),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddNoteDialog(context),
            ),
          ),
          if (notes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Geen notities'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return ListTile(
                  title: Text(note.text),
                  subtitle: Text(
                    DateFormat('dd-MM-yyyy HH:mm').format(note.date),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onNoteDeleted,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _showAddNoteDialog(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notitie toevoegen'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Typ hier je notitie...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onNoteAdded(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Toevoegen'),
          ),
        ],
      ),
    );
  }
}
