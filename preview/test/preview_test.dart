import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:rudi_ui_preview/main.dart';

void main() {
  testWidgets('catalog fits a narrow window and exposes the overview', (
    tester,
  ) async {
    await _setSurface(tester, const Size(390, 844));

    await tester.pumpWidget(const RudiPreviewApp());

    expect(find.text('COMPONENT LAB'), findsOneWidget);
    expect(find.text('Calm surfaces.\nComplete behavior.'), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide catalog uses a persistent component sidebar', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1280, 900));

    await tester.pumpWidget(const RudiPreviewApp());

    final brand = tester.getTopLeft(find.text('RUDI'));
    final content = tester.getTopLeft(
      find.text('Calm surfaces.\nComplete behavior.'),
    );
    expect(brand.dx, lessThan(content.dx));
    expect(find.text('CATALOG'), findsOneWidget);
    expect(find.text('Overlays'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tooltip catalog example responds to pointer hover', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1280, 900));
    await tester.pumpWidget(const RudiPreviewApp());

    await tester.tap(find.byKey(const ValueKey('nav-6')));
    await tester.pumpAndSettle();
    expect(find.byType(RudiTooltip), findsOneWidget);

    final trigger = find.bySemanticsLabel('Add component');
    final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(pointer.removePointer);
    await pointer.addPointer(location: tester.getCenter(trigger));
    await pointer.moveTo(tester.getCenter(trigger));
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.text('Add this component to your workspace'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('overlay catalog opens the bottom sheet example', (tester) async {
    await _setSurface(tester, const Size(1280, 900));
    await tester.pumpWidget(const RudiPreviewApp());

    await tester.tap(find.byKey(const ValueKey('nav-6')));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('component-catalog-scroll')),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Preview options'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('feedback catalog previews stacked snackbar variants', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1280, 900));
    await tester.pumpWidget(const RudiPreviewApp());

    await tester.tap(find.byKey(const ValueKey('nav-5')));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.ensureVisible(find.text('Stack'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('Stack'));
    await tester.pump();

    expect(find.text('Preparing backup…'), findsOneWidget);
    expect(find.text('Uploading changes…'), findsOneWidget);
    expect(find.text('One file could not be uploaded.'), findsOneWidget);

    final preparingBeforeSwipe = tester
        .getTopLeft(find.text('Preparing backup…'))
        .dy;
    await tester.drag(
      find.text('One file could not be uploaded.'),
      const Offset(0, 300),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      (tester.getTopLeft(find.text('Preparing backup…')).dy -
              preparingBeforeSwipe)
          .abs(),
      lessThan(64),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('One file could not be uploaded.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('calendar is an interactive catalog destination', (tester) async {
    await _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(const RudiPreviewApp());

    final destination = find.byKey(const ValueKey('nav-7'));
    await tester.ensureVisible(destination);
    await tester.tap(destination);
    await tester.pumpAndSettle();

    expect(find.text('Calendar'), findsWidgets);
    expect(find.text('Interactive month'), findsOneWidget);
    expect(find.byType(RudiCalendar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
