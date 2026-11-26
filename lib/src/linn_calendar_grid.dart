part of 'linn_calendar_view.dart';

class _TimeGrid extends StatefulWidget {
  const _TimeGrid({
    required this.days,
    required this.focusedDate,
    required this.startHour,
    required this.endHour,
    required this.slotMinutes,
    required this.onEventPressed,
  });

  final List<_CalendarDay> days;
  final DateTime focusedDate;
  final int startHour;
  final int endHour;
  final int slotMinutes;
  final ValueChanged<LinnCalendarEvent>? onEventPressed;

  @override
  State<_TimeGrid> createState() => _TimeGridState();
}

class _TimeGridState extends State<_TimeGrid> {
  final _horizontalScroll = ScrollController();

  @override
  void dispose() {
    _horizontalScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final localizations = MaterialLocalizations.of(context);
    final days = widget.days;
    final week = days.length > 1;
    final workStart = widget.startHour * 60;
    final workEnd = widget.endHour * 60;
    var visibleStart = workStart;
    var visibleEnd = workEnd;
    for (final day in days) {
      final nextDay = DateUtils.addDaysToDate(day.date, 1);
      for (final event in day.events) {
        final firstMinute = event.start.isBefore(day.date)
            ? 0
            : event.start.hour * 60;
        final lastMinute = event.end.isBefore(nextDay)
            ? event.end.hour * 60 +
                  (event.end.minute == 0 &&
                          event.end.second == 0 &&
                          event.end.millisecond == 0 &&
                          event.end.microsecond == 0
                      ? 0
                      : 60)
            : 1440;
        visibleStart = math.min(visibleStart, firstMinute);
        visibleEnd = math.max(visibleEnd, lastMinute);
      }
    }
    final periods = [
      ..._periods(visibleStart, workStart),
      ..._periods(workStart, workEnd),
      ..._periods(workEnd, visibleEnd),
    ];

    final table = Table(
      columnWidths: const {0: FixedColumnWidth(70)},
      border: TableBorder(
        horizontalInside: BorderSide(color: scheme.outlineVariant),
        verticalInside: BorderSide(color: scheme.outlineVariant),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(color: scheme.surfaceContainerLow),
          children: [
            const _GridHeading('Time'),
            for (final day in days)
              _GridHeading(
                localizations.formatMediumDate(day.date),
                focused: DateUtils.isSameDay(day.date, widget.focusedDate),
              ),
          ],
        ),
        for (final period in periods)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 8,
                ),
                child: Text(
                  _formatTime(
                    context,
                    TimeOfDay(
                      hour: period.start ~/ 60,
                      minute: period.start % 60,
                    ),
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              for (final day in days)
                _eventCell(
                  context,
                  day,
                  period,
                  firstRow: period.start == visibleStart,
                ),
            ],
          ),
      ],
    );

    final minimumWidth = week ? 70 + days.length * 148.0 : 0.0;
    return _GridFrame(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= minimumWidth) return table;
          return Scrollbar(
            controller: _horizontalScroll,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalScroll,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(width: minimumWidth, child: table),
            ),
          );
        },
      ),
    );
  }

  Iterable<_CalendarPeriod> _periods(int start, int end) sync* {
    for (var minute = start; minute < end;) {
      final next = math.min(minute + widget.slotMinutes, end);
      yield (start: minute, end: next);
      minute = next;
    }
  }

  Widget _eventCell(
    BuildContext context,
    _CalendarDay day,
    _CalendarPeriod period, {
    required bool firstRow,
  }) {
    final start = _timeOn(day.date, period.start);
    final end = _timeOn(day.date, period.end);
    // A clock change can collapse a wall-clock interval to zero duration.
    if (!end.isAfter(start)) return const SizedBox(height: 48);
    final active = day.events
        .where((event) => _overlaps(event, start, end))
        .toList();
    if (active.isEmpty) return const SizedBox(height: 52);

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final booking in active)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _CalendarEventTile(
                key: ValueKey((booking.event.id, day.date, period.start)),
                event: booking.event,
                subtitle: !firstRow && booking.start.isBefore(start)
                    ? null
                    : _eventTimeRange(context, booking),
                continuing: !firstRow && booking.start.isBefore(start),
                onPressed: widget.onEventPressed == null
                    ? null
                    : () => widget.onEventPressed!(booking.event),
              ),
            ),
        ],
      ),
    );
  }
}

typedef _CalendarPeriod = ({int start, int end});

String _eventTimeRange(BuildContext context, _LocalEvent event) =>
    '${_formatTime(context, TimeOfDay.fromDateTime(event.start))} – '
    '${_formatTime(context, TimeOfDay.fromDateTime(event.end))}';

DateTime _timeOn(DateTime date, int minute) =>
    DateTime(date.year, date.month, date.day, minute ~/ 60, minute % 60);

