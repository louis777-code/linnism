part of 'main.dart';

class _SurveyWorkflowPreviews extends StatefulWidget {
  const _SurveyWorkflowPreviews({required this.state, super.key});

  final LinnState state;

  @override
  State<_SurveyWorkflowPreviews> createState() =>
      _SurveyWorkflowPreviewsState();
}

class _SurveyWorkflowPreviewsState extends State<_SurveyWorkflowPreviews> {
  static const _previewHeight = 202.0;
  final _scheduledWeeks = <DateTime>{};
  DateTime _weekStart = DateTime(2026, 11, 23);
  bool _itemSelected = true;
  int _quantity = 2;
  bool? _approved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final state = widget.state;
    final stateName = 'LinnState.${state.name}';
    final weekEnd = DateUtils.addDaysToDate(_weekStart, 6);
    final weekLabel =
        '${localizations.formatShortMonthDay(_weekStart)} – '
        '${localizations.formatShortMonthDay(weekEnd)}';
    final scheduled = _scheduledWeeks.contains(_weekStart);
    final slotLabel = scheduled ? 'Release survey slot' : 'Schedule survey';
    final (status, tone) = switch (_approved) {
      true => ('Item approved', LinnStatusTone.success),
      false => ('Item rejected', LinnStatusTone.error),
      null when !_itemSelected => ('No item selected', LinnStatusTone.neutral),
      _ => ('Awaiting review', LinnStatusTone.warning),
    };
    final canReview = _itemSelected && _quantity > 0;
    final reviewMessage = switch (state) {
      LinnState.idle =>
        canReview ? null : 'Select an item and enter a quantity.',
      LinnState.loading => 'Saving the review…',
      LinnState.success => 'Review saved.',
      LinnState.error => 'Couldn’t save the review. Try again.',
      LinnState.disabled => 'Review is locked.',
    };
    final cards = [
      _ComponentCard(
        number: 19,
        title: 'LinnCalendarHeader',
        previewHeight: _previewHeight,
        code:
            """LinnCalendarHeader(
  title: '$weekLabel',
  state: $stateName,
  onPrevious: previousWeek,
  onNext: nextWeek,
)""",
        child: LinnCalendarHeader(
          key: const ValueKey('preview-calendar-header'),
          title: weekLabel,
          subtitle: 'Survey calendar',
          state: state,
          onPrevious: () => setState(
            () => _weekStart = DateUtils.addDaysToDate(_weekStart, -7),
          ),
          onNext: () => setState(
            () => _weekStart = DateUtils.addDaysToDate(_weekStart, 7),
          ),
        ),
      ),
      _ComponentCard(
        number: 20,
        title: 'LinnScheduleSlot',
        previewHeight: _previewHeight,
        code:
            """LinnScheduleSlot(
  timeLabel: 'Monday · 9:00 AM',
  label: '$slotLabel',
  state: $stateName,
  onPressed: changeSlot,
)""",
        child: LinnScheduleSlot(
          key: const ValueKey('preview-schedule-slot'),
          timeLabel: 'Monday · 9:00 AM',
          label: slotLabel,
          state: state,
          onPressed: () => setState(() {
            if (scheduled) {
              _scheduledWeeks.remove(_weekStart);
            } else {
              _scheduledWeeks.add(_weekStart);
            }
          }),
        ),
      ),
      _ComponentCard(
        number: 21,
        title: 'LinnItemSelectionRow',
        previewHeight: _previewHeight,
        code:
            """LinnItemSelectionRow(
  label: 'Roof mounting kit',
  selected: $_itemSelected,
  state: $stateName,
  onSelected: selectItem,
)""",
        child: LinnItemSelectionRow(
          key: const ValueKey('preview-item-selection'),
          label: 'Roof mounting kit',
          description: 'Mounting · SKU MK-120',
          icon: Icons.inventory_2_outlined,
          selected: _itemSelected,
          state: state,
          onSelected: (selected) => setState(() {
            _itemSelected = selected;
            _approved = null;
          }),
        ),
      ),
      _ComponentCard(
        number: 22,
        title: 'LinnQuantityStepper',
        previewHeight: _previewHeight,
        code:
            """LinnQuantityStepper(
  value: $_quantity,
  max: 6,
  state: $stateName,
  onChanged: setQuantity,
)""",
        child: LinnQuantityStepper(
          key: const ValueKey('preview-quantity'),
          label: 'Mounting kit quantity',
          value: _quantity,
          max: 6,
          state: state,
          onChanged: !_itemSelected
              ? null
              : (value) => setState(() {
                  _quantity = value;
                  _approved = null;
                }),
        ),
      ),
      _ComponentCard(
        number: 23,
        title: 'LinnApprovalActions',
        previewHeight: _previewHeight,
        code:
            """LinnApprovalActions(
  state: $stateName,
  onApprove: approveItem,
  onReject: rejectItem,
)""",
        child: LinnApprovalActions(
          key: const ValueKey('preview-approval'),
          state: state,
          message: reviewMessage,
          onApprove: canReview ? () => setState(() => _approved = true) : null,
          onReject: canReview ? () => setState(() => _approved = false) : null,
        ),
      ),
      _ComponentCard(
        number: 24,
        title: 'LinnStatusDot',
        previewHeight: _previewHeight,
        code:
            """LinnStatusDot(
  label: '$status',
  tone: LinnStatusTone.${tone.name},
  state: $stateName,
)""",
        child: LinnStatusDot(
          key: const ValueKey('preview-status-dot'),
          label: status,
          tone: tone,
          state: state,
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Survey & BOQ',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Schedule a survey, then select and review a bill of quantities item.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
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
                for (final card in cards) SizedBox(width: width, child: card),
              ],
            );
          },
        ),
      ],
    );
  }
}
