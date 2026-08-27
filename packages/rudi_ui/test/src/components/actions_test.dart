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
    var confirmed = false;
    await tester.pumpWidget(
      _TestApp(
        child: RudiHoldToConfirm(
          label: 'Hold',
          duration: const Duration(milliseconds: 300),
          onConfirmed: () => confirmed = true,
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Hold')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await gesture.up();

    expect(confirmed, isTrue);
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
