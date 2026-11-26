import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnism_ui_concept_solar/linnism_ui_concept_solar.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: child,
    ),
  ),
);

LinnCalendarEvent _event(String title, DateTime start, DateTime end) =>
    LinnCalendarEvent(id: title, title: title, start: start, end: end);

void main() {
  testWidgets(
    'day grid displays overlapping events as tappable previews with no booking controls',
    (tester) async {
      final date = DateTime(2026, 11, 24);
      final events = [
        _event(
          'Riverside',
          DateTime(2026, 11, 24, 9, 30),
          DateTime(2026, 11, 24, 11),
        ),
        _event(
          'Hilltop',
          DateTime(2026, 11, 24, 9, 45),
          DateTime(2026, 11, 24, 10, 15),
        ),
      ];
      LinnCalendarEvent? opened;
      await tester.pumpWidget(
        _host(
          LinnCalendarView(
            focusedDate: date,
            events: events,
            mode: LinnCalendarMode.day,
            startHour: 9,
            endHour: 13,
            onEventPressed: (event) => opened = event,
          ),
        ),
      );
      expect(find.text('Riverside'), findsOneWidget);
      expect(find.text('Hilltop'), findsOneWidget);
      expect(find.text('Continues'), findsNWidgets(2));
      expect(find.byType(LinnScheduleSlot), findsNothing);
      await tester.tap(find.text('Hilltop'));
      expect(opened, same(events.last));
    },
  );

  testWidgets(
    'overnight events stay visible outside the default display hours',
    (tester) async {
      final overnight = _event(
        'Overnight service',
        DateTime(2026, 11, 23, 23),
        DateTime(2026, 11, 24, 1),
      );
      await tester.pumpWidget(
        _host(
          LinnCalendarView(
            focusedDate: DateTime(2026, 11, 24),
            events: [overnight],
            mode: LinnCalendarMode.day,
            startHour: 8,
            endHour: 9,
            slotMinutes: 45,
          ),
        ),
      );
      expect(find.text('Overnight service'), findsOneWidget);
      expect(find.byType(LinnScheduleSlot), findsNothing);
    },
  );

  testWidgets(
    'empty Week scrolls on a phone and navigates to the next period',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 760);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      DateTime? next;
      final date = DateTime(2026, 11, 24);
      await tester.pumpWidget(
        _host(
          LinnCalendarView(
            focusedDate: date,
            events: const [],
            startHour: 9,
            endHour: 10,
            onDateChanged: (day) => next = day,
          ),
        ),
      );
      expect(find.byType(Scrollbar), findsOneWidget);
      expect(find.byType(LinnScheduleSlot), findsNothing);
      await tester.tap(find.byTooltip('Next period'));
      expect(next, DateTime(2026, 12, 1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'month navigation clamps short months and selecting a date requests Day',
    (tester) async {
      DateTime? selected;
      LinnCalendarMode? mode;
      await tester.pumpWidget(
        _host(
          LinnCalendarView(
            focusedDate: DateTime(2028, 1, 31),
            events: const [],
            mode: LinnCalendarMode.month,
            onDateChanged: (day) => selected = day,
            onModeChanged: (value) => mode = value,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Next period'));
      expect(selected, DateTime(2028, 2, 29));
      await tester.tap(find.text('15'));
      expect(selected, DateTime(2028, 1, 15));
      expect(mode, LinnCalendarMode.day);
    },
  );

  testWidgets(
    'refresh keeps existing event details available and error offers retry',
    (tester) async {
      const states = [LinnState.loading, LinnState.error];
      var retries = 0;
      var opens = 0;
      final date = DateTime(2026, 11, 24);
      final events = [
        _event(
          'Riverside',
          DateTime(2026, 11, 24, 9),
          DateTime(2026, 11, 24, 10),
        ),
      ];
      for (final state in states) {
        await tester.pumpWidget(
          _host(
            LinnCalendarView(
              focusedDate: date,
              events: events,
              mode: LinnCalendarMode.day,
              state: state,
              startHour: 9,
              endHour: 11,
              onEventPressed: (_) => opens++,
              onRetry: () => retries++,
            ),
          ),
        );
        expect(find.text('Riverside'), findsOneWidget);
        await tester.tap(find.text('Riverside'));
      }
      expect(opens, 2);
      await tester.tap(find.text('Retry'));
      expect(retries, 1);
    },
  );

  testWidgets(
    'compact Month offers an event list and details without navigation callbacks',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 760);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final event = LinnCalendarEvent(
        id: 'site',
        title: 'Site visit',
        start: DateTime(2026, 11, 24, 9),
        end: DateTime(2026, 11, 24, 10),
        description: 'Bring the site checklist.',
      );
      await tester.pumpWidget(
        _host(
          LinnCalendarView(
            focusedDate: DateTime(2026, 11, 24),
            events: [event],
            mode: LinnCalendarMode.month,
          ),
        ),
      );
      expect(find.text('Site visit'), findsNothing);
      await tester.tap(find.text('24'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Site visit'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Site visit'));
      await tester.pumpAndSettle();
      expect(find.text('Bring the site checklist.'), findsOneWidget);
    },
  );
}
