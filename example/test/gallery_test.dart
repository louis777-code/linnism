import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnism_ui_concept_solar/linnism_ui_concept_solar.dart';

import 'package:solar_widget_gallery/main.dart';

void main() {
  void viewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('gallery lists all 37 distinct numbered previews', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 1300));
    await tester.pumpWidget(const LinnGalleryApp());
    for (var number = 1; number <= 37; number++) {
      final title = find.byKey(ValueKey('gallery-widget-number-$number'));
      expect(title, findsOneWidget);
      expect(
        tester.widget<Text>(title).data,
        number.toString().padLeft(2, '0'),
      );
    }
    final numbered = find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith(
            'gallery-widget-number-',
          ),
    );
    expect(numbered, findsNWidgets(37));
  });

  testWidgets('gallery switches every preview state and supports dark mode', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 1300));
    await tester.pumpWidget(const LinnGalleryApp());
    for (final state in LinnState.values) {
      await tester.tap(find.byKey(ValueKey('state-${state.name}')));
      await tester.pump();
      expect(
        tester
            .widget<LinnButton>(find.byKey(const ValueKey('preview-button')))
            .state,
        state,
      );
      expect(
        tester
            .widget<LinnTextField>(find.byKey(const ValueKey('preview-field')))
            .state,
        state,
      );
      expect(
        tester
            .widget<LinnAlert>(find.byKey(const ValueKey('preview-alert')))
            .state,
        state,
      );
      expect(
        tester
            .widget<LinnDropdown<String>>(
              find.byKey(const ValueKey('preview-dropdown')),
            )
            .state,
        state,
      );
      expect(
        tester
            .widget<LinnCheckbox>(
              find.byKey(const ValueKey('preview-checkbox')),
            )
            .state,
        state,
      );
      expect(
        tester
            .widget<LinnStatusBadge>(
              find.byKey(const ValueKey('preview-badge')),
            )
            .state,
        state,
      );
      expect(tester.takeException(), isNull);
    }
    await tester.tap(find.byKey(const ValueKey('theme-toggle')));
    await tester.pumpAndSettle();
    final context = tester.element(find.byKey(const ValueKey('preview-alert')));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(tester.takeException(), isNull);
  });

  testWidgets('alert preview retries from the error popup', (tester) async {
    viewport(tester, const Size(1440, 1100));
    await tester.pumpWidget(const LinnGalleryApp());
    await tester.tap(find.byKey(const ValueKey('state-error')));
    await tester.pumpAndSettle();
    final trigger = find.byKey(const ValueKey('preview-alert-popup'));
    await tester.ensureVisible(trigger);
    await tester.tap(trigger);
    await tester.pumpAndSettle();
    final popup = find.byType(AlertDialog);
    expect(popup, findsOneWidget);
    await tester.tap(find.descendant(of: popup, matching: find.text('Retry')));
    await tester.pumpAndSettle();
    expect(popup, findsNothing);
    final alert = tester.widget<LinnAlert>(
      find.byKey(const ValueKey('preview-alert')),
    );
    expect(alert.state, LinnState.success);
  });

  testWidgets('gallery previews the app theme and a local button override', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 1300));
    await tester.pumpWidget(const LinnGalleryApp());
    final button = find.descendant(
      of: find.byKey(const ValueKey('preview-button')),
      matching: find.byType(FilledButton),
    );
    ButtonStyle buttonStyle() => tester.widget<FilledButton>(button).style!;
    final defaultColor = buttonStyle().backgroundColor!.resolve({});
    final field = find.descendant(
      of: find.byKey(const ValueKey('preview-field')),
      matching: find.byType(TextField),
    );

    await tester.tap(find.byKey(const ValueKey('custom-app-theme')));
    await tester.pumpAndSettle();
    final lightTheme = Theme.of(tester.element(button));
    expect(
      buttonStyle().backgroundColor!.resolve({}),
      lightTheme.colorScheme.primary,
    );
    expect(buttonStyle().backgroundColor!.resolve({}), isNot(defaultColor));
    final buttonShape =
        buttonStyle().shape!.resolve({})! as RoundedRectangleBorder;
    final fieldBorder =
        tester.widget<TextField>(field).decoration!.enabledBorder!
            as OutlineInputBorder;
    expect(buttonShape.borderRadius, BorderRadius.circular(4));
    expect(fieldBorder.borderRadius, BorderRadius.circular(14));

    await tester.tap(find.byKey(const ValueKey('theme-toggle')));
    await tester.pumpAndSettle();
    final darkTheme = Theme.of(tester.element(button));
    expect(darkTheme.brightness, Brightness.dark);
    expect(
      buttonStyle().backgroundColor!.resolve({}),
      darkTheme.colorScheme.primary,
    );
  });

  testWidgets('save demo handles validation, request failure, and retry', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 1500));
    await tester.pumpWidget(const LinnGalleryApp());
    final field = find.descendant(
      of: find.byKey(const ValueKey('flow-field')),
      matching: find.byType(TextFormField),
    );
    final submit = find.byKey(const ValueKey('flow-submit'));
    await tester.ensureVisible(field);
    await tester.enterText(field, '');
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('Enter a project name.'), findsOneWidget);
    await tester.enterText(field, 'New solar project');
    await tester.tap(find.byKey(const ValueKey('simulate-error')));
    await tester.tap(submit);
    await tester.pump();
    expect(tester.widget<LinnButton>(submit).state, LinnState.loading);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(
      tester.widget<LinnAlert>(find.byKey(const ValueKey('flow-alert'))).state,
      LinnState.error,
    );
    await tester.tap(find.byKey(const ValueKey('simulate-error')));
    await tester.tap(submit);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(
      tester.widget<LinnAlert>(find.byKey(const ValueKey('flow-alert'))).state,
      LinnState.success,
    );
    expect(
      find.text('New solar project is ready for your team.'),
      findsOneWidget,
    );
  });

  testWidgets('gallery fits a small phone viewport', (tester) async {
    viewport(tester, const Size(320, 740));
    await tester.pumpWidget(const LinnGalleryApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('flow-alert')),
      400,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('gallery-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'calendar previews preserve selections and block taps while busy',
    (tester) async {
      viewport(tester, const Size(1440, 2400));
      await tester.pumpWidget(const LinnGalleryApp());

      final nav = find.byKey(const ValueKey('preview-nav-item'));
      final view = find.byKey(const ValueKey('preview-segmented'));
      final assignment = find.byKey(const ValueKey('preview-assignment'));
      final day = find.descendant(of: view, matching: find.text('Day'));
      final month = find.descendant(of: view, matching: find.text('Month'));
      final navLabel = find.descendant(
        of: nav,
        matching: find.text('Survey calendar'),
      );
      final assignmentTitle = find.descendant(
        of: assignment,
        matching: find.text('Riverside site survey'),
      );

      await tester.tap(navLabel);
      await tester.tap(day);
      await tester.tap(assignmentTitle);
      await tester.pumpAndSettle();

      for (final state in [LinnState.loading, LinnState.disabled]) {
        await tester.tap(find.byKey(ValueKey('state-${state.name}')));
        await tester.pump();
        await tester.tap(navLabel);
        await tester.tap(month);
        await tester.tap(assignmentTitle);
        await tester.pump();
        final navWidget = tester.widget<LinnNavItem>(nav);
        final viewWidget = tester.widget<LinnSegmentedControl<String>>(view);
        final assignmentWidget = tester.widget<LinnAssignmentCard>(assignment);
        expect(navWidget.state, state);
        expect(viewWidget.state, state);
        expect(assignmentWidget.state, state);
        expect(navWidget.selected, isTrue);
        expect(viewWidget.value, 'day');
        expect(assignmentWidget.selected, isTrue);
      }

      await tester.tap(find.byKey(const ValueKey('state-error')));
      await tester.pumpAndSettle();
      await tester.tap(month);
      await tester.pumpAndSettle();
      expect(tester.widget<LinnSegmentedControl<String>>(view).value, 'month');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'dashboard previews connect search, filtering, pagination and reset',
    (tester) async {
      viewport(tester, const Size(1440, 1300));
      await tester.pumpWidget(const LinnGalleryApp());
      await tester.tap(find.widgetWithText(TextButton, 'Dashboard widgets'));
      await tester.pumpAndSettle();
      final summary = find.byKey(const ValueKey('preview-summary'));
      final pagination = find.byKey(const ValueKey('preview-pagination'));
      final search = find.descendant(
        of: find.byKey(const ValueKey('preview-search')),
        matching: find.byType(TextFormField),
      );
      LinnSummaryCard metric() => tester.widget<LinnSummaryCard>(summary);
      LinnPagination pages() => tester.widget<LinnPagination>(pagination);

      expect(metric().value, '8');
      await tester.ensureVisible(pagination);
      await tester.tap(find.byTooltip('Next page'));
      await tester.pumpAndSettle();
      expect(pages().page, 2);
      expect(metric().details, contains('Lakeview'));

      final chip = find.byKey(const ValueKey('preview-filter-chip'));
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(metric().value, '5');
      expect(pages().page, 1);

      await tester.ensureVisible(search);
      await tester.enterText(search, 'north');
      await tester.pumpAndSettle();
      expect(metric().value, '0');
      expect(pages().page, 0);
      expect(pages().pageCount, 0);

      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(metric().value, '5');

      final dialog = find.byKey(const ValueKey('preview-dialog-trigger'));
      await tester.ensureVisible(dialog);
      await tester.tap(dialog);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();
      expect(metric().value, '8');
      expect(tester.widget<LinnFilterChip>(chip).selected, isFalse);
      expect(find.text('Filters cleared.'), findsOneWidget);
    },
  );

  testWidgets(
    'survey keeps a slot in its week and reopens review on quantity change',
    (tester) async {
      viewport(tester, const Size(1440, 1300));
      await tester.pumpWidget(const LinnGalleryApp());
      await tester.tap(find.widgetWithText(TextButton, 'Survey & BOQ'));
      await tester.pumpAndSettle();

      final header = find.byKey(const ValueKey('preview-calendar-header'));
      final slot = find.byKey(const ValueKey('preview-schedule-slot'));
      final originalWeek = tester.widget<LinnCalendarHeader>(header).title;
      await tester.tap(slot);
      await tester.pumpAndSettle();
      expect(
        tester.widget<LinnScheduleSlot>(slot).label,
        'Release survey slot',
      );
      await tester.tap(
        find.descendant(of: header, matching: find.byTooltip('Next period')),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<LinnCalendarHeader>(header).title,
        isNot(originalWeek),
      );
      expect(tester.widget<LinnScheduleSlot>(slot).label, 'Schedule survey');
      await tester.tap(
        find.descendant(
          of: header,
          matching: find.byTooltip('Previous period'),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<LinnScheduleSlot>(slot).label,
        'Release survey slot',
      );

      final approval = find.byKey(const ValueKey('preview-approval'));
      final status = find.byKey(const ValueKey('preview-status-dot'));
      final quantity = find.byKey(const ValueKey('preview-quantity'));
      await tester.ensureVisible(approval);
      await tester.tap(
        find.descendant(of: approval, matching: find.text('Approve')),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<LinnStatusDot>(status).label, 'Item approved');
      expect(tester.widget<LinnStatusDot>(status).tone, LinnStatusTone.success);
      await tester.ensureVisible(quantity);
      await tester.tap(find.byTooltip('Increase quantity'));
      await tester.pumpAndSettle();
      expect(tester.widget<LinnQuantityStepper>(quantity).value, 3);
      expect(tester.widget<LinnStatusDot>(status).label, 'Awaiting review');

      final item = find.byKey(const ValueKey('preview-item-selection'));
      await tester.ensureVisible(item);
      await tester.tap(item);
      await tester.pumpAndSettle();
      expect(tester.widget<LinnStatusDot>(status).label, 'No item selected');
      expect(tester.widget<LinnApprovalActions>(approval).onApprove, isNull);
    },
  );

  testWidgets(
    'full calendar opens existing event details from Week, Month and Day',
    (tester) async {
      viewport(tester, const Size(1440, 1350));
      await tester.pumpWidget(const LinnGalleryApp());
      await tester.tap(find.widgetWithText(TextButton, 'Calendar demo'));
      await tester.pumpAndSettle();
      final calendar = find.byKey(const ValueKey('live-calendar'));
      Finder inCalendar(Finder target) =>
          find.descendant(of: calendar, matching: target);
      Finder inDialog(Finder target) =>
          find.descendant(of: find.byType(AlertDialog), matching: target);
      final hilltop = inCalendar(find.text('Hilltop assessment'));
      await tester.ensureVisible(hilltop);
      await tester.tap(hilltop);
      await tester.pumpAndSettle();
      expect(inDialog(find.text('Team B')), findsOneWidget);
      expect(inDialog(find.textContaining('north entrance')), findsOneWidget);
      Navigator.of(tester.element(find.byType(AlertDialog))).pop();
      await tester.pumpAndSettle();
      final month = inCalendar(find.text('Month'));
      await tester.ensureVisible(month);
      await tester.tap(inCalendar(find.text('Month')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<LinnCalendarView>(calendar).mode,
        LinnCalendarMode.month,
      );
      final riverside = inCalendar(find.text('Riverside survey'));
      expect(riverside, findsOneWidget);
      await tester.ensureVisible(riverside);
      await tester.tap(riverside);
      await tester.pumpAndSettle();
      expect(inDialog(find.text('Confirmed')), findsOneWidget);
      expect(
        tester.widget<LinnCalendarView>(calendar).mode,
        LinnCalendarMode.month,
      );
      Navigator.of(tester.element(find.byType(AlertDialog))).pop();
      await tester.pumpAndSettle();
      final day = inCalendar(find.text('24'));
      await tester.ensureVisible(day);
      await tester.tap(day);
      await tester.pumpAndSettle();
      expect(
        tester.widget<LinnCalendarView>(calendar).mode,
        LinnCalendarMode.day,
      );

      expect(inCalendar(find.byType(LinnScheduleSlot)), findsNothing);
      await tester.ensureVisible(hilltop);
      await tester.tap(hilltop);
      await tester.pumpAndSettle();
      expect(inDialog(find.text('Hilltop assessment')), findsOneWidget);
    },
  );

  testWidgets('the numbered approval demo approves and assigns a team', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 1350));
    await tester.pumpWidget(const LinnGalleryApp());
    await tester.tap(find.widgetWithText(TextButton, 'Operations & workflows'));
    await tester.pumpAndSettle();
    final approval = find.byKey(const ValueKey('preview-approval-assignment'));
    Finder inApproval(Finder target) =>
        find.descendant(of: approval, matching: target);
    final approve = inApproval(find.text('Approve'));
    await tester.ensureVisible(approve);
    await tester.tap(approve);
    await tester.pumpAndSettle();
    expect(
      tester.widget<LinnApprovalAssignment>(approval).decision,
      LinnReviewDecision.approved,
    );
    final picker = inApproval(find.byType(DropdownButton<String>));
    await tester.ensureVisible(picker);
    await tester.tap(picker);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Team Cedar').last);
    await tester.pumpAndSettle();
    final assign = inApproval(find.text('Assign'));
    await tester.ensureVisible(assign);
    await tester.tap(assign);
    await tester.pumpAndSettle();
    expect(inApproval(find.text('Assigned to Team Cedar.')), findsOneWidget);
  });

  testWidgets(
    'new previews allow selection and preserve values while loading',
    (tester) async {
      viewport(tester, const Size(1440, 1500));
      await tester.pumpWidget(const LinnGalleryApp());
      final dropdown = find.byKey(const ValueKey('preview-dropdown'));
      final checkbox = find.byKey(const ValueKey('preview-checkbox'));
      await tester.ensureVisible(dropdown);
      await tester.tap(
        find.descendant(
          of: dropdown,
          matching: find.byType(DropdownButton<String>),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Team B').last);
      await tester.pumpAndSettle();
      expect(tester.widget<LinnDropdown<String>>(dropdown).value, 'Team B');
      await tester.ensureVisible(checkbox);
      await tester.tap(find.text('Send survey reminders'));
      await tester.pumpAndSettle();
      expect(tester.widget<LinnCheckbox>(checkbox).value, isFalse);
      final loading = find.byKey(const ValueKey('state-loading'));
      await tester.ensureVisible(loading);
      await tester.tap(loading);
      await tester.pump();
      expect(tester.widget<LinnDropdown<String>>(dropdown).value, 'Team B');
      expect(tester.widget<LinnCheckbox>(checkbox).value, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
