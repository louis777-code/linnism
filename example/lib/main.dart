import 'package:flutter/material.dart';
import 'package:linnism_ui_concept_solar/linnism_ui_concept_solar.dart';

part 'calendar_preview.dart';
part 'dashboard_previews.dart';
part 'operations_previews.dart';
part 'survey_workflow_previews.dart';

void main() => runApp(const LinnGalleryApp());

const _blue = Color(0xFF306CD8);

class LinnGalleryApp extends StatefulWidget {
  const LinnGalleryApp({super.key});

  @override
  State<LinnGalleryApp> createState() => _LinnGalleryAppState();
}

class _LinnGalleryAppState extends State<LinnGalleryApp> {
  bool _dark = false;
  bool _customTheme = false;

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final seed = _customTheme ? const Color(0xFF00796B) : _blue;
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness)
        .copyWith(
          primary: _customTheme || dark ? null : _blue,
          surface: dark ? const Color(0xFF171E2C) : Colors.white,
          onSurface: dark ? const Color(0xFFEEF2FA) : const Color(0xFF172238),
          onSurfaceVariant: dark
              ? const Color(0xFFA4B0C5)
              : const Color(0xFF647187),
          outline: dark ? const Color(0xFF526078) : const Color(0xFFB7C1D1),
          outlineVariant: dark
              ? const Color(0xFF2D384B)
              : const Color(0xFFE2E7F0),
        );
    final appTheme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? const Color(0xFF0D131F)
          : const Color(0xFFF5F7FC),
    );
    return _customTheme
        ? const LinnThemeData(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ).applyTo(appTheme)
        : appTheme;
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Linn UI · Widget gallery',
    debugShowCheckedModeBanner: false,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
    home: _GalleryPage(
      dark: _dark,
      onToggleTheme: () => setState(() => _dark = !_dark),
      customTheme: _customTheme,
      onToggleCustomTheme: () => setState(() => _customTheme = !_customTheme),
    ),
  );
}

class _GalleryPage extends StatefulWidget {
  const _GalleryPage({
    required this.dark,
    required this.onToggleTheme,
    required this.customTheme,
    required this.onToggleCustomTheme,
  });
  final bool dark;
  final VoidCallback onToggleTheme;
  final bool customTheme;
  final VoidCallback onToggleCustomTheme;

