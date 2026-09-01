import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui_preview/main.dart';

void main() {
  testWidgets('preview fits a narrow window and exposes the overview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const RudiPreviewApp());

    expect(find.text('RUDI'), findsOneWidget);
    expect(find.text('A calmer way to\nbuild Flutter.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preview uses the wide two-column composition', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const RudiPreviewApp());

    final navigation = tester.getTopLeft(find.text('Floating navigation'));
    final progress = tester.getTopLeft(find.text('Progress with intent'));
    expect((navigation.dy - progress.dy).abs(), lessThan(20));
    expect(navigation.dx, lessThan(progress.dx));
    expect(tester.takeException(), isNull);
  });

  testWidgets('preview exposes the bottom sheet example', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const RudiPreviewApp());
    await tester.drag(
      find.byKey(const ValueKey('component-catalog-scroll')),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    expect(find.text('A native Rudi surface'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
