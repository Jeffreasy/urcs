import 'package:flutter/material.dart';
import '../../../../models/time_registration.dart';
import '../../../../providers/time_registration_provider.dart';
import 'package:provider/provider.dart';

class TimeDisplay extends StatelessWidget {
  final DateTime date;
  final String employeeId;
  final TimeRegistration? registration;
  final bool isStartTime;
  final void Function(DateTime, String, bool) onTap;

  const TimeDisplay({
    super.key,
    required this.date,
    required this.employeeId,
    required this.registration,
    required this.isStartTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TimeOfDay? time = registration != null
        ? (isStartTime ? registration!.startTime : registration!.endTime)
        : null;

    // Gebruik de provider voor rechtencontrole
    final provider = Provider.of<TimeRegistrationProvider>(context);
    final bool canEdit = provider.canEditRegistration(employeeId, registration);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canEdit ? () => onTap(date, employeeId, isStartTime) : null,
        borderRadius: BorderRadius.circular(6),
        splashColor: canEdit
            ? theme.colorScheme.primary.withAlpha((0.2 * 255).round())
            : Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withAlpha((0.3 * 255).round()),
            ),
            borderRadius: BorderRadius.circular(6),
            color: !canEdit ? theme.colorScheme.surface.withAlpha(30) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isStartTime ? Icons.login : Icons.logout,
                size: 14,
                color: theme.colorScheme.primary.withAlpha((0.7 * 255).round()),
              ),
              const SizedBox(width: 4),
              Text(
                time?.format(context) ?? '--:--',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: time == null
                      ? theme.colorScheme.outline.withAlpha((0.3 * 255).round())
                      : theme.colorScheme.onSurface
                          .withAlpha((0.8 * 255).round()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
