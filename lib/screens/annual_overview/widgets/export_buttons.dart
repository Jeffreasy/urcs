import 'package:flutter/material.dart';

class ExportButtons extends StatelessWidget {
  final VoidCallback onExportToPdf;
  final VoidCallback onExportToExcel;
  final VoidCallback onExportToCsv;

  const ExportButtons({
    super.key,
    required this.onExportToPdf,
    required this.onExportToExcel,
    required this.onExportToCsv,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          onPressed: onExportToPdf,
          tooltip: 'Exporteer naar PDF',
        ),
        IconButton(
          icon: const Icon(Icons.table_chart),
          onPressed: onExportToExcel,
          tooltip: 'Exporteer naar Excel',
        ),
        IconButton(
          icon: const Icon(Icons.code),
          onPressed: onExportToCsv,
          tooltip: 'Exporteer naar CSV',
        ),
      ],
    );
  }
}