String _formatTime(BuildContext context, TimeOfDay time) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      time,
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.days,
    required this.focusedDate,
    required this.canNavigate,
    required this.onDayPressed,
    required this.onEventPressed,
  });

  final List<_CalendarDay> days;
  final DateTime focusedDate;
  final bool canNavigate;
  final ValueChanged<_CalendarDay>? onDayPressed;
  final ValueChanged<LinnCalendarEvent>? onEventPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final localizations = MaterialLocalizations.of(context);
    return _GridFrame(
      child: LayoutBuilder(
        builder: (context, constraints) => Table(
          border: TableBorder(
            horizontalInside: BorderSide(color: scheme.outlineVariant),
            verticalInside: BorderSide(color: scheme.outlineVariant),
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.intrinsicHeight,
          children: [
            TableRow(
              decoration: BoxDecoration(color: scheme.surfaceContainerLow),
              children: [
                for (final day in days.take(7))
                  _GridHeading(
                    localizations.narrowWeekdays[day.date.weekday % 7],
                  ),
              ],
            ),
            for (var start = 0; start < days.length; start += 7)
              TableRow(
                children: [
                  for (final day in days.skip(start).take(7))
                    _MonthDay(
                      day: day,
                      focusedDate: focusedDate,
                      showEvents: constraints.maxWidth >= 560,
                      onPressed:
                          onDayPressed != null &&
                              (canNavigate || day.events.isNotEmpty)
                          ? () => onDayPressed!(day)
                          : null,
                      onEventPressed: onEventPressed,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthDay extends StatelessWidget {
  const _MonthDay({
    required this.day,
    required this.focusedDate,
    required this.showEvents,
    required this.onPressed,
    required this.onEventPressed,
  });

  final _CalendarDay day;
  final DateTime focusedDate;
  final bool showEvents;
  final VoidCallback? onPressed;
  final ValueChanged<LinnCalendarEvent>? onEventPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final localization = MaterialLocalizations.of(context);
    final selected = DateUtils.isSameDay(day.date, focusedDate);
    final inMonth = day.date.month == focusedDate.month;
    final count = day.events.length;
    final countLabel =
        '${localization.formatDecimal(count)} '
        '${count == 1 ? 'booking' : 'bookings'}';
    final accent = LinnStyle.accent(context, LinnState.idle);
    final dateButton = Semantics(
      label: '${localization.formatFullDate(day.date)}, $countLabel',
      button: onPressed != null,
      selected: selected,
      child: InkWell(
        onTap: onPressed,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: showEvents
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Text(
                  localization.formatDecimal(day.date.day),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: inMonth ? scheme.onSurface : scheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (!showEvents && count > 0) ...[
                  const SizedBox(height: 4),
                  Icon(Icons.circle, size: 6, color: accent),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    return Material(
      color: selected
          ? Color.alphaBlend(accent.withValues(alpha: 0.12), scheme.surface)
          : scheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: showEvents
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  dateButton,
                  for (final booking in day.events.take(2))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 4),
                      child: _CalendarEventTile(
                        event: booking.event,
                        onPressed: onEventPressed == null
                            ? null
                            : () => onEventPressed!(booking.event),
                      ),
                    ),
                  if (count > 2)
                    TextButton(
                      onPressed: onPressed,
                      child: Text(
                        '+${localization.formatDecimal(count - 2)} more',
                      ),
                    ),
                ],
              )
            : dateButton,
      ),
    );
  }
}

class _CalendarEventTile extends StatelessWidget {
  const _CalendarEventTile({
    required this.event,
    required this.onPressed,
    this.subtitle,
    this.continuing = false,
    super.key,
  });

  final LinnCalendarEvent event;
  final VoidCallback? onPressed;
  final String? subtitle;
  final bool continuing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = LinnStyle.accent(context, event.state);
    return Tooltip(
      message: event.title,
      excludeFromSemantics: true,
      child: Semantics(
        button: onPressed != null,
        label: continuing ? '${event.title}, continues' : null,
        child: Material(
          color: Color.alphaBlend(
            accent.withValues(alpha: continuing ? 0.06 : 0.12),
            theme.colorScheme.surface,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: LinnStyle.radius(context),
            side: BorderSide(color: accent.withValues(alpha: 0.30)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: subtitle == null ? 6 : 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (continuing)
                    ExcludeSemantics(
                      child: Text(
                        'Continues',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accent,
                        ),
                      ),
                    )
                  else
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GridFrame extends StatelessWidget {
  const _GridFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: LinnStyle.radius(context),
      ),
      child: child,
    );
  }
}

class _GridHeading extends StatelessWidget {
  const _GridHeading(this.label, {this.focused = false});

  final String label;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = LinnStyle.accent(context, LinnState.idle);
    return Semantics(
      header: true,
      child: ColoredBox(
        color: focused ? accent.withValues(alpha: 0.10) : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: focused ? accent : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
