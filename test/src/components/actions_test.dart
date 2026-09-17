import 'dart:ui' show Tristate;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() {
  testWidgets('RudiButton responds to pointer and keyboard activation', (
    tester,
  ) async {
    var activations = 0;
    await tester.pumpWidget(
      _TestApp(
        child: RudiButton(
          autofocus: true,
          label: 'Continue',
          onPressed: () => activations++,
        ),
      ),
    );

    await tester.tap(find.text('Continue'));
    expect(activations, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(activations, 2);
  });

  testWidgets('disabled RudiButton does not activate', (tester) async {
    await tester.pumpWidget(
      const _TestApp(child: RudiButton(label: 'Disabled', onPressed: null)),
    );

    await tester.tap(find.text('Disabled'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('RudiIconButton matches plain icon button geometry and states', (
    tester,
  ) async {
    final theme = RudiThemeData.light();
    await tester.pumpWidget(
      RudiApp(
        theme: theme,
        home: RudiPage(
          child: Center(
            child: RudiIconButton(
              icon: const Icon(IconData(0xe000)),
              semanticLabel: 'Add',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final button = find.byType(RudiIconButton);
    final visual = find.byKey(const ValueKey('rudi-icon-button-visual'));
    expect(tester.getSize(button), const Size.square(48));
    expect(tester.getSize(visual), const Size.square(40));
    final iconTheme = tester
        .widgetList<IconTheme>(
          find.descendant(of: button, matching: find.byType(IconTheme)),
        )
        .last;
    expect(iconTheme.data.color, theme.colors.foreground);
    expect(iconTheme.data.size, 24);

    var decoration = tester.widget<AnimatedContainer>(visual).decoration!;
    expect((decoration as BoxDecoration).color, const Color(0x00000000));

    final touch = await tester.startGesture(tester.getCenter(button));
    await tester.pump();
    decoration = tester.widget<AnimatedContainer>(visual).decoration!;
    expect(
      (decoration as BoxDecoration).color,
      theme.colors.foreground.withValues(alpha: .10),
    );
    await touch.up();
  });

  testWidgets('RudiButton expands on phones and caps its tablet width', (
    tester,
  ) async {
    Future<Size> pumpAt(double width, {double minHeight = 56}) async {
      await tester.pumpWidget(
        _TestApp(
          child: SizedBox(
            width: width,
            child: RudiButton(
              key: const ValueKey('responsive-button'),
              label: 'Continue',
              minHeight: minHeight,
              onPressed: () {},
            ),
          ),
        ),
      );
      return tester.getSize(
        find.descendant(
          of: find.byKey(const ValueKey('responsive-button')),
          matching: find.byType(RudiPressable),
        ),
      );
    }

    expect(await pumpAt(360), const Size(360, 56));
    expect(await pumpAt(900), const Size(560, 56));
    expect(await pumpAt(360, minHeight: 72), const Size(360, 72));
  });

  testWidgets('RudiPressable supports a long-press-only action', (
    tester,
  ) async {
    var longPresses = 0;
    await tester.pumpWidget(
      _TestApp(
        child: RudiPressable(
          onLongPress: () => longPresses++,
          builder: (context, state) => const SizedBox(
            key: ValueKey('long-press-only'),
            width: 80,
            height: 80,
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('long-press-only'))),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await gesture.up();

    expect(longPresses, 1);
  });

  testWidgets('RudiPressable honors its explicit enabled state', (
    tester,
  ) async {
    var activations = 0;
    await tester.pumpWidget(
      _TestApp(
        child: RudiPressable(
          enabled: false,
          onPressed: () => activations++,
          child: const SizedBox(
            key: ValueKey('disabled-pressable'),
            width: 80,
            height: 80,
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('disabled-pressable')),
      warnIfMissed: false,
    );

    expect(activations, 0);
    final semantics = tester.getSemantics(
      find.byKey(const ValueKey('disabled-pressable')),
    );
    expect(semantics.flagsCollection.isEnabled, Tristate.isFalse);
  });

  testWidgets('RudiPressable without callbacks is disabled', (tester) async {
    await tester.pumpWidget(
      const _TestApp(
        child: RudiPressable(
          child: SizedBox(
            key: ValueKey('passive-pressable'),
            width: 80,
            height: 80,
          ),
        ),
      ),
    );

    final semantics = tester.getSemantics(
      find.byKey(const ValueKey('passive-pressable')),
    );
    expect(semantics.flagsCollection.isEnabled, Tristate.isFalse);
  });

  testWidgets('RudiHoldToConfirm completes after configured duration', (
    tester,
  ) async {
    var confirmations = 0;
    await tester.pumpWidget(
      _TestApp(
        child: RudiHoldToConfirm(
          label: 'Hold',
          duration: const Duration(milliseconds: 300),
          onConfirmed: () => confirmations++,
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('hold-to-confirm-button'))),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await gesture.up();

    expect(confirmations, 1);
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const ValueKey('hold-to-confirm-fill'))).width,
      0,
    );

    final secondGesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('hold-to-confirm-button'))),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await secondGesture.up();
    await tester.pumpAndSettle();
    expect(confirmations, 2);
  });

  testWidgets('interaction controls preserve their established geometry', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RudiHoldToConfirm(
                label: 'Hold',
                icon: const RudiGlyph(RudiGlyphType.close),
                onConfirmed: () {},
              ),
              const SizedBox(height: 16),
              RudiSwipeAction(
                label: 'Swipe',
                thumb: const RudiGlyph(RudiGlyphType.chevron),
                onConfirmed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('hold-to-confirm-button'))),
      const Size(360, 56),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('swipe-thumb'))),
      const Size(56, 56),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('swipe-thumb-fade'))),
      const Size(56, 56),
    );
    expect(tester.getSize(find.byType(RudiSwipeAction)), const Size(360, 72));
  });

  testWidgets('RudiSwipeAction completes only at the configured end', (
    tester,
  ) async {
    var confirmations = 0;
    await tester.pumpWidget(
      _TestApp(
        child: SizedBox(
          width: 360,
          child: RudiSwipeAction(
            label: 'Swipe',
            thumb: const RudiGlyph(RudiGlyphType.chevron),
            onConfirmed: () => confirmations++,
          ),
        ),
      ),
    );

    final thumb = find.byKey(const ValueKey('swipe-thumb'));
    final initialThumbLeft = tester.getTopLeft(thumb).dx;
    final partial = await tester.startGesture(tester.getCenter(thumb));
    await partial.moveBy(const Offset(180, 0));
    await partial.up();
    await tester.pumpAndSettle();
    expect(confirmations, 0);

    final complete = await tester.startGesture(tester.getCenter(thumb));
    await complete.moveBy(const Offset(300, 0));
    await complete.up();
    await tester.pumpAndSettle();
    expect(confirmations, 1);
    expect(tester.getTopLeft(thumb).dx, initialThumbLeft);

    final secondComplete = await tester.startGesture(tester.getCenter(thumb));
    await secondComplete.moveBy(const Offset(300, 0));
    await secondComplete.up();
    await tester.pumpAndSettle();
    expect(confirmations, 2);
  });

  testWidgets('RudiSwipeAction follows the theme haptic policy', (
    tester,
  ) async {
    var pulses = 0;
    var hapticCompletions = 0;
    var confirmations = 0;

    Future<void> pumpAction(RudiFeedbackPolicy feedback) async {
      await tester.pumpWidget(
        _TestApp(
          feedback: feedback,
          child: SizedBox(
            width: 360,
            child: RudiSwipeAction(
              key: ValueKey(feedback.hapticsEnabled),
              label: 'Swipe',
              thumb: const RudiGlyph(RudiGlyphType.chevron),
              onConfirmed: () => confirmations++,
              onHapticPulse: (_) => pulses++,
              onHapticCompleted: () => hapticCompletions++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpAction(RudiFeedbackPolicy.silent);
    var gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('swipe-thumb'))),
    );
    await gesture.moveBy(const Offset(300, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect((pulses, hapticCompletions, confirmations), (0, 0, 1));

    await pumpAction(
      const RudiFeedbackPolicy(hapticsEnabled: true, soundsEnabled: false),
    );
    gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('swipe-thumb'))),
    );
    await gesture.moveBy(const Offset(300, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(pulses, greaterThan(0));
    expect(hapticCompletions, 1);
    expect(confirmations, 2);
  });
}

final class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.child,
    this.feedback = RudiFeedbackPolicy.silent,
  });

  final Widget child;
  final RudiFeedbackPolicy feedback;

  @override
  Widget build(BuildContext context) {
    return RudiApp(
      theme: RudiThemeData.light(feedback: feedback),
      home: RudiPage(child: Center(child: child)),
    );
  }
}
