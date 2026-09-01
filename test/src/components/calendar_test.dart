import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() {
  testWidgets('calendar swipes between months and keeps full day targets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final months = <DateTime>[];
    final pressed = <DateTime>[];

    await tester.pumpWidget(
      _CalendarHarness(onMonthChanged: months.add, onDayPressed: pressed.add),
    );
    await tester.pumpAndSettle();

    final currentDay = find.byKey(
      const ValueKey('rudi-calendar-day-2026-9-20'),
    );
    expect(tester.getSize(currentDay).width, greaterThan(34));
    expect(tester.getSize(currentDay).height, greaterThan(40));
    final currentText = tester.widget<Text>(
      find.descendant(of: currentDay, matching: find.text('20')),
    );
    expect(
      currentText.style?.color,
      RudiTheme.of(tester.element(currentDay)).colors.accent,
    );

    await tester.drag(
      find.byKey(const ValueKey('rudi-calendar-pages')),
      const Offset(280, 0),
    );
    await tester.pumpAndSettle();
    expect(months.single, DateTime(2026, 8));
    await tester.tap(find.bySemanticsLabel('Next month'));
    await tester.pumpAndSettle();
    expect(months.last, DateTime(2026, 9));

    await tester.tap(currentDay);
    expect(pressed.single, DateTime(2026, 9, 20));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'completed and in-progress days use indicators below the number',
    (tester) async {
      await tester.pumpWidget(const _CalendarHarness());
      await tester.pumpAndSettle();

      for (final day in [8, 14]) {
        final cell = find.byKey(ValueKey('rudi-calendar-day-2026-9-$day'));
        final number = tester.getRect(
          find.descendant(of: cell, matching: find.text('$day')),
        );
        final marks = find.descendant(
          of: cell,
          matching: find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.height == 4,
          ),
        );
        expect(marks, findsWidgets);
        expect(tester.getTopLeft(marks.last).dy, greaterThan(number.bottom));
        final accent = RudiTheme.of(tester.element(cell)).colors.accent;
        final accentDot = find.descendant(
          of: cell,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).shape == BoxShape.circle &&
                (widget.decoration as BoxDecoration).color == accent,
          ),
        );
        expect(accentDot, findsOneWidget);
        expect(
          find.descendant(of: cell, matching: find.byType(RudiGlyph)),
          findsNothing,
        );
      }
    },
  );
}

final class _CalendarHarness extends StatelessWidget {
  const _CalendarHarness({this.onMonthChanged, this.onDayPressed});

  final ValueChanged<DateTime>? onMonthChanged;
  final ValueChanged<DateTime>? onDayPressed;

  @override
  Widget build(BuildContext context) => RudiApp(
    home: Center(
      child: SizedBox(
        width: 320,
        child: RudiCalendar(
          initialMonth: DateTime(2026, 9),
          firstMonth: DateTime(2026, 8),
          lastMonth: DateTime(2026, 9),
          today: DateTime(2026, 9, 20),
          weekdayLabels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
          monthLabelBuilder: (month) => '${month.month}/${month.year}',
          dayStateBuilder: (day) => switch (day.day) {
            8 => RudiCalendarDayState.completed,
            14 => RudiCalendarDayState.inProgress,
            _ when day.isAfter(DateTime(2026, 9, 20)) =>
              RudiCalendarDayState.unavailable,
            _ => RudiCalendarDayState.available,
          },
          daySemanticLabelBuilder: (day, state) => '${day.day}, ${state.name}',
          previousMonthSemanticLabel: 'Previous month',
          nextMonthSemanticLabel: 'Next month',
          onMonthChanged: onMonthChanged,
          onDayPressed: onDayPressed,
          gridHeight: 288,
        ),
      ),
    ),
  );
}
