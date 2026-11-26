part of 'main.dart';

class _OperationsPreviews extends StatefulWidget {
  const _OperationsPreviews({
    required this.state,
    required this.onRetry,
    super.key,
  });

  final LinnState state;
  final VoidCallback onRetry;

  @override
  State<_OperationsPreviews> createState() => _OperationsPreviewsState();
}

class _OperationsPreviewsState extends State<_OperationsPreviews> {
  static const _teams = {'atlas': 'Team Atlas', 'cedar': 'Team Cedar'};
  static const _high = (label: 'High potential', tone: LinnStatusTone.success);
  static const _medium = (
    label: 'Medium potential',
    tone: LinnStatusTone.warning,
  );
  static const _pending = (label: 'Pending', tone: LinnStatusTone.warning);
  static const _active = (label: 'In progress', tone: LinnStatusTone.info);
  static const _approved = (label: 'Approved', tone: LinnStatusTone.success);

  String? _team = 'atlas';
  LinnScheduleStatus _schedule = LinnScheduleStatus.scheduled;
  LinnStockAvailability _availability = LinnStockAvailability.inStock;
  LinnReviewDecision _decision = LinnReviewDecision.pending;
  String? _assignedTeam;

  void _feedback(String message) =>
      LinnSnackbar(message: message, state: LinnState.success).show(context);

  void _showRecord(String title, String details) => LinnDialog(
    title: title,
    message: details,
    icon: Icons.description_outlined,
    confirmLabel: MaterialLocalizations.of(context).closeButtonLabel,
    showCancel: false,
  ).show(context);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.state;
    final retry = widget.onRetry;
    final stateName = 'LinnState.${state.name}';
    final salesRows = <LinnSalesRow>[
      (
        enquiry: 'P-001',
        customer: 'North Market',
        project: 'Market rooftop',
        potential: _high,
        surveyTeam: 'Team Atlas',
        surveyDate: DateTime(2026, 11, 24),
        lastUpdate: DateTime(2026, 11, 22),
      ),
      (
        enquiry: 'P-002',
        customer: 'Riverside',
        project: 'Warehouse installation',
        potential: _medium,
        surveyTeam: null,
        surveyDate: null,
        lastUpdate: DateTime(2026, 11, 20),
      ),
    ];
    final engineeringRows = <LinnEngineeringRow>[
      (
        project: 'Market rooftop',
        customer: 'North Market',
        phone: 'Ext. 102',
        status: _active,
        surveyTeam: 'Team Atlas',
        surveyDate: DateTime(2026, 11, 24),
      ),
      (
        project: 'Lakeview expansion',
        customer: 'Lakeview',
        phone: 'Ext. 208',
        status: _approved,
        surveyTeam: 'Team Cedar',
        surveyDate: DateTime(2026, 11, 26),
      ),
    ];
    const costingRows = <LinnBoqCostingRow>[
      (
        boq: 'BOQ-0042',
        project: 'Market rooftop',
        estimatedCost: 9515000,
        approval: _pending,
      ),
      (
        boq: 'BOQ-0043',
        project: 'Lakeview expansion',
        estimatedCost: 4275000,
        approval: _approved,
      ),
    ];
    const supplyRows = <LinnSupplyChainRow>[
      (
        item: '6 kW inverter',
        quantity: 6,
        supplier: 'Gridline Supply',
        unitPrice: 380000,
        total: 2280000,
      ),
      (
        item: 'Roof mount kit',
        quantity: 12,
        supplier: 'Roofline Parts',
        unitPrice: 48000,
        total: 576000,
      ),
    ];
    final procurementRows = <LinnProcurementRow>[
      (
        item: '6 kW inverter',
        supplier: 'Gridline Supply',
        status: (label: 'Delivered', tone: LinnStatusTone.success),
        leadTimeDays: 14,
        arrivalDate: DateTime(2026, 12, 10),
      ),
      (
        item: 'Roof mount kit',
        supplier: 'Roofline Parts',
        status: (label: 'On order', tone: LinnStatusTone.info),
        leadTimeDays: 7,
        arrivalDate: DateTime(2026, 12, 15),
      ),
    ];
    const supplierRows = <LinnSupplierRow>[
      (
        supplier: 'Gridline Supply',
        contact: 'Orders team',
        items: 6,
        termsDays: 14,
        spend: 2280000,
      ),
      (
        supplier: 'Roofline Parts',
        contact: 'Trade desk',
        items: 12,
        termsDays: 30,
        spend: 576000,
      ),
    ];
    final stockRows = <LinnStockRow>[
      (
        item: '6 kW inverter',
        warehouse: 'Central',
        onHand: 6,
        toBuy: 0,
        ordered: 2,
        availability: _availability,
      ),
      (
        item: 'Roof mount kit',
        warehouse: 'North',
        onHand: 3,
        toBuy: 9,
        ordered: 0,
        availability: LinnStockAvailability.orderNeeded,
      ),
    ];

