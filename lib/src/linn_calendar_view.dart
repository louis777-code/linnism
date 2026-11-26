import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'linn_alert.dart';
import 'linn_calendar_header.dart';
import 'linn_popup_panel.dart';
import 'linn_segmented_control.dart';
import 'linn_state.dart';
import 'linn_status_badge.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

part 'linn_calendar_grid.dart';

enum LinnCalendarMode { day, week, month }

/// A scheduled interval. [end] is exclusive and must be after [start].
class LinnCalendarEvent {
  LinnCalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.subtitle,
    this.description,
    this.statusLabel,
    this.state = LinnState.idle,
  }) {
    if (!end.isAfter(start)) {
      throw ArgumentError.value(end, 'end', 'Must be after start.');
    }
  }

  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String? subtitle;
  final String? description;
  final String? statusLabel;
  final LinnState state;
}

/// A controlled calendar for browsing existing events.
///
/// The caller supplies [events], [mode], and [focusedDate], then updates them
/// through the callbacks. Dates and times are displayed in the device's local
/// time zone, and the first day of the week follows the Material locale.
/// The grid keeps showing supplied events during loading, errors, and disabled
/// mode. Tapping an event opens its details unless [onEventPressed] is supplied.
class LinnCalendarView extends StatelessWidget {
  const LinnCalendarView({
    required this.focusedDate,
    required this.events,
    this.mode = LinnCalendarMode.week,
    this.state = LinnState.idle,
    this.onModeChanged,
    this.onDateChanged,
    this.onEventPressed,
    this.onRetry,
    this.startHour = 8,
    this.endHour = 17,
    this.slotMinutes = 60,
    this.message,
    this.style,
    super.key,
  }) : assert(startHour >= 0 && startHour < endHour && endHour <= 24),
       assert(slotMinutes >= 15 && slotMinutes <= 1440);

  final DateTime focusedDate;
  final List<LinnCalendarEvent> events;
  final LinnCalendarMode mode;
  final LinnState state;
  final LinnThemeData? style;
  final ValueChanged<LinnCalendarMode>? onModeChanged;
  final ValueChanged<DateTime>? onDateChanged;

  /// Opens a custom event detail view instead of the calendar's detail dialog.
  final ValueChanged<LinnCalendarEvent>? onEventPressed;
  final VoidCallback? onRetry;

  /// Default displayed hours. The grid expands to include events outside them.
  /// Use 24 for midnight at the end of a day.
  final int startHour;
  final int endHour;

  /// Minutes between time grid lines, from 15 to 1440.
  final int slotMinutes;
  final String? message;

  static const _modes = {
    LinnCalendarMode.day: 'Day',
    LinnCalendarMode.week: 'Week',
    LinnCalendarMode.month: 'Month',
  };

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final date = DateUtils.dateOnly(focusedDate.toLocal());
    final weekStart = _startOfWeek(date, localizations.firstDayOfWeekIndex);
    final monthStart = DateTime(date.year, date.month);
    final monthEnd = DateTime(date.year, date.month + 1, 0);
    final (firstDay, lastDay, title) = switch (mode) {
      LinnCalendarMode.day => (date, date, localizations.formatFullDate(date)),
      LinnCalendarMode.week => (
        weekStart,
        DateUtils.addDaysToDate(weekStart, 6),
        '${localizations.formatShortMonthDay(weekStart)} – '
            '${localizations.formatShortMonthDay(DateUtils.addDaysToDate(weekStart, 6))}',
      ),
      LinnCalendarMode.month => (
        _startOfWeek(monthStart, localizations.firstDayOfWeekIndex),
        DateUtils.addDaysToDate(
          _startOfWeek(monthEnd, localizations.firstDayOfWeekIndex),
          6,
        ),
        localizations.formatMonthYear(date),
      ),
    };
    final days = _calendarDays(firstDay, lastDay, events);
    final navigate = state.isInteractive ? onDateChanged : null;
    final changeMode = state.isInteractive ? onModeChanged : null;
    final openEvent = state == LinnState.disabled
        ? null
        : onEventPressed ?? (event) => _showEventDetails(context, event);
    final feedbackTitle = switch (state) {
      LinnState.idle => null,
      LinnState.loading => 'Loading calendar',
      LinnState.success => 'Calendar updated',
      LinnState.error => 'Couldn’t refresh the calendar',
      LinnState.disabled => 'Calendar controls are disabled',
    };
    final retry = state == LinnState.error ? onRetry : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinnCalendarHeader(
          title: title,
          onPrevious: navigate == null ? null : () => navigate(_move(date, -1)),
          onNext: navigate == null ? null : () => navigate(_move(date, 1)),
        ),
        if (onModeChanged != null) ...[
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: LinnSegmentedControl<LinnCalendarMode>(
              label: 'Calendar view',
              options: _modes,
              value: mode,
              onChanged: changeMode,
              state: state.isInteractive ? LinnState.idle : LinnState.disabled,
            ),
          ),
        ],
        if (feedbackTitle != null) ...[
          const SizedBox(height: 10),
          LinnAlert(
            title: feedbackTitle,
            message: message,
            state: state,
            actionLabel: retry == null ? null : 'Retry',
            onAction: retry,
          ),
        ],
        const SizedBox(height: 12),
        if (mode == LinnCalendarMode.month)
          _MonthGrid(
            days: days,
            focusedDate: date,
            onEventPressed: openEvent,
            canNavigate: navigate != null,
            onDayPressed: navigate == null && openEvent == null
                ? null
                : (day) {
                    navigate?.call(day.date);
                    if (navigate != null && changeMode != null) {
                      changeMode(LinnCalendarMode.day);
                    } else if (openEvent != null && day.events.isNotEmpty) {
                      _showDayEvents(context, day, openEvent);
                    }
                  },
          )
        else
          _TimeGrid(
            days: days,
            focusedDate: date,
            startHour: startHour,
            endHour: endHour,
            slotMinutes: slotMinutes,
            onEventPressed: openEvent,
          ),
      ],
    );
  }

  DateTime _move(DateTime date, int direction) => switch (mode) {
    LinnCalendarMode.day => DateUtils.addDaysToDate(date, direction),
    LinnCalendarMode.week => DateUtils.addDaysToDate(date, direction * 7),
    LinnCalendarMode.month => _moveMonth(date, direction),
  };
}

