import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekNavigator extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final bool isToday;

  const WeekNavigator({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.isToday,
  });

  Future<void> _showWeekPicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025, 12, 31), // Aangepast: hele 2025 toestaan
      locale: const Locale('nl', 'NL'),
    );
    if (picked != null) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekNumber = DateFormat('w').format(selectedDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: () => onDateChanged(
            selectedDate.subtract(const Duration(days: 7)),
          ),
        ),
        InkWell(
          onTap: () {
            if (!isToday) {
              // Als de geselecteerde datum niet vandaag is, zet deze dan direct op vandaag.
              onDateChanged(DateTime.now());
            } else {
              // Als de geselecteerde datum al vandaag is, open dan de datumkiezer.
              _showWeekPicker(context);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primaryContainer.withAlpha(76),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isToday
                      ? 'Week $weekNumber, ${selectedDate.year}'
                      : 'Naar vandaag',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isToday ? Icons.calendar_month : Icons.today,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: () => onDateChanged(
            selectedDate.add(const Duration(days: 7)),
          ),
        ),
      ],
    );
  }
}
