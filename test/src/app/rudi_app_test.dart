import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() {
  testWidgets('uses stretch instead of glow for Android overscroll', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      await tester.pumpWidget(
        RudiApp(home: ListView(children: const [SizedBox(height: 1200)])),
      );

      expect(find.byType(StretchingOverscrollIndicator), findsOneWidget);
      expect(find.byType(GlowingOverscrollIndicator), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('high contrast preserves a custom consumer palette', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(highContrast: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final custom = RudiThemeData.light().copyWith(
      colors: RudiThemeData.light().colors.copyWith(
        background: const Color(0xFF123456),
      ),
    );

    await tester.pumpWidget(
      RudiApp(
        theme: custom,
        home: const Text('Custom', textDirection: TextDirection.ltr),
      ),
    );

    final active = RudiTheme.of(tester.element(find.text('Custom')));
    expect(active.colors.background, const Color(0xFF123456));
    expect(active.highContrast, isTrue);
  });

  testWidgets('uses an explicit high-contrast theme when supplied', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(highContrast: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final highContrast = RudiThemeData.light().copyWith(
      colors: RudiThemeData.light().colors.copyWith(
        background: const Color(0xFF654321),
      ),
      highContrast: true,
    );

    await tester.pumpWidget(
      RudiApp(
        theme: RudiThemeData.light(),
        highContrastTheme: highContrast,
        home: const Text('Explicit', textDirection: TextDirection.ltr),
      ),
    );

    expect(RudiTheme.of(tester.element(find.text('Explicit'))), highContrast);
  });

  testWidgets('uses transparent system bars without a navigation scrim', (
    tester,
  ) async {
    await tester.pumpWidget(
      const RudiApp(
        themeMode: RudiThemeMode.dark,
        home: Text('System UI', textDirection: TextDirection.ltr),
      ),
    );

    final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
    );
    expect(region.value.statusBarColor, const Color(0x00000000));
    expect(region.value.systemNavigationBarColor, const Color(0x00000000));
    expect(
      region.value.systemNavigationBarDividerColor,
      const Color(0x00000000),
    );
    expect(region.value.systemNavigationBarContrastEnforced, isFalse);
    expect(region.value.statusBarIconBrightness, Brightness.light);
    expect(region.value.systemNavigationBarIconBrightness, Brightness.light);
  });

  testWidgets('RudiPage respects safe areas by default', (tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const RudiApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(400, 600),
            padding: EdgeInsets.only(top: 30, bottom: 20),
          ),
          child: RudiPage(
            padding: EdgeInsets.zero,
            child: SizedBox.expand(key: ValueKey('page-content')),
          ),
        ),
      ),
    );

    final rect = tester.getRect(find.byKey(const ValueKey('page-content')));
    expect(rect, const Rect.fromLTWH(0, 30, 400, 550));
  });

  testWidgets('RudiPage can extend through top and bottom safe areas', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const RudiApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(400, 600),
            padding: EdgeInsets.only(top: 30, bottom: 20),
          ),
          child: RudiPage(
            padding: EdgeInsets.zero,
            safeAreaTop: false,
            safeAreaBottom: false,
            child: SizedBox.expand(key: ValueKey('page-content')),
          ),
        ),
      ),
    );

    final rect = tester.getRect(find.byKey(const ValueKey('page-content')));
    expect(rect, const Rect.fromLTWH(0, 0, 400, 600));
  });

  testWidgets('RudiAppBar owns the top safe area and exposes its slots', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const background = Color(0xFF123456);
    await tester.pumpWidget(
      const RudiApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(400, 600),
            padding: EdgeInsets.only(top: 30),
          ),
          child: Column(
            children: [
              RudiAppBar(
                height: 56,
                backgroundColor: background,
                leading: Text('Back'),
                title: Text('Timer'),
                trailing: Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(RudiAppBar)).height, 86);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Timer'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(
      tester
          .widget<ColoredBox>(
            find.descendant(
              of: find.byType(RudiAppBar),
              matching: find.byType(ColoredBox),
            ),
          )
          .color,
      background,
    );
  });

  testWidgets('RudiBackButton pops by default', (tester) async {
    await tester.pumpWidget(
      RudiApp(
        home: Builder(
          builder: (context) => RudiButton(
            label: 'Open',
            onPressed: () => Navigator.of(context).push(
              PageRouteBuilder<void>(
                pageBuilder: (_, _, _) => RudiAppBar.back(
                  backButtonSemanticLabel: 'Back',
                  title: Text('Details'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('RudiAppBar.back delegates cleanup to its callback', (
    tester,
  ) async {
    var cleanupCalls = 0;
    await tester.pumpWidget(
      RudiApp(
        home: RudiAppBar.back(
          backButtonSemanticLabel: 'Back',
          onBack: () => cleanupCalls++,
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Back'));
    expect(cleanupCalls, 1);
  });
}
