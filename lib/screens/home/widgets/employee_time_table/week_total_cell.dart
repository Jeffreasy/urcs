import 'package:flutter/material.dart';

class WeekTotalCell extends StatelessWidget {
  final double weekTotal;

  const WeekTotalCell({super.key, required this.weekTotal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasHours = weekTotal > 0;

    return Container(
      width: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            hasHours ? theme.colorScheme.primaryContainer.withAlpha(30) : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        hasHours ? '${weekTotal.toStringAsFixed(1)}\nuur' : '-',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: hasHours
              ? theme.colorScheme.primary.withAlpha(100)
              : theme.colorScheme.outline.withAlpha(30),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
