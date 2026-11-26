import 'package:flutter/material.dart';

import 'linn_data_table.dart';
import 'linn_state.dart';
import 'linn_status_dot.dart';
import 'linn_style.dart';
import 'linn_theme.dart';
import 'linn_workflow_menus.dart';

/// A label and color for a business status in a table cell.
typedef LinnTableStatus = ({String label, LinnStatusTone tone});

typedef LinnSalesRow = ({
  String enquiry,
  String customer,
  String project,
  LinnTableStatus potential,
  String? surveyTeam,
  DateTime? surveyDate,
  DateTime? lastUpdate,
});

typedef LinnEngineeringRow = ({
  String project,
  String customer,
  String phone,
  LinnTableStatus status,
  String? surveyTeam,
  DateTime? surveyDate,
});

typedef LinnBoqCostingRow = ({
  String boq,
  String project,
  int estimatedCost,
  LinnTableStatus approval,
});

typedef LinnSupplyChainRow = ({
  String item,
  int quantity,
  String supplier,
  int unitPrice,
  int total,
});

typedef LinnProcurementRow = ({
  String item,
  String supplier,
  LinnTableStatus status,
  int leadTimeDays,
  DateTime? arrivalDate,
});

typedef LinnSupplierRow = ({
  String supplier,
  String contact,
  int items,
  int termsDays,
  int spend,
});

typedef LinnStockRow = ({
  String item,
  String warehouse,
  int onHand,
  int toBuy,
  int ordered,
  LinnStockAvailability availability,
});

/// Sortable survey enquiries with customer, potential, and assignment details.
class LinnSalesTable extends _OperationalTable<LinnSalesRow> {
  const LinnSalesTable({
    required super.rows,
    super.state,
    super.message,
    super.onRetry,
    super.onDetails,
    super.onEdit,
    super.style,
    super.key,
  }) : super(emptyMessage: 'No sales enquiries.');

  @override
  List<_Column<LinnSalesRow>> get _columns => [
    _Column.text('Enquiry', (row) => row.enquiry),
    _Column.text('Customer', (row) => row.customer),
    _Column.text('Project', (row) => row.project),
    _Column.status('Potential', (row) => row.potential),
    _Column.text('Survey team', (row) => row.surveyTeam),
    _Column.date('Survey date', (row) => row.surveyDate),
    _Column.date('Last update', (row) => row.lastUpdate),
  ];
}

/// Sortable engineering assignments with status and survey dates.
class LinnEngineeringTable extends _OperationalTable<LinnEngineeringRow> {
  const LinnEngineeringTable({
    required super.rows,
    super.state,
    super.message,
    super.onRetry,
    super.onDetails,
    super.style,
    super.key,
  }) : super(emptyMessage: 'No engineering assignments.');

  @override
  List<_Column<LinnEngineeringRow>> get _columns => [
    _Column.text('Project', (row) => row.project),
    _Column.text('Customer', (row) => row.customer),
    _Column.text('Phone', (row) => row.phone),
    _Column.status('Status', (row) => row.status),
    _Column.text('Survey team', (row) => row.surveyTeam),
    _Column.date('Survey date', (row) => row.surveyDate),
  ];
}

/// Sortable bills of quantities with cost estimates and approval status.
class LinnBoqCostingTable extends _OperationalTable<LinnBoqCostingRow> {
  const LinnBoqCostingTable({
    required super.rows,
    this.currency = 'MMK',
    super.state,
    super.message,
    super.onRetry,
    super.onDetails,
    super.onEdit,
    super.style,
    super.key,
  }) : super(emptyMessage: 'No cost estimates.');

  /// Currency code for the integer amounts in [rows].
  final String currency;

  @override
  List<_Column<LinnBoqCostingRow>> get _columns => [
    _Column.text('BOQ', (row) => row.boq),
    _Column.text('Project', (row) => row.project),
    _Column.number(
      'Estimated cost',
      (row) => row.estimatedCost,
      unit: currency,
    ),
    _Column.status('Approval', (row) => row.approval),
  ];
}