void _showEventDetails(BuildContext context, LinnCalendarEvent event) {
  showDialog<void>(
    context: context,
    barrierColor: LinnStyle.popupBarrier(context),
    builder: (context) {
      final theme = Theme.of(context);
      final scheme = theme.colorScheme;
      final localizations = MaterialLocalizations.of(context);
      final start = event.start.toLocal();
      final end = event.end.toLocal();
      final startTime = _formatTime(context, TimeOfDay.fromDateTime(start));
      final endTime = _formatTime(context, TimeOfDay.fromDateTime(end));
      final dateLabel = DateUtils.isSameDay(start, end)
          ? '${localizations.formatFullDate(start)}\n$startTime – $endTime'
          : '${localizations.formatFullDate(start)}, $startTime\n'
                '${localizations.formatFullDate(end)}, $endTime';

      return LinnPopupPanel(
        title: event.title,
        icon: Icons.event_note_outlined,
        state: event.state,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.subtitle case final subtitle?) ...[
              Text(subtitle),
              const SizedBox(height: 14),
            ],
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: LinnStyle.radius(context),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: scheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      dateLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (event.statusLabel case final status?) ...[
              const SizedBox(height: 14),
              LinnStatusBadge(label: status, state: event.state),
            ],
            if (event.description case final description?) ...[
              const SizedBox(height: 14),
              Text(description),
            ],
          ],
        ),
        actions: [
          TextButton(
            style: LinnPopupPanel.secondaryButton(context),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.closeButtonLabel),
          ),
        ],
      );
    },
  );
}

Future<void> _showDayEvents(
  BuildContext context,
  _CalendarDay day,
  ValueChanged<LinnCalendarEvent> openEvent,
) async {
  final selected = await showDialog<LinnCalendarEvent>(
    context: context,
    barrierColor: LinnStyle.popupBarrier(context),
    builder: (context) => LinnPopupPanel(
      icon: Icons.calendar_today_outlined,
      title: MaterialLocalizations.of(context).formatFullDate(day.date),
      content: Column(
        spacing: 8,
        children: [
          for (final event in day.events)
            Material(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: LinnStyle.radius(context),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                title: Text(event.event.title),
                subtitle: Text(_eventTimeRange(context, event)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).pop(event.event),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          style: LinnPopupPanel.secondaryButton(context),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    ),
  );
  if (context.mounted && selected != null) openEvent(selected);
}

DateTime _startOfWeek(DateTime day, int firstDayIndex) =>
    DateUtils.addDaysToDate(day, -((day.weekday % 7 - firstDayIndex) % 7));

DateTime _moveMonth(DateTime date, int direction) {
  final first = DateTime(date.year, date.month + direction);
  final last = DateTime(first.year, first.month + 1, 0);
  return DateTime(first.year, first.month, math.min(last.day, date.day));
}

typedef _LocalEvent = ({LinnCalendarEvent event, DateTime start, DateTime end});
typedef _CalendarDay = ({DateTime date, List<_LocalEvent> events});

bool _overlaps(_LocalEvent event, DateTime start, DateTime end) =>
    event.start.isBefore(end) && event.end.isAfter(start);

List<_CalendarDay> _calendarDays(
  DateTime first,
  DateTime last,
  List<LinnCalendarEvent> events,
) {
  final localEvents =
      [
        for (final event in events)
          (
            event: event,
            start: event.start.toLocal(),
            end: event.end.toLocal(),
          ),
      ]..sort((a, b) {
        final byStart = a.start.compareTo(b.start);
        return byStart == 0 ? a.event.id.compareTo(b.event.id) : byStart;
      });

  final days = <_CalendarDay>[];
  for (var day = first; !day.isAfter(last);) {
    final next = DateUtils.addDaysToDate(day, 1);
    days.add((
      date: day,
      events: localEvents
          .where((event) => _overlaps(event, day, next))
          .toList(),
    ));
    day = next;
  }
  return days;
}
