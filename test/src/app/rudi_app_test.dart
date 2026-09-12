import 'package:flutter/foundation.dart';
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
}
