# Linn UI for Flutter

Linn UI provides 37 Material widgets for forms, feedback, calendars, tables, and
workflows. Use the same `state:` parameter to show loading, success, errors, or
unavailable actions. Your app owns the data and state transitions.

[Install](#add-linn-ui-to-your-app) · [First screen](#build-your-first-screen) ·
[Theme](#use-your-app-theme) · [Popups](#alerts-dialogs-and-snackbars) ·
[Calendars](#date-picker-and-calendar) · [Tables and workflows](#tables-and-workflows) ·
[Widget reference](#widget-reference)

## Add Linn UI to your app

Use a Flutter SDK with Dart `^3.12.0`. This package was verified with Flutter
`3.44.0` and Dart `3.12.0`. Run `flutter --version` to check your SDK.

### Use a local copy

If your Flutter app and `linnism_ui_concept_solar` folders are next to each
other, add this entry under `dependencies:` in **your app's** `pubspec.yaml`.
Keep the app's existing dependencies. The relative path starts at the app folder
and points to the package folder that contains its own `pubspec.yaml`.

```yaml
dependencies:
  flutter:
    sdk: flutter
  linnism_ui_concept_solar:
    path: ../linnism_ui_concept_solar
```

If the package is elsewhere, adjust `path` to match its location. From your app
folder, run `flutter pub get`, then import Linn UI in any screen that uses it.
[Flutter package setup](https://docs.flutter.dev/packages-and-plugins/using-packages#adding-a-package-dependency-to-an-app)

```dart
import 'package:linnism_ui_concept_solar/linnism_ui_concept_solar.dart';
```

### Share the package through Git

Once you host the package in Git, you can use the same dependency entry with a
Git URL. Replace the example URL and ref with your repository and a tag or
commit, then run `flutter pub get` from your app folder. [Dart dependency reference](https://dart.dev/tools/pub/dependencies#git-packages)

```yaml
dependencies:
  linnism_ui_concept_solar:
    git:
      url: https://github.com/your-org/linnism_ui_concept_solar.git
      ref: your-tag-or-commit
```

## Build your first screen

Put this in `lib/main.dart` in a test app, or add `ProjectForm` to a screen in
your existing app. The sample uses `MaterialApp`, `Scaffold`, and the default
Linn style. It validates a project name, updates the button while saving, and
shows a retryable inline alert if the save fails.

```dart
import 'package:flutter/material.dart';
import 'package:linnism_ui_concept_solar/linnism_ui_concept_solar.dart';

void main() => runApp(const MaterialApp(home: ProjectForm()));

class ProjectForm extends StatefulWidget {
  const ProjectForm({super.key});

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  LinnState _saveState = LinnState.idle;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saveState == LinnState.loading || !_formKey.currentState!.validate()) {
      return;
    }
    final name = _name.text.trim();
    FocusScope.of(context).unfocus();
    setState(() => _saveState = LinnState.loading);

    try {
      // Replace this demo operation with your repository or API call.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (name.toLowerCase() == 'offline') {
        throw StateError('Simulated connection failure');
      }
      if (!mounted) return;
      setState(() => _saveState = LinnState.success);
      const LinnSnackbar(
        message: 'Project saved.',
        state: LinnState.success,
      ).show(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saveState = LinnState.error);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('New project')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinnTextField(
              label: 'Project name',
              controller: _name,
              state: _saveState == LinnState.loading
                  ? LinnState.loading
                  : LinnState.idle,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a project name.'
                  : null,
            ),
            if (_saveState == LinnState.error) ...[
              const SizedBox(height: 16),
              LinnAlert(
                title: 'Could not save the project',
                message: 'Check the connection and try again.',
                state: LinnState.error,
                actionLabel: 'Retry',
                onAction: _save,
              ),
            ],
            const SizedBox(height: 16),
            LinnButton(
              label: switch (_saveState) {
                LinnState.loading => 'Saving…',
                LinnState.success => 'Saved',
                LinnState.error => 'Try again',
                _ => 'Save project',
              },
              state: _saveState,
              onPressed: _save,
            ),
          ],
        ),
      ),
    ),
  );
}
```

Run `flutter run` from your app folder. Enter `offline` to see the error state.
Change the name and select **Retry** to see the success state.

### How widget states work

| State | When to use it | Example behavior |
| --- | --- | --- |
| `LinnState.idle` | Default | A button accepts presses and a field is editable. |
| `LinnState.loading` | A request is running | Buttons block repeat presses. Fields retain their values. |
| `LinnState.success` | A request completed | The widget shows confirmation. Available actions still work. |
| `LinnState.error` | Validation or a request failed | The widget shows error feedback. Supply a retry callback where appropriate. |
| `LinnState.disabled` | An action is unavailable | The widget uses muted styling and blocks its action. |

Keep values and state in `setState` or your existing state manager. Update the
`value` when controls such as `LinnDropdown`, `LinnCheckbox`, or `LinnDatePicker`
call `onChanged`. Keep business data such as a scheduled survey or an approved
request in its own value. Use `LinnState` for the current operation.

`LinnTextField` takes a `controller` or an `initialValue`. Both it and
`LinnDropdown` work with Flutter `Form` and `validator`. To show an error from
your own code, pass `state: LinnState.error` and a `message`. This explicit
error takes priority over the form validator. Dropdown items must be distinct,
and the selected `value` must appear in `items` or be `null`.

## Use your app theme

Theme setup is optional. Linn widgets already inherit the surrounding Flutter
surfaces and typography. Call `applyTo` to seed Linn's primary and error colors
from your existing theme and set package-wide options such as the corner radius
and success color. Apply it to each theme you supply to `MaterialApp`.

```dart
const linnTheme = LinnThemeData(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  success: Color(0xFF168047),
  onSuccess: Colors.white,
);

MaterialApp(
  theme: linnTheme.applyTo(appLightTheme),
  darkTheme: linnTheme.applyTo(appDarkTheme),
  themeMode: ThemeMode.system,
  home: const ProjectForm(),
);
```

Every Linn widget accepts `style:`. It overrides the supplied values for that
widget and its nested Linn controls. The app-wide theme supplies the remaining
values. When overriding a fill color, you can also provide its foreground
color with `onPrimary`, `onSuccess`, or `onError`.

```dart
LinnButton(
  label: 'Save project',
  onPressed: saveProject,
  style: const LinnThemeData(
    primary: Color(0xFF6A1B9A),
    onPrimary: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(4)),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  minimumSize: const Size(120, 48),
  textStyle: const TextStyle(fontWeight: FontWeight.w700),
);
```

`LinnTextField`, `LinnSearchField`, `LinnDropdown`, and `LinnDatePicker` also
accept `contentPadding` and `textStyle`.

## Alerts, dialogs, and snackbars

Place `LinnAlert` in your widget tree for inline feedback, as in the first
screen. Use `show(context)` to display the same alert as a popup. When you
supply `actionLabel` and `onAction`, choosing the action closes the popup and
then runs the callback.

```dart
Future<void> showSaveError(BuildContext context, VoidCallback retry) {
  return LinnAlert(
    title: 'Could not save the project',
    message: 'Check the connection and try again.',
    state: LinnState.error,
    actionLabel: 'Retry',
    onAction: retry,
  ).show(context);
}
```

Await `LinnDialog.show(context)` before acting. It returns `true` on
confirmation, `false` on Cancel, and `null` when dismissed. For a read-only
popup with one action, pass `showCancel: false` and `confirmLabel: 'Close'`.

```dart
Future<void> confirmClearFilters(BuildContext context, VoidCallback clear) async {
  final confirmed = await const LinnDialog(
    title: 'Clear project filters?',
    message: 'This clears your search and shows all projects.',
    confirmLabel: 'Clear filters',
  ).show(context);

  if (confirmed != true || !context.mounted) return;
  clear();
  const LinnSnackbar(
    message: 'Filters cleared.',
    state: LinnState.success,
  ).show(context);
}
```

Call `LinnSnackbar.show(context)` from a screen with a `Scaffold` under a
`ScaffoldMessenger`. A typical `MaterialApp` provides the messenger. For an
Undo or Retry action, pass both `actionLabel` and `onAction`.

## Date picker and calendar

Use `LinnDatePicker` to select a date. Pass `firstDate`, `lastDate`, and
`onChanged`, then store the selected `value` in your app. You can restrict
selection with `selectableDayPredicate`.

Use `LinnCalendarView` to browse existing events. The following fields and
method go inside a `State` class. The chosen date, view, and event times are
all supplied by the app.

```dart
DateTime _focusedDate = DateTime(2026, 11, 24);
LinnCalendarMode _mode = LinnCalendarMode.week;

final _events = [
  LinnCalendarEvent(
    id: 'survey-001',
    title: 'North Market survey',
    start: DateTime(2026, 11, 24, 9, 30),
    end: DateTime(2026, 11, 24, 10, 15),
    subtitle: 'Team Atlas',
    statusLabel: 'Confirmed',
  ),
];

Widget buildSurveyCalendar() => LinnCalendarView(
  focusedDate: _focusedDate,
  events: _events,
  mode: _mode,
  onDateChanged: (date) => setState(() => _focusedDate = date),
  onModeChanged: (mode) => setState(() => _mode = mode),
  startHour: 8,
  endHour: 17,
  slotMinutes: 30,
);
```

When you load events from an API, map each record to a `LinnCalendarEvent` with
an ID and actual start and end `DateTime` values. The widget displays device
local time. The end must be after the start and marks the exclusive end of the
interval. Tapping an event opens its details by default. Pass `onEventPressed`
to open your own detail screen. Supplying both date and mode callbacks lets
users jump from Month to Day.

## Tables and workflows

Use `LinnDataTable` for your own Flutter `DataColumn` and `DataRow` objects.
Handle `DataColumn.onSort` in your app and rebuild with the new order. Use a
typed operational table when one of the built-in column layouts fits. These
tables sort the displayed records and preserve the order of your supplied list.
An empty `rows` list shows the empty view. Pass `state: LinnState.error` and
`onRetry` to show a retryable load error.

```dart
LinnStockTable(
  rows: const <LinnStockRow>[
    (
      item: '6 kW inverter',
      warehouse: 'Central',
      onHand: 6,
      toBuy: 0,
      ordered: 2,
      availability: LinnStockAvailability.inStock,
    ),
  ],
  state: LinnState.idle,
);
```

Depending on the operational table, you can supply row callbacks such as
`onDetails`, `onEdit`, and `onDelete`. BOQ, supply chain, and supplier tables
accept `currency` for their integer amounts. Custom status cells take a label
and a `LinnStatusTone`.

`LinnApprovalAssignment` takes a review decision and a map of team IDs to
display names. Keep the decision and selected team ID in your state. Update
`decision` when approval succeeds, update `teamId` in `onTeamChanged`, and
persist the assignment in `onAssign`. Assignment becomes available once the
request is approved and the selected ID exists in the map. [Approval and table examples](example/lib/operations_previews.dart)

## Widget reference

The numbers match the interactive gallery.

| # | Widget | Use |
| --- | --- | --- |
| 01 | `LinnButton` | Run an action and show its progress or result. |
| 02 | `LinnTextField` | Collect and validate text. |
| 03 | `LinnAlert` | Show feedback inline or as a popup with a retry action. |
| 04 | `LinnDropdown<T>` | Select one value from distinct options. |
| 05 | `LinnCheckbox` | Toggle a Boolean with a tappable label. |
| 06 | `LinnStatusBadge` | Display a compact status label and state indicator. |
| 07 | `LinnNavItem` | Select a navigation destination. |
| 08 | `LinnSegmentedControl<T>` | Switch between a small set of labeled options. |
| 09 | `LinnAssignmentCard` | Show a scheduled assignment and an optional action. |
| 10 | `LinnDatePicker` | Select one date within a range. |
| 11 | `LinnDataTable` | Display custom rows and columns. |
| 12 | `LinnSnackbar` | Show temporary feedback with an optional Undo or Retry. |
| 13 | `LinnSearchField` | Report search changes and clear the query. |
| 14 | `LinnFilterChip` | Toggle a category or filter. |
| 15 | `LinnIconButton` | Run a compact action with an accessible label. |
| 16 | `LinnPagination` | Browse one-based pages. Use `page: 0, pageCount: 0` for no results. |
| 17 | `LinnSummaryCard` | Show a metric and optional details. |
| 18 | `LinnDialog` | Confirm an action or open a details popup. |
| 19 | `LinnCalendarHeader` | Display a period and navigate to the previous or next one. |
| 20 | `LinnScheduleSlot` | Display a time slot and trigger a scheduling action. |
| 21 | `LinnItemSelectionRow` | Select an item with a label, description, and optional icon. |
| 22 | `LinnQuantityStepper` | Increase or decrease a quantity within `min` and `max`. |
| 23 | `LinnApprovalActions` | Approve or reject a request with shared feedback. |
| 24 | `LinnStatusDot` | Show a business status with a colored marker and label. |
| 25 | `LinnCalendarView` | Browse and inspect existing events in Day, Week, and Month views. |
| 26 | `LinnSalesTable` | List enquiries, projects, and survey assignments. |
| 27 | `LinnEngineeringTable` | List engineering projects and survey status. |
| 28 | `LinnBoqCostingTable` | List bills of quantities, cost estimates, and approvals. |
| 29 | `LinnSupplyChainTable` | List materials, quantities, suppliers, and costs. |
| 30 | `LinnProcurementTable` | List orders, delivery status, and lead times. |
| 31 | `LinnSupplierTable` | List contacts, terms, and spend. |
| 32 | `LinnStockTable` | List warehouse stock and quantities to buy. |
| 33 | `LinnTeamPicker` | Select a team by ID from a map of team names. |
| 34 | `LinnScheduleStatusMenu` | Choose a scheduled, done, or canceled status. |
| 35 | `LinnStockAvailabilityMenu` | Choose in stock or order needed. |
| 36 | `LinnWorkflowActions` | Continue with optional Edit and Cancel. |
| 37 | `LinnApprovalAssignment` | Approve a request and assign a team. |

Use `Linn` names in new code. Deprecated `Solar` aliases are available for
existing apps.

## Run the interactive gallery

From the package folder, run the gallery in Chrome.

```sh
cd example
flutter pub get
flutter run -d chrome
```

Choose **Custom app theme** to compare app-wide styling with widget 01's local
override. Select **Error** and use **Preview popup** on widget 03 to try Retry.
Widget 18 previews the confirmation dialog. The gallery also includes calendar
and workflow demos and an end-to-end save simulation. [Gallery source](example/lib/main.dart)

## Check the package

```sh
flutter analyze
flutter test
cd example
flutter analyze
flutter test
```

## Design reference

The default accent colors come from SG Solar. The base button is blue
(`#306CD8`), with hover (`#1E4895`) and pressed (`#2559B9`) shades. The default
error and success colors are `#D32F2F` and `#15803D`, with lighter accents in
dark mode. Linn controls use an 8 px default corner radius, and dialog
surfaces use 16 px. Typography inherits the host app's theme. State icons use
Flutter's Material icons. Flutter is the only runtime dependency. [SG Solar design](https://www.figma.com/design/7RQZjc5J8sa4ttJpUdjNnZ/SG-Solar?node-id=289-5791)
