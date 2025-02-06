import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayHeader extends StatelessWidget {
  final DateTime date;
  final bool isToday;

  const DayHeader({
    super.key,
    required this.date,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayAbbreviation = DateFormat('E').format(date);
    final dayMonth = DateFormat('d MMM').format(date);

    return SizedBox(
      width: 100,
      height: 70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isToday
                  ? theme.colorScheme.primary.withAlpha((0.1 * 255).round())
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              dayAbbreviation,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isToday
                    ? theme.colorScheme.primary
                    : theme.textTheme.titleMedium?.color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dayMonth,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
