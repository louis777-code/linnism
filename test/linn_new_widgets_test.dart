import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnism_ui_concept_solar/linnism_ui_concept_solar.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(
    body: Center(child: SizedBox(width: 280, child: child)),
  ),
);

void main() {
  test('the existing package import retains compatible Solar aliases', () {
    // ignore: deprecated_member_use_from_same_package, deprecated_member_use
    const button = SolarButton(
      label: 'Save',
      onPressed: null,
      state: SolarState.loading,
    );
    // ignore: deprecated_member_use_from_same_package, deprecated_member_use
    const dropdown = SolarDropdown<String>(
      label: 'Team',
      items: ['A'],
      onChanged: null,
    );
    expect(button, isA<LinnButton>());
    expect(button.state, LinnState.loading);
    expect(dropdown, isA<LinnDropdown<String>>());
  });

  testWidgets(
    'date picker confirms an available date after displaying an error',
    (tester) async {
      DateTime? confirmed;
      await tester.pumpWidget(
        _host(
          LinnDatePicker(
            label: 'Survey date',
            value: DateTime(2026, 11, 24),
            firstDate: DateTime(2026, 11),
            lastDate: DateTime(2026, 11, 30),
            state: LinnState.error,
            message: 'Choose a date with team availability.',
            selectableDayPredicate: (date) => date.day != 25,
            onChanged: (date) => confirmed = date,
          ),
        ),
      );
      expect(
        find.text('Choose a date with team availability.'),
        findsOneWidget,
      );
      await tester.tap(find.byIcon(Icons.error_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('25'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(confirmed, DateTime(2026, 11, 24));

      await tester.tap(find.byIcon(Icons.error_outline_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('26'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(confirmed, DateTime(2026, 11, 26));
    },
  );

  testWidgets('loading and disabled date picker block the calendar', (
    tester,
  ) async {
    for (final state in [LinnState.loading, LinnState.disabled]) {
      await tester.pumpWidget(
        _host(
          LinnDatePicker(
            label: 'Survey date',
            firstDate: DateTime(2026, 11),
            lastDate: DateTime(2026, 11, 30),
            state: state,
            onChanged: (_) =>
                fail('A blocked picker must not change the date.'),
          ),
        ),
      );
      await tester.tap(find.text('Choose a date'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(DatePickerDialog), findsNothing);
    }
  });

  testWidgets(
    'table switches from error to empty and forwards sort and retry',
    (tester) async {
      var retries = 0;
      (int, bool)? sort;
      final columns = [
        DataColumn(
          label: const Text('Project'),
          onSort: (index, ascending) => sort = (index, ascending),
        ),
        const DataColumn(label: Text('Team')),
      ];
      await tester.pumpWidget(
        _host(
          LinnDataTable(
            columns: columns,
            rows: const [],
            state: LinnState.error,
            onRetry: () => retries++,
          ),
        ),
      );
      await tester.tap(find.text('Retry'));
      expect(retries, 1);
      expect(find.byType(DataTable), findsNothing);

      await tester.pumpWidget(
        _host(LinnDataTable(columns: columns, rows: const [])),
      );
      expect(find.text('No records to display.'), findsOneWidget);

      await tester.pumpWidget(
        _host(
          LinnDataTable(
            columns: columns,
            rows: const [
              DataRow(
                cells: [DataCell(Text('Riverside')), DataCell(Text('Team A'))],
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Project'));
      expect(sort, (0, true));
      expect(find.text('Riverside'), findsOneWidget);
    },
  );

  testWidgets('snackbar shows through the messenger and invokes retry once', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => LinnSnackbar(
              message: 'Couldn’t schedule the survey.',
              state: LinnState.error,
              actionLabel: 'Retry',
              onAction: () => retries++,
            ).show(context),
            child: const Text('Show snackbar'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Show snackbar'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Couldn’t schedule the survey.'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(retries, 1);
    expect(find.byType(SnackBar), findsNothing);
  });
}
