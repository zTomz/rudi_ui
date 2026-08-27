import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() {
  testWidgets('RudiMessenger queues and dismisses messages', (tester) async {
    final controller = RudiMessengerController();
    await tester.pumpWidget(
      RudiApp(
        home: RudiMessenger(
          controller: controller,
          child: const RudiPage(child: SizedBox.expand()),
        ),
      ),
    );

    controller
      ..show(const RudiSnack(message: 'First'))
      ..show(const RudiSnack(message: 'Second'));
    await tester.pump();
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsNothing);

    controller.hideCurrent();
    await tester.pump();
    expect(find.text('Second'), findsOneWidget);
  });

  testWidgets('dialog opens and can be dismissed through its action', (
    tester,
  ) async {
    await tester.pumpWidget(const _DialogTestApp());

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Dialog title'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Dialog title'), findsNothing);
  });

  testWidgets('bottom sheet opens and respects safe layout', (tester) async {
    await tester.pumpWidget(const _SheetTestApp());

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();
    expect(find.text('Sheet content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final class _DialogTestApp extends StatelessWidget {
  const _DialogTestApp();

  @override
  Widget build(BuildContext context) {
    return RudiApp(
      home: RudiPage(
        child: Builder(
          builder: (context) => RudiButton(
            label: 'Open',
            onPressed: () => showRudiDialog<void>(
              context: context,
              barrierLabel: 'Dismiss',
              builder: (dialogContext) => RudiDialog(
                title: const Text('Dialog title'),
                content: const Text('Dialog content'),
                actions: [
                  RudiButton(
                    label: 'Done',
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _SheetTestApp extends StatelessWidget {
  const _SheetTestApp();

  @override
  Widget build(BuildContext context) {
    return RudiApp(
      home: RudiPage(
        child: Builder(
          builder: (context) => RudiButton(
            label: 'Open sheet',
            onPressed: () => showRudiBottomSheet<void>(
              context: context,
              barrierLabel: 'Dismiss sheet',
              builder: (_) => const Text('Sheet content'),
            ),
          ),
        ),
      ),
    );
  }
}
