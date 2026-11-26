import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnism_ui_concept_solar/linnism_ui_concept_solar.dart';

const _appRadius = BorderRadius.all(Radius.circular(12));
const _localRadius = BorderRadius.all(Radius.circular(4));
const _localError = Color(0xFF9B174C);

void _onPressed() {}

void main() {
  testWidgets('app colors seed Linn while local values override individually', (
    tester,
  ) async {
    final appTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      extensions: const [LinnThemeData(success: Colors.purple)],
    );
    final themed = const LinnThemeData(
      borderRadius: _appRadius,
    ).applyTo(appTheme);
    expect(themed.colorScheme, appTheme.colorScheme);
    expect(themed.extension<LinnThemeData>()?.success, Colors.purple);

    await tester.pumpWidget(
      MaterialApp(
        theme: themed,
        home: Scaffold(
          body: Column(
            children: [
              const LinnButton(label: 'Use app theme', onPressed: _onPressed),
              const LinnButton(
                label: 'Override radius',
                onPressed: _onPressed,
                padding: EdgeInsets.all(16),
                style: LinnThemeData(borderRadius: _localRadius),
              ),
              const LinnButton(
                label: 'Custom error',
                onPressed: _onPressed,
                state: LinnState.error,
                style: LinnThemeData(error: _localError, onError: Colors.amber),
              ),
            ],
          ),
        ),
      ),
    );
    ButtonStyle styleFor(String label) => tester
        .widget<FilledButton>(find.widgetWithText(FilledButton, label))
        .style!;
    final appStyle = styleFor('Use app theme');
    final localStyle = styleFor('Override radius');
    final errorStyle = styleFor('Custom error');
    expect(appStyle.backgroundColor!.resolve({}), themed.colorScheme.primary);
    expect(appStyle.foregroundColor!.resolve({}), themed.colorScheme.onPrimary);
    expect(localStyle.backgroundColor!.resolve({}), themed.colorScheme.primary);
    expect(localStyle.padding!.resolve({}), const EdgeInsets.all(16));
    expect(
      (appStyle.shape!.resolve({})! as RoundedRectangleBorder).borderRadius,
      _appRadius,
    );
    expect(
      (localStyle.shape!.resolve({})! as RoundedRectangleBorder).borderRadius,
      _localRadius,
    );
    expect(errorStyle.backgroundColor!.resolve({}), _localError);
    expect(errorStyle.foregroundColor!.resolve({}), Colors.amber);
  });

  testWidgets('changing a field style preserves input and validation', (
    tester,
  ) async {
    const padding = EdgeInsets.symmetric(horizontal: 10, vertical: 8);
    Future<void> pump({
      LinnThemeData? style,
      LinnState state = LinnState.idle,
    }) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LinnTextField(
            label: 'Project',
            state: state,
            style: style,
            contentPadding: padding,
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
    await pump();
    final field = find.byType(TextField);
    await tester.enterText(field, 'Existing draft');
    await pump(
      style: const LinnThemeData(
        error: _localError,
        borderRadius: _localRadius,
      ),
      state: LinnState.error,
    );
    final input = tester.widget<TextField>(field);
    final border = input.decoration!.errorBorder! as OutlineInputBorder;
    expect(input.controller!.text, 'Existing draft');
    expect(input.style?.fontSize, 18);
    expect(input.decoration!.contentPadding, padding);
    expect(border.borderSide.color, _localError);
    expect(border.borderRadius, _localRadius);
    expect(find.text('Please check this field.'), findsOneWidget);
  });

  testWidgets('a date picker carries local style into the Material route', (
    tester,
  ) async {
    const primary = Color(0xFF6A1B9A);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LinnDatePicker(
            label: 'Survey date',
            value: DateTime(2026, 11, 24),
            firstDate: DateTime(2026, 11),
            lastDate: DateTime(2026, 12),
            onChanged: (_) {},
            style: const LinnThemeData(
              primary: primary,
              borderRadius: _localRadius,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(DatePickerDialog));
    expect(Theme.of(context).colorScheme.primary, primary);
    final shape = DatePickerTheme.of(context).shape! as RoundedRectangleBorder;
    expect(shape.borderRadius, _localRadius);
  });

  testWidgets('dialog and snackbar apply style to their displayed surfaces', (
    tester,
  ) async {
    const style = LinnThemeData(error: _localError, borderRadius: _localRadius);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                if (await const LinnDialog(
                          title: 'Review draft',
                          state: LinnState.error,
                          style: style,
                        ).show(context) ==
                        true &&
                    context.mounted) {
                  const LinnSnackbar(
                    message: 'Draft rejected',
                    state: LinnState.error,
                    style: style,
                  ).show(context);
                }
              },
              child: const Text('Review'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
    expect(
      (dialog.shape! as RoundedRectangleBorder).borderRadius,
      _localRadius,
    );
    final confirm = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Confirm'),
    );
    expect(confirm.style!.backgroundColor!.resolve({}), _localError);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    final snackbar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackbar.backgroundColor, _localError);
    expect(
      (snackbar.shape! as RoundedRectangleBorder).borderRadius,
      _localRadius,
    );
  });
}
