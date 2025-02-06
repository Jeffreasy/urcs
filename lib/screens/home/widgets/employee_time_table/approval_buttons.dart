import 'package:flutter/material.dart';
import '../../../../models/time_registration.dart';

class ApprovalButtons extends StatelessWidget {
  final TimeRegistration registration;
  final void Function(TimeRegistration, bool) onApprove;

  const ApprovalButtons({
    super.key,
    required this.registration,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ApprovalButton(
            icon: Icons.check,
            color: Colors.green,
            tooltip: 'Goedkeuren',
            onPressed: () => onApprove(registration, true),
          ),
          const SizedBox(width: 4.0),
          _ApprovalButton(
            icon: Icons.close,
            color: Colors.red,
            tooltip: 'Afkeuren',
            onPressed: () => onApprove(registration, false),
          ),
        ],
      ),
    );
  }
}

class _ApprovalButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _ApprovalButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 16.0,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
