import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() {
  testWidgets('RudiMessenger layers messages and swipes away the newest', (
    tester,
  ) async {
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
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    final verticalOffset =
        tester.getTopLeft(find.text('Second')).dy -
        tester.getTopLeft(find.text('First')).dy;
    expect(verticalOffset, greaterThan(8));
    expect(verticalOffset, lessThan(32));

    await tester.drag(find.text('Second'), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsOneWidget);

    final firstBeforeDismiss = tester.getTopLeft(find.text('First')).dy;
    final downSwipe = await tester.startGesture(
      tester.getCenter(find.text('Second')),
    );
    await downSwipe.moveBy(const Offset(0, 300));
    await downSwipe.up();
    await tester.pump(const Duration(milliseconds: 200));
    final promotionStart = tester.getTopLeft(find.text('First')).dy;
    await tester.pump(const Duration(milliseconds: 40));
    final promotionMiddle = tester.getTopLeft(find.text('First')).dy;
    await tester.pump(const Duration(milliseconds: 200));
    final promotionEnd = tester.getTopLeft(find.text('First')).dy;

    expect(promotionStart, lessThan(promotionMiddle));
    expect(promotionMiddle, lessThan(promotionEnd));
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsNothing);
    expect(promotionEnd - firstBeforeDismiss, inInclusiveRange(8, 32));
  });

  testWidgets('RudiMessenger reveals unexpired messages behind visible stack', (
    tester,
  ) async {
    final controller = RudiMessengerController();
    await tester.pumpWidget(
      RudiApp(
        home: RudiMessenger(
          controller: controller,
          child: const RudiPage(child: SizedBox.expand()),
        ),
      ),
    );

    for (var index = 0; index < 6; index++) {
      controller.show(
        RudiSnack(
          message: 'Message $index',
          duration: const Duration(minutes: 1),
        ),
      );
    }
    await tester.pump();

    for (var index = 0; index < 2; index++) {
      expect(find.text('Message $index'), findsNothing);
    }
    for (var index = 2; index < 6; index++) {
      expect(find.text('Message $index'), findsOneWidget);
    }
    expect(find.byType(Dismissible), findsNWidgets(4));

    await tester.drag(find.text('Message 5'), const Offset(0, 300));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Message 1'), findsOneWidget);
    expect(find.text('Message 5'), findsNothing);

    controller.hideCurrent();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Message 0'), findsOneWidget);
    expect(find.text('Message 4'), findsNothing);
    expect(find.byType(Dismissible), findsNWidgets(4));
  });

  testWidgets('hidden messages expire without returning to the stack', (
    tester,
  ) async {
    final controller = RudiMessengerController();
    await tester.pumpWidget(
      RudiApp(
        home: RudiMessenger(
          controller: controller,
          maxVisibleSnacks: 2,
          child: const RudiPage(child: SizedBox.expand()),
        ),
      ),
    );

    controller
      ..show(
        const RudiSnack(
          message: 'Expired while hidden',
          duration: Duration(milliseconds: 300),
        ),
      )
      ..show(const RudiSnack(message: 'Second', duration: Duration(minutes: 1)))
      ..show(const RudiSnack(message: 'Third', duration: Duration(minutes: 1)));
    await tester.pump();
    expect(find.text('Expired while hidden'), findsNothing);

    await tester.pump(const Duration(milliseconds: 300));
    controller.hideCurrent();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Third'), findsNothing);
    expect(find.text('Second'), findsOneWidget);
    expect(find.text('Expired while hidden'), findsNothing);

    controller.hideCurrent();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(Dismissible), findsNothing);
  });

  testWidgets('stacked messages keep independent durations', (tester) async {
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
      ..show(
        const RudiSnack(
          message: 'Short',
          duration: Duration(milliseconds: 500),
        ),
      )
      ..show(const RudiSnack(message: 'Long', duration: Duration(seconds: 2)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Short'), findsNothing);
    expect(find.text('Long'), findsOneWidget);

    controller.clear();
    await tester.pump();
    expect(find.text('Long'), findsNothing);
  });

  test('RudiSnack named constructors select semantic variants and icons', () {
    const info = RudiSnack.info(message: 'Info');
    const error = RudiSnack.error(message: 'Error');
    const debug = RudiSnack.debug(message: 'Debug');

    expect(info.variant, RudiSnackVariant.info);
    expect((info.icon! as RudiGlyph).type, RudiGlyphType.info);
    expect(error.variant, RudiSnackVariant.error);
    expect((error.icon! as RudiGlyph).type, RudiGlyphType.error);
    expect(debug.variant, RudiSnackVariant.debug);
    expect(debug.icon, isNull);
  });

  testWidgets('RudiSnack semantic variants use their theme colors', (
    tester,
  ) async {
    final controller = RudiMessengerController();
    await tester.pumpWidget(
      RudiApp(
        home: RudiMessenger(
          controller: controller,
          child: const RudiPage(child: SizedBox.expand()),
        ),
      ),
    );

    controller.show(const RudiSnack.error(message: 'Failed'));
    await tester.pump();

    final theme = RudiTheme.of(tester.element(find.text('Failed')));
    final snackSurface = tester.widget<Container>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).gradient is LinearGradient,
      ),
    );
    final decoration = snackSurface.decoration! as BoxDecoration;
    expect(
      (decoration.gradient! as LinearGradient).colors.first,
      Color.lerp(const Color(0xFF12151A), theme.colors.error, .16),
    );
  });

  testWidgets('RudiSnack uses the shared responsive Loop geometry', (
    tester,
  ) async {
    const snackAccent = Color(0xFFE15252);
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
        accentColor: snackAccent,
        actionLabel: 'Retry',
        maxLines: null,
      ),
    );
    await tester.pump();

    final theme = RudiTheme.of(tester.element(find.text('Saved everywhere')));
    final snackSurface = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).gradient is LinearGradient &&
          (widget.decoration! as BoxDecoration).borderRadius ==
              BorderRadius.circular(theme.radii.pill),
    );
    final iconSlot = find.byWidgetPredicate(
      (widget) =>
          widget is SizedBox && widget.width == 32 && widget.height == 32,
    );
    final message = tester.widget<Text>(find.text('Saved everywhere'));

    expect(tester.getSize(snackSurface).width, 560);
    expect(tester.getSize(iconSlot), const Size.square(32));
    expect(
      find.descendant(of: iconSlot, matching: find.byType(Transform)),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: snackSurface,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
        ),
      ),
      findsNothing,
    );
    expect(message.maxLines, isNull);
    expect(message.overflow, TextOverflow.visible);
    expect(message.style?.color, theme.colors.onPrimary);
    expect(
      find.descendant(of: snackSurface, matching: find.byType(CustomPaint)),
      findsWidgets,
    );

    final surface = tester.widget<Container>(snackSurface);
    final decoration = surface.decoration! as BoxDecoration;
    final foregroundDecoration = surface.foregroundDecoration! as BoxDecoration;
    expect(decoration.color, isNull);
    expect(
      (decoration.gradient! as LinearGradient).colors.last,
      const Color(0xFF171A1F),
    );
    expect(
      (decoration.gradient! as LinearGradient).colors.first,
      Color.lerp(const Color(0xFF12151A), snackAccent, .16),
    );
    expect(
      (foregroundDecoration.border! as Border).top.color,
      snackAccent.withValues(alpha: .46),
    );
    expect(tester.widget<Text>(find.text('Retry')).style?.color, snackAccent);
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
