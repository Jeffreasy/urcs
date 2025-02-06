import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

class BaseTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double? minWidth;
  final double columnSpacing;
  final bool fixedLeftColumns;
  final Color headingRowColor;

  const BaseTable({
    super.key,
    required this.columns,
    required this.rows,
    this.minWidth,
    this.columnSpacing = 56.0,
    this.fixedLeftColumns = true,
    required this.headingRowColor,
  });

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable2(
      columnSpacing: columnSpacing,
      horizontalMargin: 12,
      minWidth: minWidth,
      fixedLeftColumns: fixedLeftColumns ? 3 : 0,
      headingRowColor: WidgetStateProperty.all(headingRowColor),
      columns: columns,
      source: _TableDataSource(rows),
      rowsPerPage: 20,
      showFirstLastButtons: true,
      showCheckboxColumn: false,
    );
  }
}

class _TableDataSource extends DataTableSource {
  final List<DataRow> _rows;

  _TableDataSource(this._rows);

  @override
  DataRow? getRow(int index) => index < _rows.length ? _rows[index] : null;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _rows.length;

  @override
  int get selectedRowCount => 0;
}