    final tables = [
      _tableCard(
        26,
        'LinnSalesTable',
        'salesRows',
        LinnSalesTable(
          key: const ValueKey('preview-sales-table'),
          rows: salesRows,
          state: state,
          onRetry: retry,
          onDetails: (row) =>
              _showRecord(row.enquiry, '${row.project}\n${row.customer}'),
        ),
      ),
      _tableCard(
        27,
        'LinnEngineeringTable',
        'engineeringRows',
        LinnEngineeringTable(
          rows: engineeringRows,
          state: state,
          onRetry: retry,
          onDetails: (row) =>
              _showRecord(row.project, '${row.customer}\n${row.status.label}'),
        ),
      ),
      _tableCard(
        28,
        'LinnBoqCostingTable',
        'costingRows',
        LinnBoqCostingTable(
          rows: costingRows,
          state: state,
          onRetry: retry,
          onDetails: (row) =>
              _showRecord(row.boq, '${row.project}\n${row.approval.label}'),
        ),
      ),
      _tableCard(
        29,
        'LinnSupplyChainTable',
        'supplyRows',
        LinnSupplyChainTable(
          rows: supplyRows,
          state: state,
          onRetry: retry,
          onDetails: (row) => _showRecord(
            row.item,
            'Supplier · ${row.supplier}\nQuantity · ${row.quantity}',
          ),
        ),
      ),
      _tableCard(
        30,
        'LinnProcurementTable',
        'procurementRows',
        LinnProcurementTable(
          rows: procurementRows,
          state: state,
          onRetry: retry,
          onDetails: (row) => _showRecord(
            row.item,
            '${row.status.label}\nLead time · ${row.leadTimeDays} days',
          ),
        ),
      ),
      _tableCard(
        31,
        'LinnSupplierTable',
        'supplierRows',
        LinnSupplierTable(
          rows: supplierRows,
          state: state,
          onRetry: retry,
          onDetails: (row) => _showRecord(
            row.supplier,
            '${row.contact}\nPayment terms · ${row.termsDays} days',
          ),
        ),
      ),
      _tableCard(
        32,
        'LinnStockTable',
        'stockRows',
        LinnStockTable(
          key: const ValueKey('preview-stock-table'),
          rows: stockRows,
          state: state,
          onRetry: retry,
        ),
      ),
    ];
    final controls = [
      _ComponentCard(
        number: 33,
        title: 'LinnTeamPicker',
        codeHeight: 160,
        code:
            """LinnTeamPicker(
  teams: teams,
  value: teamId,
  state: $stateName,
  onChanged: selectTeam,
)""",
        child: LinnTeamPicker(
          key: const ValueKey('preview-team-picker'),
          teams: _teams,
          value: _team,
          state: state,
          onChanged: (team) => setState(() => _team = team),
        ),
      ),
      _ComponentCard(
        number: 34,
        title: 'LinnScheduleStatusMenu',
        codeHeight: 160,
        code:
            """LinnScheduleStatusMenu(
  value: LinnScheduleStatus.${_schedule.name},
  state: $stateName,
  onChanged: updateSchedule,
)""",
        child: LinnScheduleStatusMenu(
          key: const ValueKey('preview-schedule-status'),
          value: _schedule,
          state: state,
          onChanged: (status) => setState(() => _schedule = status),
        ),
      ),
      _ComponentCard(
        number: 35,
        title: 'LinnStockAvailabilityMenu',
        codeHeight: 160,
        code:
            """LinnStockAvailabilityMenu(
  value: LinnStockAvailability.${_availability.name},
  state: $stateName,
  onChanged: updateStock,
)""",
        child: LinnStockAvailabilityMenu(
          key: const ValueKey('preview-stock-availability'),
          value: _availability,
          state: state,
          onChanged: (availability) =>
              setState(() => _availability = availability),
          message: 'Updates the inverter in table 32.',
        ),
      ),
      _ComponentCard(
        number: 36,
        title: 'LinnWorkflowActions',
        codeHeight: 240,
        previewHeight: 240,
        code:
            """LinnWorkflowActions(
  state: $stateName,
  onEdit: editDraft,
  onCancel: cancel,
  onContinue: nextStep,
)""",
        child: LinnWorkflowActions(
          key: const ValueKey('preview-workflow-actions'),
          state: state,
          onEdit: () => _showRecord('Edit draft', 'Market rooftop survey'),
          onCancel: () => _feedback('Review closed.'),
          onContinue: () => _feedback('Ready for the next step.'),
        ),
      ),
      _ComponentCard(
        number: 37,
        title: 'LinnApprovalAssignment',
        codeHeight: 240,
        previewHeight: 240,
        code:
            """LinnApprovalAssignment(
  decision: LinnReviewDecision.${_decision.name},
  teams: teams,
  teamId: teamId,
  state: $stateName,
  onApprove: approveRequest,
  onReject: rejectRequest,
  onTeamChanged: selectTeam,
  onAssign: assignTeam,
)""",
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinnApprovalAssignment(
              key: const ValueKey('preview-approval-assignment'),
              decision: _decision,
              teams: _teams,
              teamId: _team,
              state: state,
              message: _assignedTeam == null
                  ? null
                  : 'Assigned to ${_teams[_assignedTeam]}.',
              onApprove: () =>
                  setState(() => _decision = LinnReviewDecision.approved),
              onReject: () =>
                  setState(() => _decision = LinnReviewDecision.rejected),
              onTeamChanged: (team) => setState(() {
                _team = team;
                _assignedTeam = null;
              }),
              onAssign: (id) => setState(() => _assignedTeam = id),
            ),
            if (_decision != LinnReviewDecision.pending)
              TextButton(
                onPressed: state.isInteractive
                    ? () => setState(() {
                        _decision = LinnReviewDecision.pending;
                        _assignedTeam = null;
                      })
                    : null,
                child: const Text('Reset review'),
              ),
          ],
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operations tables',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Select a column heading to sort. Scroll sideways to see more columns.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth >= 980
                ? (constraints.maxWidth - 20) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                for (final table in tables)
                  SizedBox(width: width, child: table),
              ],
            );
          },
        ),
        const SizedBox(height: 36),
        Text(
          'Workflow controls',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = _galleryCardWidth(constraints.maxWidth);
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                for (final control in controls)
                  SizedBox(width: width, child: control),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _tableCard(int number, String widgetName, String rows, Widget table) =>
      _ComponentCard(
        number: number,
        title: widgetName,
        previewHeight: 192,
        codeHeight: 145,
        code:
            """$widgetName(
  rows: $rows,
  state: LinnState.${widget.state.name},
  onRetry: reloadRows,
)""",
        child: table,
      );
}
