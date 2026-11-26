import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnism_ui_concept_solar/linnism_ui_concept_solar.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(
    body: Center(child: SizedBox(width: 300, child: child)),
  ),
);

void main() {
  for (final state in LinnState.values) {
    testWidgets('dropdown ${state.name} allows or blocks selection', (
      tester,
    ) async {
      String? selection;
      await tester.pumpWidget(
        _host(
          LinnDropdown<String>(
            label: 'Assign team',
            items: const ['Team A', 'Team B'],
            value: 'Team A',
            state: state,
            onChanged: (value) => selection = value,
          ),
        ),
      );
      await tester.tap(
        find.byType(DropdownButton<String>),
        warnIfMissed: false,
      );
      final interactive = switch (state) {
        LinnState.idle || LinnState.error || LinnState.success => true,
        LinnState.loading || LinnState.disabled => false,
      };
      if (interactive) {
        await tester.pumpAndSettle();
        await tester.tap(find.text('Team B').last);
        await tester.pumpAndSettle();
        expect(selection, 'Team B');
      } else {
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Team B'), findsNothing);
        expect(selection, isNull);
        expect(find.text('Team A'), findsOneWidget);
      }
    });
  }

  testWidgets('dropdown with no callback does not open', (tester) async {
    await tester.pumpWidget(
      _host(
        const LinnDropdown<String>(
          label: 'Assign team',
          items: ['Team A', 'Team B'],
          value: 'Team A',
          onChanged: null,
        ),
      ),
    );
    await tester.tap(find.byType(DropdownButton<String>), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Team B'), findsNothing);
  });

  testWidgets('an empty dropdown stays usable without opening an empty menu', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        LinnDropdown<String>(
          label: 'Assign team',
          items: const [],
          onChanged: (_) {},
        ),
      ),
    );
    await tester.tap(find.byType(DropdownButton<String>), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Choose an option'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'dropdown preserves selection and follows external changes and clearing',
    (tester) async {
      String? selection = 'Team A';
      var state = LinnState.error;
      late StateSetter update;
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return LinnDropdown<String>(
                label: 'Assign team',
                items: const ['Team A', 'Team B'],
                value: selection,
                state: state,
                message: state == LinnState.error
                    ? 'Team is unavailable.'
                    : null,
                onChanged: (value) => setState(() => selection = value),
              );
            },
          ),
        ),
      );
      expect(find.text('Team is unavailable.'), findsOneWidget);
      update(() => state = LinnState.loading);
      await tester.pump();
      expect(find.text('Team A'), findsOneWidget);
      expect(find.text('Team is unavailable.'), findsNothing);
      update(() {
        state = LinnState.idle;
        selection = 'Team B';
      });
      await tester.pumpAndSettle();
      expect(find.text('Team B'), findsOneWidget);
      update(() => selection = null);
      await tester.pumpAndSettle();
      expect(find.text('Choose an option'), findsOneWidget);
    },
  );

  testWidgets('generic dropdown supports labels and normal Form validation', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    int? selected;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => Form(
            key: form,
            child: LinnDropdown<int>(
              label: 'Team',
              items: const [1, 2],
              value: selected,
              itemLabel: (item) => 'Team $item',
              onChanged: (value) => setState(() => selected = value),
              validator: (value) => value == null ? 'Choose a team.' : null,
            ),
          ),
        ),
      ),
    );
    expect(form.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('Choose a team.'), findsOneWidget);
    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Team 2').last);
    await tester.pumpAndSettle();
    expect(selected, 2);
    expect(form.currentState!.validate(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Choose a team.'), findsNothing);
  });

  for (final state in LinnState.values) {
    testWidgets('checkbox ${state.name} allows or blocks row taps', (
      tester,
    ) async {
      final changes = <bool>[];
      await tester.pumpWidget(
        _host(
          LinnCheckbox(
            label: 'Send reminders',
            value: false,
            state: state,
            onChanged: changes.add,
          ),
        ),
      );
      await tester.tap(find.text('Send reminders'), warnIfMissed: false);
      await tester.pump();
      expect(changes, switch (state) {
        LinnState.idle || LinnState.error || LinnState.success => [true],
        LinnState.loading || LinnState.disabled => <bool>[],
      });
      expect(
        find.byType(CircularProgressIndicator),
        state == LinnState.loading ? findsOneWidget : findsNothing,
      );
    });
  }

  testWidgets('checkbox label and box each toggle the controlled value once', (
    tester,
  ) async {
    var value = false;
    var calls = 0;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => LinnCheckbox(
            label: 'Send reminders',
            value: value,
            onChanged: (next) => setState(() {
              value = next;
              calls++;
            }),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Send reminders'));
    await tester.pumpAndSettle();
    expect(value, isTrue);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(value, isFalse);
    expect(calls, 2);
  });

  testWidgets(
    'status badge exposes both its label and error state to accessibility',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          _host(
            const LinnStatusBadge(
              label: 'Needs repair',
              state: LinnState.error,
            ),
          ),
        );
        final data = tester
            .getSemantics(find.byType(LinnStatusBadge))
            .getSemanticsData();
        expect(data.label, 'Needs repair');
        expect(data.value, 'Error');
      } finally {
        semantics.dispose();
      }
    },
  );
}
