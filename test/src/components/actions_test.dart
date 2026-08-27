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

  testWidgets('Loop interaction controls preserve their original geometry', (
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
}

final class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RudiApp(
      theme: RudiThemeData.light(feedback: RudiFeedbackPolicy.silent),
      home: RudiPage(child: Center(child: child)),
    );
  }
}
