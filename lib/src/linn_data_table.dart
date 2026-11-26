import 'package:flutter/material.dart';

import 'linn_alert.dart';
import 'linn_state.dart';
import 'linn_status_badge.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// A horizontally scrollable table with loading, empty, and error views.
///
/// Use Flutter's [DataColumn] and [DataRow] to supply columns and rows. The
/// caller owns row order and selection. [DataColumn.onSort] requests a sort.
class LinnDataTable extends StatelessWidget {
  const LinnDataTable({
    required this.columns,
    required this.rows,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.state = LinnState.idle,
    this.message,
    this.emptyMessage = 'No records to display.',
    this.onRetry,
    this.showCheckboxColumn = true,
    this.style,
    super.key,
  });

  final List<DataColumn> columns;
  final List<DataRow> rows;
  final int? sortColumnIndex;
  final bool sortAscending;
  final LinnState state;
  final LinnThemeData? style;
  final String? message;
  final String emptyMessage;
  final VoidCallback? onRetry;
  final bool showCheckboxColumn;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final placeholder = switch (state) {
      LinnState.loading => 'Loading records',
      LinnState.error => 'Couldn’t load records',
      LinnState.disabled => 'Table unavailable',
      _ => rows.isEmpty ? emptyMessage : null,
    };
    if (placeholder != null) {
      final retry = state == LinnState.error ? onRetry : null;
      return LinnAlert(
        title: placeholder,
        state: state,
        message: message,
        actionLabel: retry != null ? 'Retry' : null,
        onAction: retry,
      );
    }

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: LinnStyle.radius(context),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state == LinnState.success)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: LinnStatusBadge(
                label: message ?? 'Records loaded',
                state: state,
              ),
            ),
          _TableScroll(
            child: DataTable(
              columns: columns,
              rows: rows,
              sortColumnIndex: sortColumnIndex,
              sortAscending: sortAscending,
              showCheckboxColumn: showCheckboxColumn,
              horizontalMargin: 14,
              columnSpacing: 20,
              headingRowHeight: 48,
              headingRowColor: WidgetStatePropertyAll(
                scheme.surfaceContainerLow,
              ),
              dataRowMaxHeight: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableScroll extends StatefulWidget {
  const _TableScroll({required this.child});

  final Widget child;

  @override
  State<_TableScroll> createState() => _TableScrollState();
}

class _TableScrollState extends State<_TableScroll> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: constraints.hasBoundedWidth ? constraints.maxWidth : 0,
          ),
          child: widget.child,
        ),
      ),
    ),
  );
}
