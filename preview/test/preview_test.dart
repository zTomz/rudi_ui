import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui_preview/main.dart';

void main() {
  testWidgets('component lab fits a narrow window and changes theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const RudiPreviewApp());

    expect(find.text('RUDI / LAB'), findsOneWidget);
    expect(find.text('One system.\nEvery Flutter surface.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byKey(const ValueKey('component-catalog-scroll')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use dark theme').hitTestable());
    await tester.pumpAndSettle();

    expect(find.text('Use light theme'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('component lab uses the wide two-column composition', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const RudiPreviewApp());

    final actions = tester.getTopLeft(find.text('Clear by default'));
    final typography = tester.getTopLeft(find.text('Roles, not font files'));
    expect((actions.dy - typography.dy).abs(), lessThan(20));
    expect(actions.dx, lessThan(typography.dx));
    expect(tester.takeException(), isNull);
  });
}
