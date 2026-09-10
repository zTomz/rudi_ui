import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() {
  testWidgets('page automatically floats configured navigation over content', (
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
            padding: EdgeInsets.only(bottom: 24),
          ),
          child: RudiPage(
            padding: EdgeInsets.zero,
            navigation: SizedBox(
              key: ValueKey('navigation'),
              width: 200,
              height: 68,
            ),
            child: SizedBox.expand(key: ValueKey('content')),
          ),
        ),
      ),
    );

    final content = tester.getRect(find.byKey(const ValueKey('content')));
    final navigation = tester.getRect(find.byKey(const ValueKey('navigation')));
    expect(content, const Rect.fromLTWH(0, 0, 400, 576));
    expect(navigation.center.dx, content.center.dx);
    expect(navigation.bottom, content.bottom - 16);
    expect(navigation.top, lessThan(content.bottom));
  });

  testWidgets('floating navigation changes the selected destination', (
    tester,
  ) async {
    var selectedIndex = 0;
    await tester.pumpWidget(
      RudiApp(
        home: Center(
          child: RudiFloatingNavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) => selectedIndex = value,
            destinations: const [
              RudiNavigationDestination(
                icon: RudiGlyph(RudiGlyphType.info),
                label: 'Overview',
              ),
              RudiNavigationDestination(
                icon: RudiGlyph(RudiGlyphType.chevron),
                label: 'Controls',
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('nav-1')));
    expect(selectedIndex, 1);
  });

  for (final brightness in Brightness.values) {
    testWidgets('floating navigation uses semantic colors in $brightness', (
      tester,
    ) async {
      final theme = brightness == Brightness.light
          ? RudiThemeData.light()
          : RudiThemeData.dark();
      await tester.pumpWidget(
        RudiApp(
          theme: theme,
          home: Center(
            child: RudiFloatingNavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              destinations: const [
                RudiNavigationDestination(
                  icon: RudiGlyph(RudiGlyphType.info),
                  label: 'Overview',
                ),
                RudiNavigationDestination(
                  icon: RudiGlyph(RudiGlyphType.chevron),
                  label: 'Controls',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final navigation = find.byType(RudiFloatingNavigationBar);
      final decorations = find.descendant(
        of: navigation,
        matching: find.byType(DecoratedBox),
      );
      final container = tester.widget<DecoratedBox>(decorations.at(0));
      final indicator = tester.widget<DecoratedBox>(decorations.at(1));
      expect(
        (container.decoration as BoxDecoration).color,
        theme.colors.primary,
      );
      expect(
        (container.decoration as BoxDecoration).boxShadow,
        brightness == Brightness.dark ? isEmpty : isNotEmpty,
      );
      expect(
        (indicator.decoration as BoxDecoration).color,
        theme.colors.background,
      );

      final icons = find.descendant(
        of: navigation,
        matching: find.byType(RudiGlyph),
      );
      expect(
        IconTheme.of(icons.evaluate().elementAt(0)).color,
        theme.colors.foreground,
      );
      expect(
        IconTheme.of(icons.evaluate().elementAt(1)).color,
        theme.colors.onPrimary,
      );
    });
  }
}