/// Sortable material quantities, unit prices, and totals.
class LinnSupplyChainTable extends _OperationalTable<LinnSupplyChainRow> {
  const LinnSupplyChainTable({
    required super.rows,
    this.currency = 'MMK',
    super.state,
    super.message,
    super.onRetry,
    super.onDetails,
    super.onEdit,
    super.onDelete,
    super.style,
    super.key,
  }) : super(emptyMessage: 'No supply items.');

  final String currency;

  @override
  List<_Column<LinnSupplyChainRow>> get _columns => [
    _Column.text('Item', (row) => row.item),
    _Column.number('Qty', (row) => row.quantity),
    _Column.text('Supplier', (row) => row.supplier),
    _Column.number('Price per unit', (row) => row.unitPrice, unit: currency),
    _Column.number('Total', (row) => row.total, unit: currency),
  ];
}

/// Sortable procurements with delivery status, lead time, and arrival date.
class LinnProcurementTable extends _OperationalTable<LinnProcurementRow> {
  const LinnProcurementTable({
    required super.rows,
    super.state,
    super.message,
    super.onRetry,
    super.onDetails,
    super.onEdit,
    super.onDelete,
    super.style,
    super.key,
  }) : super(emptyMessage: 'No procurement records.');

  @override
  List<_Column<LinnProcurementRow>> get _columns => [
    _Column.text('Item', (row) => row.item),
    _Column.text('Supplier', (row) => row.supplier),
    _Column.status('Status', (row) => row.status),
    _Column.number('Lead time (days)', (row) => row.leadTimeDays),
    _Column.date('Arrives', (row) => row.arrivalDate),
  ];
}

/// Sortable supplier contacts, payment terms, and spend.
class LinnSupplierTable extends _OperationalTable<LinnSupplierRow> {
  const LinnSupplierTable({
    required super.rows,
    this.currency = 'MMK',
    super.state,
    super.message,
    super.onRetry,
    super.onDetails,
    super.onEdit,
    super.onDelete,
    super.style,
    super.key,
  }) : super(emptyMessage: 'No suppliers.');

  final String currency;

  @override
  List<_Column<LinnSupplierRow>> get _columns => [
    _Column.text('Supplier', (row) => row.supplier),
    _Column.text('Contact', (row) => row.contact),
    _Column.number('Items', (row) => row.items),
    _Column.number('Terms (days)', (row) => row.termsDays),
    _Column.number('Spend', (row) => row.spend, unit: currency),
  ];
}

/// Sortable stock quantities and availability by warehouse.
class LinnStockTable extends _OperationalTable<LinnStockRow> {
  const LinnStockTable({
    required super.rows,
    super.state,
    super.message,
    super.onRetry,
    super.onDetails,
    super.onEdit,
    super.onDelete,
    super.style,
    super.key,
  }) : super(emptyMessage: 'No stock records.');

  @override
  List<_Column<LinnStockRow>> get _columns => [
    _Column.text('Item', (row) => row.item),
    _Column.text('Warehouse', (row) => row.warehouse),
    _Column.number('On hand', (row) => row.onHand),
    _Column.number('To buy', (row) => row.toBuy),
    _Column.number('Ordered', (row) => row.ordered),
    _Column.status(
      'Status',
      (row) => (label: row.availability.label, tone: row.availability.tone),
    ),
  ];
}

abstract class _OperationalTable<T> extends StatefulWidget {
  const _OperationalTable({
    required this.rows,
    required this.emptyMessage,
    this.state = LinnState.idle,
    this.message,
    this.onRetry,
    this.onDetails,
    this.onEdit,
    this.onDelete,
    this.style,
    super.key,
  });

