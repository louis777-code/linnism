import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnism_ui_concept_solar/linnism_ui_concept_solar.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(
    body: Center(child: SizedBox(width: 280, child: child)),
  ),
);

void main() {
  testWidgets(
    'search keeps its query during loading and emits one clear event',
    (tester) async {
      final changes = <String>[];
      var state = LinnState.idle;
      late StateSetter update;
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (_, setState) {
              update = setState;
              return LinnSearchField(state: state, onChanged: changes.add);
            },
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField), 'Solar');
      await tester.pump();
      update(() => state = LinnState.loading);
      await tester.pump();
      expect(find.text('Solar'), findsOneWidget);
      expect(find.byTooltip('Clear search'), findsNothing);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).readOnly,
        isTrue,
      );
      update(() => state = LinnState.error);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(changes, ['Solar', '']);
      expect(find.text('Solar'), findsNothing);
    },
  );

  testWidgets('pagination stops at boundaries and preserves a busy page', (
    tester,
  ) async {
    int? requested;
    Future<void> pump(int page, LinnState state) => tester.pumpWidget(
      _host(
        LinnPagination(
          page: page,
          pageCount: 2,
          state: state,
          onChanged: (next) => requested = next,
        ),
      ),
    );
    await pump(1, LinnState.idle);
    await tester.tap(find.byTooltip('Previous page'));
    expect(requested, isNull);
    await tester.tap(find.byTooltip('Next page'));
    expect(requested, 2);
    requested = null;
    await pump(2, LinnState.loading);
    expect(find.text('Page 2 of 2'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous page'));
    expect(requested, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
    'loading disables icon and filter actions and preserves filter selection',
    (tester) async {
      var presses = 0;
      final toggles = <bool>[];
      await tester.pumpWidget(
        _host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinnIconButton(
                icon: Icons.refresh,
                label: 'Refresh',
                state: LinnState.loading,
                onPressed: () => presses++,
              ),
              LinnFilterChip(
                label: 'Active',
                selected: true,
                state: LinnState.loading,
                onSelected: toggles.add,
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.byTooltip('Refresh'));
      await tester.tap(find.text('Active'));
      expect(presses, 0);
      expect(toggles, isEmpty);
      expect(
        tester.widget<FilterChip>(find.byType(FilterChip)).selected,
        isTrue,
      );
    },
  );

  testWidgets(
    'busy confirmation can be cancelled and error confirmation can retry',
    (tester) async {
      bool? choice;
      late BuildContext dialogHost;
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) {
              dialogHost = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      const loading = LinnDialog(
        title: 'Clear filters?',
        confirmLabel: 'Clear filters',
        cancelLabel: 'Cancel',
        state: LinnState.loading,
      );
      loading.show(dialogHost).then((value) => choice = value);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.tap(find.text('Clear filters'));
      expect(choice, isNull);
      expect(find.byType(LinnDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(choice, isFalse);

      const error = LinnDialog(
        title: 'Clear filters?',
        confirmLabel: 'Clear filters',
        state: LinnState.error,
      );
      error.show(dialogHost).then((value) => choice = value);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();
      expect(choice, isTrue);
    },
  );
}
