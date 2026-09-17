import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() {
  testWidgets('passive tooltip preserves tap and opens on long press', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      RudiApp(
        home: RudiPage(
          child: RudiTooltip(
            message: 'Add time',
            child: RudiIconButton(
              semanticLabel: 'Add time',
              onPressed: () => taps++,
              icon: const Text('+'),
            ),
          ),
        ),
      ),
    );

    final semantics = tester.ensureSemantics();
    await tester.pump();
    expect(find.bySemanticsLabel('Add time'), findsOneWidget);

    await tester.tap(find.byType(RudiIconButton));
    expect(taps, 1);
    expect(find.text('Add time'), findsNothing);

    await tester.longPress(find.byType(RudiIconButton));
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(find.text('Add time'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('passive tooltip can be refreshed and reopened', (tester) async {
    await tester.pumpWidget(
      RudiApp(
        home: RudiPage(
          child: RudiTooltip(
            message: 'Add time',
            showDuration: const Duration(seconds: 2),
            child: RudiIconButton(
              semanticLabel: 'Add time',
              onPressed: () {},
              icon: const Text('+'),
            ),
          ),
        ),
      ),
    );

    final trigger = find.byType(RudiIconButton);
    await tester.longPress(trigger);
    await tester.pumpAndSettle();
    expect(find.text('Add time'), findsOneWidget);

    await tester.longPress(trigger);
    await tester.pumpAndSettle();
    expect(find.text('Add time'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Add time'), findsNothing);

    await tester.longPress(trigger);
    await tester.pumpAndSettle();
    expect(find.text('Add time'), findsOneWidget);
  });

  testWidgets('passive tooltip gives selection feedback on long press', (
    tester,
  ) async {
    final platformCalls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      platformCalls.add(call);
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await tester.pumpWidget(
      RudiApp(
        theme: RudiThemeData.light(
          feedback: const RudiFeedbackPolicy(
            hapticsEnabled: true,
            soundsEnabled: false,
          ),
        ),
        home: RudiPage(
          child: RudiTooltip(
            message: 'Add time',
            child: RudiIconButton(
              semanticLabel: 'Add time',
              onPressed: () {},
              icon: const Text('+'),
            ),
          ),
        ),
      ),
    );

    await tester.longPress(find.byType(RudiIconButton));
    await tester.pumpAndSettle();

    expect(
      platformCalls,
      anyElement(
        isA<MethodCall>()
            .having((call) => call.method, 'method', 'HapticFeedback.vibrate')
            .having(
              (call) => call.arguments,
              'arguments',
              'HapticFeedbackType.selectionClick',
            ),
      ),
    );
  });

  testWidgets('information tooltip opens, stays anchored and dismisses', (
    tester,
  ) async {
    await tester.pumpWidget(
      const RudiApp(
        home: RudiPage(
          child: Align(
            alignment: Alignment.centerRight,
            child: RudiInfoTooltip(
              semanticLabel: 'Explain input mode',
              message: 'Choose a number, then tap cells to place it.',
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Choose a number, then tap cells to place it.'),
      findsNothing,
    );
    expect(
      tester.widget<RudiInfoTooltip>(find.byType(RudiInfoTooltip)).duration,
      const Duration(seconds: 2),
    );
    await tester.tap(find.bySemanticsLabel('Explain input mode'));
    await tester.pump();
    expect(
      find.text('Choose a number, then tap cells to place it.'),
      findsOneWidget,
    );
    final scale = tester.widget<ScaleTransition>(
      find.ancestor(
        of: find.text('Choose a number, then tap cells to place it.'),
        matching: find.byType(ScaleTransition),
      ),
    );
    expect(scale.alignment, Alignment.bottomRight);
    expect(scale.scale.value, lessThan(1));
    await tester.pumpAndSettle();
    final tooltipRect = tester.getRect(
      find.text('Choose a number, then tap cells to place it.'),
    );
    final triggerRect = tester.getRect(
      find.bySemanticsLabel('Explain input mode'),
    );
    expect(tooltipRect.left, greaterThanOrEqualTo(16));
    expect(tooltipRect.right, lessThanOrEqualTo(784));
    expect(tooltipRect.bottom, lessThan(triggerRect.top));
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(
      find.text('Choose a number, then tap cells to place it.'),
      findsNothing,
    );

    await tester.tap(find.bySemanticsLabel('Explain input mode'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(1, 1));
    await tester.pump();
    expect(
      find.text('Choose a number, then tap cells to place it.'),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Choose a number, then tap cells to place it.'),
      findsNothing,
    );
  });

  testWidgets('passive tooltip stays centered above its trigger', (
    tester,
  ) async {
    await tester.pumpWidget(
      RudiApp(
        home: RudiPage(
          padding: EdgeInsets.zero,
          child: Align(
            alignment: const Alignment(-.75, 0),
            child: RudiTooltip(
              message: 'Add 10 seconds',
              child: RudiIconButton(
                key: const ValueKey('add-time'),
                semanticLabel: 'Add 10 seconds',
                onPressed: () {},
                icon: const Text('+10'),
              ),
            ),
          ),
        ),
      ),
    );

    final trigger = find.byKey(const ValueKey('add-time'));
    await tester.longPress(trigger);
    await tester.pumpAndSettle();
    final tooltipRect = tester.getRect(find.text('Add 10 seconds'));
    final triggerRect = tester.getRect(trigger);
    expect(tooltipRect.center.dx, closeTo(triggerRect.center.dx, .01));
    expect(tooltipRect.bottom, lessThan(triggerRect.top));
  });

  testWidgets('supporting tooltip suppresses the switch row ripple', (
    tester,
  ) async {
    var value = false;
    await tester.pumpWidget(
      RudiApp(
        home: RudiSettingsGroup(
          children: [
            RudiSwitchTile(
              title: 'Clean up notes',
              value: value,
              onChanged: (next) => value = next,
              supporting: const RudiInfoTooltip(
                key: ValueKey('info'),
                semanticLabel: 'Explain clean up notes',
                message: 'Removes matching notes.',
              ),
            ),
          ],
        ),
      ),
    );

    final tile = tester.widget<RudiSettingsTile>(
      find.ancestor(
        of: find.byKey(const ValueKey('info')),
        matching: find.byType(RudiSettingsTile),
      ),
    );
    expect(tile.ink, false);
    final switchIndicator = find.byWidgetPredicate(
      (widget) =>
          widget is AnimatedContainer &&
          widget.constraints?.maxWidth == 50 &&
          widget.constraints?.maxHeight == 30,
    );
    expect(
      tester.getCenter(find.byKey(const ValueKey('info'))).dx,
      lessThan(tester.getCenter(switchIndicator).dx),
    );
    await tester.tap(find.byKey(const ValueKey('info')));
    await tester.pumpAndSettle();
    expect(value, false);
    expect(find.text('Removes matching notes.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