  @override
  State<_GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<_GalleryPage> {
  static const _surveyPreviewHeight = 292.0;
  final _dashboardKey = GlobalKey();
  final _surveyWorkflowKey = GlobalKey();
  final _calendarKey = GlobalKey();
  final _operationsKey = GlobalKey();
  LinnState _state = LinnState.idle;
  String _team = 'Team A';
  bool _reminders = true;
  bool _navSelected = false;
  String _calendarView = 'week';
  bool _assignmentSelected = false;
  final _firstDate = DateTime(2026, 11);
  final _lastDate = DateTime(2026, 12, 31);
  DateTime _surveyDate = DateTime(2026, 11, 24);
  bool? _sortAscending;
  bool _emptyTable = false;

  Widget _tablePreview() {
    final projects = _sortAscending == true
        ? const [('Hilltop', 'Team B'), ('Riverside', 'Team A')]
        : const [('Riverside', 'Team A'), ('Hilltop', 'Team B')];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinnDataTable(
          key: const ValueKey('preview-table'),
          columns: [
            DataColumn(
              label: const Text('Project'),
              tooltip: 'Sort by project',
              onSort: (_, ascending) =>
                  setState(() => _sortAscending = ascending),
            ),
            const DataColumn(label: Text('Team')),
          ],
          rows: [
            if (!_emptyTable)
              for (final (project, team) in projects)
                DataRow(cells: [DataCell(Text(project)), DataCell(Text(team))]),
          ],
          sortColumnIndex: _sortAscending == null ? null : 0,
          sortAscending: _sortAscending ?? true,
          state: _state,
          emptyMessage: 'No surveys scheduled.',
          onRetry: () => setState(() {
            _emptyTable = false;
            _state = LinnState.success;
          }),
        ),
        if (_state.isInteractive && _state != LinnState.error) ...[
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: _color(LinnState.idle, context),
            ),
            onPressed: () => setState(() => _emptyTable = !_emptyTable),
            child: Text(_emptyTable ? 'Restore rows' : 'Preview empty table'),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final previewAccent = _color(LinnState.idle, context);
    const buttonStyle = LinnThemeData(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    );
    final buttonLabel = switch (_state) {
      LinnState.loading => 'Saving changes',
      LinnState.success => 'Changes saved',
      LinnState.error => 'Try again',
      _ => 'Save changes',
    };
    final fieldMessage = switch (_state) {
      LinnState.error => 'Enter a project name.',
      LinnState.loading => 'Checking availability…',
      LinnState.success => 'Project name looks good.',
      LinnState.disabled => 'Editing is unavailable.',
      _ => 'Give your project a clear name.',
    };
    final alertMessage = switch (_state) {
      LinnState.error => 'Your changes could not be saved. Please try again.',
      LinnState.loading => 'Saving your changes. This will only take a moment.',
      LinnState.success => 'Your team can now see the updated project.',
      LinnState.disabled =>
        'This action is unavailable with your current access.',
      _ => 'Keep your project details up to date for the team.',
    };
    final alert = LinnAlert(
      key: const ValueKey('preview-alert'),
      title: _alertTitle(_state),
      state: _state,
      message: alertMessage,
      actionLabel: _state == LinnState.error ? 'Retry' : null,
      onAction: _state == LinnState.error
          ? () => setState(() => _state = LinnState.success)
          : null,
    );
    final dropdownMessage = switch (_state) {
      LinnState.error => 'Choose a team with availability.',
      LinnState.loading => 'Checking team availability…',
      LinnState.success => 'Your team is available.',
      LinnState.disabled => 'Team assignment is locked.',
      _ => 'Choose who will visit the site.',
    };
    final checkboxMessage = switch (_state) {
      LinnState.error => 'Confirm how the team should be notified.',
      LinnState.loading => 'Saving notification preference…',
      LinnState.success => 'Notification preference saved.',
      LinnState.disabled => 'Only project owners can edit this.',
      _ => 'Keep the team informed about upcoming visits.',
    };
    final badgeLabel = switch (_state) {
      LinnState.error => 'Needs attention',
      LinnState.loading => 'Checking status',
      LinnState.success => 'Ready for survey',
      LinnState.disabled => 'Unavailable',
      _ => 'Scheduled',
    };
    final assignmentStatus = switch (_state) {
      LinnState.error => 'Needs rescheduling',
      LinnState.loading => 'Checking availability',
      LinnState.success => 'Confirmed',
      LinnState.disabled => 'Unavailable',
      LinnState.idle => 'Scheduled',
    };
    final surveyDateText = MaterialLocalizations.of(
      context,
    ).formatMediumDate(_surveyDate);
    final snackbar = LinnSnackbar(
      key: const ValueKey('preview-snackbar'),
      message: switch (_state) {
        LinnState.idle => 'Team assignment updated.',
        LinnState.loading => 'Scheduling survey…',
        LinnState.success => 'Survey scheduled.',
        LinnState.error => 'Couldn’t schedule the survey.',
        LinnState.disabled => 'Scheduling is unavailable.',
      },
      state: _state,
      actionLabel: _state == LinnState.error ? 'Retry' : null,
      onAction: _state == LinnState.error
          ? () => const LinnSnackbar(
              message: 'Survey scheduled.',
              state: LinnState.success,
            ).show(context)
          : null,
    );
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          key: const ValueKey('gallery-scroll'),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.wb_sunny_outlined,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'LINN UI',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        const Spacer(),
                        IconButton.filledTonal(
                          key: const ValueKey('theme-toggle'),
                          style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          tooltip: widget.dark
                              ? 'Use light theme'
                              : 'Use dark theme',
                          onPressed: widget.onToggleTheme,
                          icon: Icon(
                            widget.dark
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Linn widget gallery',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 660),
                      child: Text(
                        'Choose a state to preview it across all 37 widgets.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilterChip(
                      key: const ValueKey('custom-app-theme'),
                      avatar: widget.customTheme
                          ? null
                          : const Icon(Icons.palette_outlined, size: 18),
                      label: const Text('Custom app theme'),
                      selected: widget.customTheme,
                      onSelected: (_) => widget.onToggleCustomTheme(),
                    ),
                    const SizedBox(height: 12),
                    _Surface(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              'PREVIEW STATE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                letterSpacing: 1,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          for (final state in LinnState.values)
                            ChoiceChip(
                              key: ValueKey('state-${state.name}'),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              label: Text(state.label),
                              selected: _state == state,
                              showCheckmark: false,
                              avatar: Icon(
                                Icons.circle,
                                size: 8,
                                color: _color(state, context),
                              ),
                              selectedColor: previewAccent.withValues(
                                alpha: 0.12,
                              ),
                              side: BorderSide(
                                color: _state == state
                                    ? previewAccent
                                    : scheme.outlineVariant,
                              ),
                              onSelected: (_) => setState(() => _state = state),
                            ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: _color(LinnState.idle, context),
                            ),
                            onPressed: () => Scrollable.ensureVisible(
                              _dashboardKey.currentContext!,
                              duration: const Duration(milliseconds: 300),
                            ),
                            child: const Text('Dashboard widgets'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: _color(LinnState.idle, context),
                            ),
                            onPressed: () => Scrollable.ensureVisible(
                              _surveyWorkflowKey.currentContext!,
                              duration: const Duration(milliseconds: 300),
                            ),
                            child: const Text('Survey & BOQ'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: _color(LinnState.idle, context),
                            ),
                            onPressed: () => Scrollable.ensureVisible(
                              _calendarKey.currentContext!,
                              duration: const Duration(milliseconds: 300),
                            ),
                            child: const Text('Calendar demo'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: _color(LinnState.idle, context),
                            ),
                            onPressed: () => Scrollable.ensureVisible(
                              _operationsKey.currentContext!,
                              duration: const Duration(milliseconds: 300),
                            ),
                            child: const Text('Operations & workflows'),
                          ),
                        ],
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
                            SizedBox(
                              width: width,
                              child: _ComponentCard(
                                number: 1,
                                title: 'LinnButton',
                                code: [
                                  'LinnButton(',
                                  "  label: '$buttonLabel',",
                                  '  state: LinnState.${_state.name},',
                                  '  onPressed: save,',
                                  if (widget.customTheme) ...const [
                                    '  style: const LinnThemeData(',
                                    '    borderRadius: BorderRadius.all(',
                                    '      Radius.circular(4),',
                                    '    ),',
                                    '  ),',
                                  ],
                                  ')',
                                ].join('\n'),
                                child: LinnButton(
                                  key: const ValueKey('preview-button'),
                                  label: buttonLabel,
                                  state: _state,
                                  style: widget.customTheme
                                      ? buttonStyle
                                      : null,
                                  onPressed: () => const LinnSnackbar(
                                    message: 'Button pressed.',
                                  ).show(context),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: _ComponentCard(
                                number: 2,
                                title: 'LinnTextField',
                                code:
                                    "LinnTextField(\n  label: 'Project name',\n  state: LinnState.${_state.name},\n  message: '$fieldMessage',\n)",
                                child: LinnTextField(
                                  key: const ValueKey('preview-field'),
                                  label: 'Project name',
                                  hintText: 'e.g. Riverside Solar',
                                  state: _state,
                                  message: fieldMessage,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: _ComponentCard(
                                number: 3,
                                title: 'LinnAlert',
                                code:
                                    "LinnAlert(\n  title: '${_alertTitle(_state)}',\n  state: LinnState.${_state.name},\n  message: '$alertMessage',\n).show(context)",
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    alert,
                                    const SizedBox(height: 6),
                                    TextButton.icon(
                                      key: const ValueKey(
                                        'preview-alert-popup',
                                      ),
                                      onPressed: () => alert.show(context),
                                      icon: const Icon(
                                        Icons.open_in_new_rounded,
                                        size: 16,
                                      ),
                                      label: const Text('Preview popup'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: _ComponentCard(
                                number: 4,
                                title: 'LinnDropdown',
                                code:
                                    "LinnDropdown<String>(\n  label: 'Assign team',\n  items: ['Team A', 'Team B', 'Team C'],\n  value: '$_team',\n  state: LinnState.${_state.name},\n  onChanged: selectTeam,\n)",
                                child: LinnDropdown<String>(
                                  key: const ValueKey('preview-dropdown'),
                                  label: 'Assign team',
                                  items: const ['Team A', 'Team B', 'Team C'],
                                  value: _team,
                                  state: _state,
                                  message: dropdownMessage,
                                  onChanged: (team) {
                                    if (team != null) {
                                      setState(() => _team = team);
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: _ComponentCard(
                                number: 5,
                                title: 'LinnCheckbox',
                                code:
                                    "LinnCheckbox(\n  label: 'Send survey reminders',\n  value: $_reminders,\n  state: LinnState.${_state.name},\n  onChanged: setReminders,\n)",
                                child: LinnCheckbox(
                                  key: const ValueKey('preview-checkbox'),
                                  label: 'Send survey reminders',
                                  value: _reminders,
                                  state: _state,
                                  message: checkboxMessage,
                                  onChanged: (value) =>
                                      setState(() => _reminders = value),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: _ComponentCard(
                                number: 6,
                                title: 'LinnStatusBadge',
                                code:
                                    "LinnStatusBadge(\n  label: '$badgeLabel',\n  state: LinnState.${_state.name},\n)",
                                child: LinnStatusBadge(
                                  key: const ValueKey('preview-badge'),
                                  label: badgeLabel,
                                  state: _state,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: _ComponentCard(
                                number: 7,
                                title: 'LinnNavItem',
                                code:
                                    """LinnNavItem(
  label: 'Survey calendar',
  icon: Icons.calendar_month_outlined,
  selected: $_navSelected,
  state: LinnState.${_state.name},
  onPressed: openCalendar,
)""",
                                child: LinnNavItem(
                                  key: const ValueKey('preview-nav-item'),
                                  label: 'Survey calendar',
                                  icon: Icons.calendar_month_outlined,
                                  selected: _navSelected,
                                  state: _state,
                                  onPressed: () => setState(
                                    () => _navSelected = !_navSelected,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: _ComponentCard(
                                number: 8,
                                title: 'LinnSegmentedControl',
                                code:
                                    """LinnSegmentedControl<String>(
  label: 'Calendar view',
  options: {'day': 'Day', 'week': 'Week', 'month': 'Month'},
  value: '$_calendarView',
  state: LinnState.${_state.name},
  onChanged: setView,
)""",
                                child: LinnSegmentedControl<String>(
                                  key: const ValueKey('preview-segmented'),
                                  label: 'Calendar view',
                                  options: const {
                                    'day': 'Day',
                                    'week': 'Week',
                                    'month': 'Month',
                                  },
                                  value: _calendarView,
                                  state: _state,
                                  onChanged: (value) =>
                                      setState(() => _calendarView = value),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: _ComponentCard(
                                number: 9,
                                title: 'LinnAssignmentCard',
                                code:
                                    """LinnAssignmentCard(
  title: 'Riverside site survey',
  subtitle: '$_team · $surveyDateText',
  statusLabel: '$assignmentStatus',
  selected: $_assignmentSelected,
  state: LinnState.${_state.name},
  onPressed: selectSurvey,
)""",
                                child: LinnAssignmentCard(
                                  key: const ValueKey('preview-assignment'),
                                  title: 'Riverside site survey',
                                  subtitle: '$_team · $surveyDateText',
                                  statusLabel: assignmentStatus,
                                  selected: _assignmentSelected,
                                  state: _state,
                                  onPressed: () => setState(
                                    () => _assignmentSelected =
                                        !_assignmentSelected,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: _ComponentCard(
                                number: 10,
                                title: 'LinnDatePicker',
                                previewHeight: _surveyPreviewHeight,
                                code:
                                    """LinnDatePicker(
  label: 'Survey date',
  value: surveyDate,
  firstDate: start,
  lastDate: end,
  state: LinnState.${_state.name},
  onChanged: selectDate,
)""",
                                child: LinnDatePicker(
                                  key: const ValueKey('preview-date-picker'),
                                  label: 'Survey date',
                                  value: _surveyDate,
                                  firstDate: _firstDate,
                                  lastDate: _lastDate,
                                  state: _state,
                                  message: _state == LinnState.error
                                      ? 'Choose a date with team availability.'
                                      : null,
                                  onChanged: (date) =>
                                      setState(() => _surveyDate = date),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: _ComponentCard(
                                number: 11,
                                title: 'LinnDataTable',
                                previewHeight: _surveyPreviewHeight,
                                code:
                                    """LinnDataTable(
  columns: surveyColumns,
  rows: ${_emptyTable ? 'const []' : 'surveyRows'},
  state: LinnState.${_state.name},
  onRetry: reloadSurveys,
)""",
                                child: _tablePreview(),
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: _ComponentCard(
                                number: 12,
                                title: 'LinnSnackbar',
                                previewHeight: _surveyPreviewHeight,
                                code:
                                    """LinnSnackbar(
  message: '${snackbar.message}',
  state: LinnState.${_state.name},
${_state == LinnState.error ? "  actionLabel: 'Retry',\n  onAction: scheduleSurvey,\n" : ''}).show(context)""",
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    snackbar,
                                    const SizedBox(height: 12),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: _color(
                                          LinnState.idle,
                                          context,
                                        ),
                                      ),
                                      onPressed: () => snackbar.show(context),
                                      child: const Text('Show snackbar'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 36),
                    _DashboardPreviews(key: _dashboardKey, state: _state),
                    const SizedBox(height: 36),
                    _SurveyWorkflowPreviews(
                      key: _surveyWorkflowKey,
                      state: _state,
                    ),
                    const SizedBox(height: 36),
                    _CalendarPreview(
                      key: _calendarKey,
                      state: _state,
                      onRetry: () => setState(() => _state = LinnState.success),
                    ),
                    const SizedBox(height: 36),
                    _OperationsPreviews(
                      key: _operationsKey,
                      state: _state,
                      onRetry: () => setState(() => _state = LinnState.success),
                    ),
                    const SizedBox(height: 32),
                    const _SaveFlow(),
                    const SizedBox(height: 26),
                    Text(
                      'SG Solar / State API prototype · Colors follow the Figma library. Typography inherits your app theme.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double _galleryCardWidth(double availableWidth) {
  final columns = switch (availableWidth) {
    >= 1050 => 3,
    >= 700 => 2,
    _ => 1,
  };
  return (availableWidth - (columns - 1) * 20) / columns;
}

String _alertTitle(LinnState state) => switch (state) {
  LinnState.error => 'Something went wrong',
  LinnState.loading => 'Working on it',
  LinnState.success => 'Changes saved',
  LinnState.disabled => 'Action unavailable',
  _ => 'A little heads-up',
};

Color _color(LinnState state, BuildContext context) {
  final style = LinnThemeData.of(context);
  final scheme = Theme.of(context).colorScheme;
  final dark = scheme.brightness == Brightness.dark;
  return switch (state) {
    LinnState.error =>
      style.error ?? (dark ? const Color(0xFFFF9995) : const Color(0xFFD32F2F)),
    LinnState.success =>
      style.success ??
          (dark ? const Color(0xFF77D89C) : const Color(0xFF15803D)),
    LinnState.disabled => style.disabled ?? scheme.onSurfaceVariant,
    _ => style.primary ?? (dark ? const Color(0xFF9DBCFF) : _blue),
  };
}

class _ComponentCard extends StatelessWidget {
  const _ComponentCard({
    required this.number,
    required this.title,
    required this.code,
    required this.child,
    this.previewHeight = 178,
    this.codeHeight = 220,
  });
  final int number;
  final String title;
  final String code;
  final Widget child;
  final double previewHeight;
  final double codeHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
            child: _NumberedWidgetTitle(number: number, title: title),
          ),
          Container(
            constraints: BoxConstraints(minHeight: previewHeight),
            padding: const EdgeInsets.all(22),
            alignment: Alignment.center,
            child: child,
          ),
          Container(
            constraints: BoxConstraints(minHeight: codeHeight),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
              border: Border(top: BorderSide(color: scheme.outlineVariant)),
            ),
            child: Text(
              code,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.5,
                height: 1.7,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberedWidgetTitle extends StatelessWidget {
  const _NumberedWidgetTitle({required this.number, required this.title});

  final int number;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            number.toString().padLeft(2, '0'),
            key: ValueKey('gallery-widget-number-$number'),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child, this.padding = EdgeInsets.zero});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    padding: padding,
    child: child,
  );
}

class _SaveFlow extends StatefulWidget {
  const _SaveFlow();
  @override
  State<_SaveFlow> createState() => _SaveFlowState();
}

class _SaveFlowState extends State<_SaveFlow> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController(text: 'Riverside Solar');
  LinnState _state = LinnState.idle;
  bool _simulateError = false;
  bool _validationError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_state.isInteractive) return;
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _validationError = true;
        _state = LinnState.error;
      });
      return;
    }
    final fail = _simulateError;
    setState(() {
      _validationError = false;
      _state = LinnState.loading;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _state = fail ? LinnState.error : LinnState.success);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinnTextField(
            key: const ValueKey('flow-field'),
            label: 'Project name',
            controller: _controller,
            state: switch (_state) {
              LinnState.loading => LinnState.loading,
              LinnState.success => LinnState.success,
              _ => LinnState.idle,
            },
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter a project name.'
                : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            onChanged: (_) {
              if (_state != LinnState.idle) {
                setState(() {
                  _state = LinnState.idle;
                  _validationError = false;
                });
              }
            },
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              LinnButton(
                key: const ValueKey('flow-submit'),
                label: switch (_state) {
                  LinnState.loading => 'Saving project',
                  LinnState.success => 'Saved successfully',
                  LinnState.error => 'Try again',
                  _ => 'Save project',
                },
                state: _state,
                onPressed: _save,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    key: const ValueKey('simulate-error'),
                    value: _simulateError,
                    onChanged: _state == LinnState.loading
                        ? null
                        : (value) => setState(() => _simulateError = value),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Simulate a failed request',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
    final alert = LinnAlert(
      key: const ValueKey('flow-alert'),
      state: _state,
      title: _validationError
          ? 'A project name is needed'
          : _alertTitle(_state),
      message: _validationError
          ? 'Fill in the project name, then try saving again.'
          : switch (_state) {
              LinnState.loading => 'Saving your project. Please wait…',
              LinnState.success =>
                '${_controller.text.trim()} is ready for your team.',
              LinnState.error =>
                'The demo request failed. Turn off the failure switch and try again.',
              _ =>
                'Save a project to watch the button, field, and alert change state together.',
            },
      actionLabel: _state == LinnState.error ? 'Try again' : null,
      onAction: _state == LinnState.error ? _save : null,
    );
    return _Surface(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Try a complete save flow',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'A local simulation with validation, loading, success, and retry. No data is sent.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth < 760
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [form, const SizedBox(height: 24), alert],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: form),
                      const SizedBox(width: 40),
                      Expanded(child: alert),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
