import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnism_ui_concept_solar/linnism_ui_concept_solar.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets(
    'supply table sorts quantities numerically without mutating rows',
    (tester) async {
      final rows = <LinnSupplyChainRow>[
        (
          item: 'Mounts',
          quantity: 10,
          supplier: 'A',
          unitPrice: 100,
          total: 1000,
        ),
        (
          item: 'Inverters',
          quantity: 2,
          supplier: 'B',
          unitPrice: 200,
          total: 400,
        ),
      ];
      LinnSupplyChainRow? opened;
      await tester.pumpWidget(
        _host(
          LinnSupplyChainTable(rows: rows, onDetails: (row) => opened = row),
        ),
      );
      String firstItem() =>
          (tester
                      .widget<DataTable>(find.byType(DataTable))
                      .rows
                      .first
                      .cells
                      .first
                      .child
                  as Text)
              .data!;
      expect(firstItem(), 'Mounts');
      await tester.tap(find.text('Qty'));
      await tester.pumpAndSettle();
      expect(firstItem(), 'Inverters');
      expect(rows.first.item, 'Mounts');
      final details = find.text('Details').first;
      await tester.ensureVisible(details);
      await tester.pumpAndSettle();
      await tester.tap(details);
      expect(opened, rows.last);
      await tester.ensureVisible(find.text('Qty'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Qty'));
      await tester.pumpAndSettle();
      expect(firstItem(), 'Mounts');
    },
  );

  testWidgets(
    'stock status uses the chosen enum and preserves its value while loading',
    (tester) async {
      LinnStockAvailability? selected;
      Future<void> pump(LinnState state) => tester.pumpWidget(
        _host(
          LinnStockAvailabilityMenu(
            value: selected ?? LinnStockAvailability.inStock,
            state: state,
            onChanged: (value) => selected = value,
          ),
        ),
      );
      await pump(LinnState.idle);
      final menu = find.byType(DropdownButton<LinnStockAvailability>);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Order needed').last);
      await tester.pumpAndSettle();
      expect(selected, LinnStockAvailability.orderNeeded);
      await pump(LinnState.loading);
      await tester.tap(menu);
      await tester.pump();
      expect(find.text('Order needed'), findsOneWidget);
      expect(find.text('In stock'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets('assignment hides stale team IDs and waits for a valid team', (
    tester,
  ) async {
    String? assigned;
    Future<void> pump(String id) => tester.pumpWidget(
      _host(
        LinnApprovalAssignment(
          decision: LinnReviewDecision.approved,
          teams: const {'atlas': 'Team Atlas'},
          teamId: id,
          onAssign: (team) => assigned = team,
        ),
      ),
    );
    await pump('missing');
    expect(find.text('Choose a team'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await pump('atlas');
    await tester.tap(find.text('Assign'));
    expect(assigned, 'atlas');
  });
}
