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
    testWidgets('button ${state.name} has the expected tap behavior', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        _host(
          LinnButton(label: 'Save', state: state, onPressed: () => calls++),
        ),
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(calls, switch (state) {
        LinnState.idle || LinnState.success || LinnState.error => 1,
        LinnState.loading || LinnState.disabled => 0,
      });
      expect(
        find.byType(CircularProgressIndicator),
        state == LinnState.loading ? findsOneWidget : findsNothing,
      );
    });
  }

  testWidgets('a null callback also disables a button', (tester) async {
    await tester.pumpWidget(
      _host(const LinnButton(label: 'Save', onPressed: null)),
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  testWidgets('explicit field errors clear without losing the entered value', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var state = LinnState.idle;
    late StateSetter update;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return LinnTextField(
              label: 'Project name',
              controller: controller,
              state: state,
              message: state == LinnState.error ? 'Name already exists.' : null,
            );
          },
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'Riverside');
    update(() => state = LinnState.error);
    await tester.pump();
    expect(find.text('Name already exists.'), findsOneWidget);
    update(() => state = LinnState.loading);
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).readOnly,
      isTrue,
    );
    expect(controller.text, 'Riverside');
    update(() => state = LinnState.idle);
    await tester.pumpAndSettle();
    expect(find.text('Name already exists.'), findsNothing);
    await tester.enterText(find.byType(TextFormField), 'Updated project');
    expect(controller.text, 'Updated project');
  });

  testWidgets('field integrates with Flutter Form validation', (tester) async {
    final form = GlobalKey<FormState>();
    await tester.pumpWidget(
      _host(
        Form(
          key: form,
          child: LinnTextField(
            label: 'Project name',
            validator: (value) =>
                value == null || value.isEmpty ? 'Name is required.' : null,
          ),
        ),
      ),
    );
    expect(form.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('Name is required.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Solar project');
    expect(form.currentState!.validate(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Name is required.'), findsNothing);
  });

  testWidgets('disabled field cannot obtain input focus', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      _host(
        LinnTextField(
          label: 'Project name',
          state: LinnState.disabled,
          focusNode: focus,
        ),
      ),
    );
    await tester.tap(find.byType(TextFormField));
    await tester.pump();
    expect(focus.hasFocus, isFalse);
  });

  testWidgets('error alert exposes retry and dismissal callbacks', (
    tester,
  ) async {
    var retries = 0;
    var dismissals = 0;
    await tester.pumpWidget(
      _host(
        LinnAlert(
          title: 'Could not save',
          state: LinnState.error,
          message: 'Please try again.',
          actionLabel: 'Retry',
          onAction: () => retries++,
          onDismiss: () => dismissals++,
        ),
      ),
    );
    await tester.tap(find.text('Retry'));
    await tester.tap(find.byTooltip('Dismiss alert'));
    expect(retries, 1);
    expect(dismissals, 1);
  });

  for (final state in [LinnState.loading, LinnState.disabled]) {
    testWidgets('${state.name} alert blocks action callbacks', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        _host(
          LinnAlert(
            title: 'Please wait',
            state: state,
            actionLabel: 'Retry',
            onAction: () => calls++,
          ),
        ),
      );
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(calls, 0);
    });
  }

  for (final brightness in Brightness.values) {
    for (final state in LinnState.values) {
      testWidgets(
        '${state.name} fits narrow width and large text in ${brightness.name}',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(brightness: brightness),
              home: Scaffold(
                body: MediaQuery(
                  data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: 280,
                      child: Column(
                        children: [
                          LinnButton(
                            label: 'Save project changes',
                            state: state,
                            onPressed: () {},
                          ),
                          LinnTextField(
                            label: 'Project name',
                            state: state,
                            message: 'Helpful feedback for the project name.',
                          ),
                          LinnAlert(
                            title: 'Project update',
                            message:
                                'Helpful feedback that wraps onto several lines.',
                            state: state,
                            actionLabel: 'Try again',
                            onAction: () {},
                            onDismiss: () {},
                          ),
                          LinnDropdown<String>(
                            label: 'Assign team',
                            items: const ['Team A', 'Team B'],
                            value: 'Team A',
                            state: state,
                            message: 'Feedback for the selected team.',
                            onChanged: (_) {},
                          ),
                          LinnCheckbox(
                            label: 'Send survey reminders',
                            value: true,
                            state: state,
                            message:
                                'Helpful feedback for this notification preference.',
                            onChanged: (_) {},
                          ),
                          LinnStatusBadge(
                            label:
                                'A project status that can wrap onto multiple lines',
                            state: state,
                          ),
                          LinnNavItem(
                            label: 'Survey calendar and upcoming visits',
                            icon: Icons.calendar_month_outlined,
                            selected: true,
                            state: state,
                            onPressed: () {},
                          ),
                          LinnSegmentedControl<String>(
                            label: 'Calendar view',
                            options: const {
                              'day': 'Day',
                              'week': 'Week',
                              'month': 'Month',
                            },
                            value: 'week',
                            state: state,
                            onChanged: (_) {},
                          ),
                          LinnAssignmentCard(
                            title:
                                'Riverside site survey and system inspection',
                            subtitle: 'Team A · 9:00–10:30 AM',
                            statusLabel: 'Scheduled for later this week',
                            state: state,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
