import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnism_ui_concept_solar/linnism_ui_concept_solar.dart';

void main() {
  testWidgets('an alert popup wraps its actions and handles retry and close', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var retries = 0;
    var dismissals = 0;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => LinnAlert(
                title: 'Project changes could not be saved',
                message:
                    'Check the connection and try sending the changes again.',
                state: LinnState.error,
                actionLabel: 'Retry the request',
                onAction: () {
                  expect(Navigator.of(context).canPop(), isFalse);
                  retries++;
                },
                onDismiss: () => dismissals++,
              ).show(context),
              child: const Text('Open alert'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open alert'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
    final close = find.text('Close');
    final retry = find.text('Retry the request');
    expect(tester.getCenter(retry).dy, greaterThan(tester.getCenter(close).dy));
    await tester.tap(retry);
    await tester.pumpAndSettle();
    expect(retries, 1);
    expect(dismissals, 0);

    await tester.tap(find.text('Open alert'));
    await tester.pumpAndSettle();
    await tester.tap(close);
    await tester.pumpAndSettle();
    expect(retries, 1);
    expect(dismissals, 1);
  });
}