  final List<T> rows;
  final String emptyMessage;
  final LinnState state;
  final LinnThemeData? style;
  final String? message;
  final VoidCallback? onRetry;
  final ValueChanged<T>? onDetails;
  final ValueChanged<T>? onEdit;
  final ValueChanged<T>? onDelete;

  List<_Column<T>> get _columns;

  @override
  State<_OperationalTable<T>> createState() => _OperationalTableState<T>();
}

class _OperationalTableState<T> extends State<_OperationalTable<T>> {
  int? _sortColumn;
  bool _ascending = true;

  @override
  Widget build(BuildContext context) =>
      LinnStyle.scope(context, widget.style, _build);

  Widget _build(BuildContext context) {
    final columns = widget._columns;
    final rows = widget.rows.indexed.toList();
    final sortedBy = _sortColumn;
    if (sortedBy != null) {
      final compare = columns[sortedBy].compare;
      rows.sort((a, b) {
        final result = _ascending ? compare(a.$2, b.$2) : compare(b.$2, a.$2);
        return result == 0 ? a.$1.compareTo(b.$1) : result;
      });
    }
    final actions = [
      if (widget.onDetails case final details?) ('Details', details),
      if (widget.onEdit case final edit?) ('Edit', edit),
      if (widget.onDelete case final delete?) ('Delete', delete),
    ];

    return LinnDataTable(
      state: widget.state,
      message: widget.message,
      onRetry: widget.onRetry,
      emptyMessage: widget.emptyMessage,
      sortColumnIndex: sortedBy,
      sortAscending: _ascending,
      showCheckboxColumn: false,
      columns: [
        for (final column in columns)
          DataColumn(
            label: Text(column.label),
            numeric: column.numeric,
            onSort: (index, ascending) => setState(() {
              _sortColumn = index;
              _ascending = ascending;
            }),
          ),
        if (actions.isNotEmpty) const DataColumn(label: Text('Actions')),
      ],
      rows: [
        for (final (index, row) in rows)
          DataRow.byIndex(
            index: index,
            cells: [
              for (final column in columns) DataCell(column.cell(context, row)),
              if (actions.isNotEmpty)
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final (label, action) in actions)
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: LinnStyle.accent(
                              context,
                              label == 'Delete'
                                  ? LinnState.error
                                  : LinnState.idle,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: LinnStyle.radius(context),
                            ),
                          ),
                          onPressed: () => action(row),
                          child: Text(label),
                        ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _Column<T> {
  const _Column(this.label, this.compare, this.cell, {this.numeric = false});

  factory _Column.text(String label, String? Function(T) read) => _Column(
    label,
    (a, b) =>
        (read(a) ?? '').toLowerCase().compareTo((read(b) ?? '').toLowerCase()),
    (_, row) => Text(read(row) ?? '—'),
  );

  factory _Column.number(String label, int Function(T) read, {String? unit}) =>
      _Column(label, (a, b) => read(a).compareTo(read(b)), (context, row) {
        final value = MaterialLocalizations.of(
          context,
        ).formatDecimal(read(row));
        return Text(unit == null ? value : '$value $unit');
      }, numeric: true);

  factory _Column.date(String label, DateTime? Function(T) read) => _Column(
    label,
    (a, b) {
      final left = read(a);
      final right = read(b);
      if (left == null) return right == null ? 0 : -1;
      return right == null ? 1 : left.compareTo(right);
    },
    (context, row) {
      final date = read(row);
      return Text(
        date == null
            ? '—'
            : MaterialLocalizations.of(context).formatShortDate(date.toLocal()),
      );
    },
  );

  factory _Column.status(String label, LinnTableStatus Function(T) read) =>
      _Column(
        label,
        (a, b) =>
            read(a).label.toLowerCase().compareTo(read(b).label.toLowerCase()),
        (_, row) {
          final status = read(row);
          return LinnStatusDot(label: status.label, tone: status.tone);
        },
      );

  final String label;
  final Comparator<T> compare;
  final Widget Function(BuildContext, T) cell;
  final bool numeric;
}
