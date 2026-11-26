part of 'main.dart';

class _CalendarPreview extends StatefulWidget {
  const _CalendarPreview({
    required this.state,
    required this.onRetry,
    super.key,
  });

  final LinnState state;
  final VoidCallback onRetry;

  @override
  State<_CalendarPreview> createState() => _CalendarPreviewState();
}

class _CalendarPreviewState extends State<_CalendarPreview> {
  static const _teams = ['Team A', 'Team B'];
  static const _allTeams = 'All teams';
  final _events = [
    LinnCalendarEvent(
      id: 'riverside',
      title: 'Riverside survey',
      subtitle: 'Team A',
      statusLabel: 'Confirmed',
      description:
          'Check roof access and record measurements for the mounting plan.',
      start: DateTime(2026, 11, 23, 9),
      end: DateTime(2026, 11, 23, 10, 30),
    ),
    LinnCalendarEvent(
      id: 'north-market',
      title: 'North Market survey',
      subtitle: 'Team A',
      statusLabel: 'Scheduled',
      description:
          'Verify the roof measurements and check access to the electrical room.',
      start: DateTime(2026, 11, 24, 9, 30),
      end: DateTime(2026, 11, 24, 10, 15),
    ),
    LinnCalendarEvent(
      id: 'hilltop',
      title: 'Hilltop assessment',
      subtitle: 'Team B',
      statusLabel: 'Scheduled',
      description:
          'Meet the facilities team at the north entrance to assess the installation site.',
      start: DateTime(2026, 11, 24, 11),
      end: DateTime(2026, 11, 24, 12),
    ),
    LinnCalendarEvent(
      id: 'lakeview',
      title: 'Lakeview roof check',
      subtitle: 'Team A',
      statusLabel: 'Scheduled',
      description:
          'Inspect the roof condition and verify the available panel area.',
      start: DateTime(2026, 11, 26, 12),
      end: DateTime(2026, 11, 26, 13),
    ),
  ];
  LinnCalendarMode _mode = LinnCalendarMode.week;
  DateTime _date = DateTime(2026, 11, 24);
  String _team = _allTeams;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Surface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _NumberedWidgetTitle(number: 25, title: 'LinnCalendarView'),
          const SizedBox(height: 6),
          Text(
            _mode == LinnCalendarMode.month
                ? 'Select a date for its schedule, or open an event for details.'
                : 'Choose a team and open a survey for its details.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 270),
            child: LinnDropdown<String>(
              label: 'Calendar team',
              items: const [_allTeams, ..._teams],
              value: _team,
              onChanged: !widget.state.isInteractive
                  ? null
                  : (team) {
                      if (team != null) setState(() => _team = team);
                    },
            ),
          ),
          const SizedBox(height: 16),
          LinnCalendarView(
            key: const ValueKey('live-calendar'),
            focusedDate: _date,
            events: [
              for (final event in _events)
                if (_team == _allTeams || event.subtitle == _team) event,
            ],
            mode: _mode,
            state: widget.state,
            startHour: 9,
            endHour: 14,
            onDateChanged: (date) => setState(() => _date = date),
            onModeChanged: (mode) => setState(() => _mode = mode),
            onRetry: widget.onRetry,
          ),
        ],
      ),
    );
  }
}
