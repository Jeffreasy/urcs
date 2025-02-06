import 'package:flutter/material.dart';
import '../../../../models/employee.dart';

class EmployeeCell extends StatelessWidget {
  final Employee employee;

  const EmployeeCell({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 160,
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: theme.colorScheme.primaryContainer.withAlpha(76),
            child: Text(
              employee.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onPrimaryContainer.withAlpha(204),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  employee.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  employee.function,
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
