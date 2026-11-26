import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnism_ui_concept_solar/linnism_ui_concept_solar.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(
    body: Center(child: SizedBox(width: 240, child: child)),
  ),
);

void main() {
  testWidgets(
    'quantity stepper reports changes within bounds and blocks busy taps',
    (tester) async {
      final changes = <int>[];
      Future<void> pump(int value, LinnState state) => tester.pumpWidget(
        _host(
          LinnQuantityStepper(
            value: value,
            min: 1,
            max: 2,
            state: state,
            onChanged: changes.add,
          ),
        ),
      );
      await pump(1, LinnState.idle);
      await tester.tap(find.byTooltip('Decrease quantity'));
      await tester.tap(find.byTooltip('Increase quantity'));
      await pump(2, LinnState.idle);
      await tester.tap(find.byTooltip('Increase quantity'));
      await tester.tap(find.byTooltip('Decrease quantity'));
      await pump(2, LinnState.loading);
      await tester.tap(find.byTooltip('Decrease quantity'));
      expect(changes, [2, 1]);
      expect(find.text('2'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'busy survey controls preserve the item and block approval and scheduling',
    (tester) async {
      final events = <String>[];
      Widget view(LinnState state) => _host(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinnScheduleSlot(
              timeLabel: '9:00 AM',
              onPressed: () => events.add('schedule'),
              state: state,
            ),
            LinnItemSelectionRow(
              label: 'Roof mounting kit',
              selected: true,
              onSelected: (_) => events.add('select'),
              state: state,
            ),
            LinnApprovalActions(
              onApprove: () => events.add('approve'),
              onReject: () => events.add('reject'),
              state: state,
            ),
          ],
        ),
      );

      for (final state in [
        LinnState.loading,
        LinnState.disabled,
        LinnState.error,
      ]) {
        await tester.pumpWidget(view(state));
        await tester.pump();
        for (final label in [
          'Schedule survey',
          'Roof mounting kit',
          'Approve',
          'Reject',
        ]) {
          await tester.tap(find.text(label));
        }
        expect(tester.widget<ListTile>(find.byType(ListTile)).selected, isTrue);
        expect(
          events,
          state == LinnState.error
              ? ['schedule', 'select', 'approve', 'reject']
              : isEmpty,
        );
      }
    },
  );

  testWidgets(
    'dot-only variant exposes the status label to readers and tooltips',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          _host(
            const LinnStatusDot(
              label: 'Awaiting review',
              tone: LinnStatusTone.warning,
              showLabel: false,
            ),
          ),
        );
        expect(find.text('Awaiting review'), findsNothing);
        expect(find.byTooltip('Awaiting review'), findsOneWidget);
        expect(
          tester
              .getSemantics(find.byType(LinnStatusDot))
              .getSemanticsData()
              .label,
          'Awaiting review',
        );
      } finally {
        semantics.dispose();
      }
    },
  );
}
