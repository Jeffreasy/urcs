import 'package:flutter/material.dart';
import '../../../../models/time_registration.dart';

class HoursDisplay extends StatelessWidget {
  final TimeRegistration? registration;

  const HoursDisplay({
    super.key,
    required this.registration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Als er geen registratie is, toon dan een placeholder.
    if (registration == null) {
      return Text(
        '-',
        style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontSize: 11,
            ) ??
            const TextStyle(fontSize: 11, color: Colors.grey),
      );
    }

    final reg = registration!;
    final hours = reg.totalHours;
    final statusColor = switch (reg.status) {
      RegistrationStatus.approved => Colors.green,
      RegistrationStatus.rejected => Colors.red,
      RegistrationStatus.pending => Colors.orange,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Verlaagde verticale padding (van 4 naar 2) om ruimte te besparen.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: statusColor.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(6),
            border:
                Border.all(color: statusColor.withAlpha((0.3 * 255).round())),
          ),
          child: Text(
            '${hours.toStringAsFixed(1)} u',
            style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ) ??
                TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor),
          ),
        ),
        // Als er een notitie is, toon dan de info-icoon met iets minder top-padding.
        if (reg.note != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Tooltip(
              message: reg.note!,
              child: Icon(
                Icons.info_outline,
                size: 14,
                color: statusColor,
              ),
            ),
          ),
      ],
    );
  }
}
