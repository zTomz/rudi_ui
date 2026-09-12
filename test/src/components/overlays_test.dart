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

  testWidgets('RudiSnack uses the shared responsive Loop geometry', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 700);
    addTearDown(tester.view.reset);
    final controller = RudiMessengerController();

    await tester.pumpWidget(
      RudiApp(
        home: RudiMessenger(
          controller: controller,
          child: const RudiPage(child: SizedBox.expand()),
        ),
      ),
    );
    controller.show(
      const RudiSnack(
        message: 'Saved everywhere',
        icon: RudiGlyph(RudiGlyphType.check),
        maxLines: null,
      ),
    );
    await tester.pump();

    final theme = RudiTheme.of(tester.element(find.text('Saved everywhere')));
    final snackSurface = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).color == theme.colors.primary &&
          (widget.decoration! as BoxDecoration).borderRadius ==
              BorderRadius.circular(theme.radii.pill),
    );
    final iconChip = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
    );
    final message = tester.widget<Text>(find.text('Saved everywhere'));

    expect(tester.getSize(snackSurface).width, 560);
    expect(tester.getSize(iconChip), const Size.square(32));
    expect(message.maxLines, isNull);
    expect(message.overflow, TextOverflow.visible);
    expect(message.style?.color, theme.colors.onPrimary);
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
              builder: (_) => const RudiBottomSheet(
                title: Text('Sheet'),
                children: [Text('Sheet content')],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
