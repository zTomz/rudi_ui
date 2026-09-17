import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('selected settings contrast in $brightness', (tester) async {
      final theme = brightness == Brightness.light
          ? RudiThemeData.light()
          : RudiThemeData.dark();
      await tester.pumpWidget(
        RudiApp(
          theme: theme,
          home: RudiSettingsGroup(
            children: [
              RudiSettingsTile(
                title: 'Selected',
                subtitle: 'Description',
                selected: true,
                leading: const RudiGlyph(RudiGlyphType.info),
                trailing: const RudiGlyph(RudiGlyphType.check),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      final tile = find.byType(RudiSettingsTile);
      final container = tester.widget<AnimatedContainer>(
        find
            .descendant(of: tile, matching: find.byType(AnimatedContainer))
            .first,
      );
      expect(
        (container.decoration! as BoxDecoration).color,
        theme.colors.foreground,
      );
      expect(
        tester.widget<Text>(find.text('Selected')).style!.color,
        theme.colors.background,
      );
      expect(
        tester.widget<Text>(find.text('Description')).style!.color,
        theme.colors.background.withValues(alpha: .67),
      );
      for (final element in find.byType(RudiGlyph).evaluate()) {
        expect(IconTheme.of(element).color, theme.colors.background);
      }
      expect(
        tester.getSemantics(tile).getSemanticsData().flagsCollection.isSelected,
        Tristate.isTrue,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final reduced in [false, true]) {
    testWidgets(
      'settings ink paints, cancels and settles (reduced: $reduced)',
      (tester) async {
        var activations = 0;
        await tester.pumpWidget(
          RudiApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
              child: child!,
            ),
            home: Center(
              child: SizedBox(
                width: 320,
                child: RudiSettingsTile(
                  title: 'Ink option',
                  onPressed: () => activations++,
                ),
              ),
            ),
          ),
        );
        void paintInk(Canvas canvas) {
          final paint = tester.widget<CustomPaint>(
            find
                .descendant(
                  of: find.byType(RudiSettingsTile),
                  matching: find.byType(CustomPaint),
                )
                .first,
          );
          paint.foregroundPainter?.paint(canvas, const Size(320, 60));
        }

        expect(paintInk, paintsNothing);
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Ink option')),
        );
        await tester.pump(const Duration(milliseconds: 120));
        await tester.pump(const Duration(milliseconds: 80));
        expect(paintInk, reduced ? (paints..rect()) : (paints..circle()));
        await gesture.cancel();
        await tester.pumpAndSettle();
        expect(activations, 0);
        expect(paintInk, paintsNothing);
        await tester.tap(find.text('Ink option'));
        await tester.pumpAndSettle();
        expect(activations, 1);
        expect(paintInk, paintsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('settings rows grow for wrapped and scaled text', (tester) async {
    await tester.pumpWidget(
      RudiApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: const SizedBox(
            width: 320,
            child: RudiSettingsTile(
              title: 'Accessible setting',
              subtitle: 'Supporting text can wrap without being clipped.',
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(RudiSettingsTile)).height,
      greaterThan(64),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'sheet without close icon can dismiss by barrier and system back',
    (tester) async {
      await tester.pumpWidget(const _SheetHarness(showClose: false));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(RudiIconButton), findsNothing);
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      expect(find.text('Options'), findsNothing);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Options'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'floating selection reaches the last requested tab after rapid taps',
    (tester) async {
      for (final rtl in [false, true]) {
        await tester.pumpWidget(_NavigationHarness(rtl: rtl));
        for (final index in [3, 1, 2, 0, 3]) {
          await tester.tap(find.byKey(ValueKey('nav-$index')));
          await tester.pump(const Duration(milliseconds: 40));
        }
        await tester.pumpAndSettle();
        final target = tester.getCenter(find.byKey(const ValueKey('nav-3')));
        final selectedSurface = tester.getCenter(
          find.descendant(
            of: find.byKey(const ValueKey('nav-3')),
            matching: find.byType(AnimatedContainer),
          ),
        );
        expect(selectedSurface.dx, closeTo(target.dx, .1));
        expect(tester.takeException(), isNull);
      }
    },
  );
  for (final reduced in [false, true]) {
    testWidgets(
      'sheet drag cancellation and dismissal (reduced motion: $reduced)',
      (tester) async {
        await tester.pumpWidget(_SheetHarness(reduced: reduced));
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final title = find.text('Options');
        final before = tester.getTopLeft(title).dy;
        final gesture = await tester.startGesture(tester.getCenter(title));
        await gesture.moveBy(const Offset(0, 30));
        await gesture.cancel();
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(title).dy, closeTo(before, .1));
        await tester.drag(title, const Offset(0, 160));
        await tester.pumpAndSettle();
        expect(title, findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('sheet handles keyboard insets and long scrolling content', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const _SheetHarness(long: true));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Item 29'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('switch row is one toggle target with disabled behavior', (
    tester,
  ) async {
    var value = false;
    await tester.pumpWidget(
      RudiApp(
        home: RudiPage(
          child: StatefulBuilder(
            builder: (context, setState) => RudiSettingsGroup(
              children: [
                RudiSwitchTile(
                  title: 'Timer',
                  value: value,
                  onChanged: (next) => setState(() => value = next),
                ),
                const RudiSwitchTile(
                  title: 'Disabled',
                  value: false,
                  onChanged: null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Timer'));
    await tester.pumpAndSettle();
    expect(value, true);
    await tester.tap(find.text('Disabled'));
    await tester.pumpAndSettle();
    expect(value, true);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switch indicators can be dragged in both directions', (
    tester,
  ) async {
    var tileValue = false;
    var iconTileValue = false;
    await tester.pumpWidget(
      RudiApp(
        home: RudiPage(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                RudiSwitchTile(
                  title: 'Shortcut',
                  value: tileValue,
                  onChanged: (next) => setState(() => tileValue = next),
                ),
                RudiSettingsTile.switchTile(
                  icon: const IconData(0xe000),
                  label: 'Sound',
                  value: iconTileValue,
                  onChanged: (next) => setState(() => iconTileValue = next),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Future<void> dragSwitch(Finder tile, double delta) async {
      final control = find.descendant(
        of: tile,
        matching: find.byKey(const ValueKey('rudi-switch-control')),
      );
      await tester.timedDrag(
        control,
        Offset(delta, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();
    }

    await dragSwitch(find.byType(RudiSwitchTile), 40);
    expect(tileValue, isTrue);
    await dragSwitch(find.byType(RudiSwitchTile), -40);
    expect(tileValue, isFalse);

    final iconTile = find.widgetWithText(RudiSettingsTile, 'Sound');
    await dragSwitch(iconTile, 40);
    expect(iconTileValue, isTrue);
    await dragSwitch(iconTile, -40);
    expect(iconTileValue, isFalse);
  });

  testWidgets('icon settings rows expose Loop geometry and toggle semantics', (
    tester,
  ) async {
    var value = false;
    await tester.pumpWidget(
      RudiApp(
        home: RudiSettingsGroup(
          children: [
            RudiSettingsTile.switchTile(
              icon: const IconData(0xe000),
              label: 'Haptics',
              value: value,
              onChanged: (next) => value = next,
            ),
          ],
        ),
      ),
    );

    final tile = find.byType(RudiSettingsTile);
    expect(tester.getSize(tile).height, RudiSettingsTile.height);
    expect(
      tester.getSemantics(tile).getSemanticsData().flagsCollection.isToggled,
      Tristate.isFalse,
    );
    await tester.tap(tile);
    expect(value, true);
  });
}

final class const _SheetHarness({
  final bool reduced = false,
  final bool long = false,
  final bool showClose = true,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => RudiApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
      child: child!,
    ),
    home: Builder(
      builder: (context) => RudiPage(
        child: Center(
          child: RudiButton(
            label: 'Open',
            onPressed: () => unawaited(
              showRudiBottomSheet<void>(
                context: context,
                barrierLabel: 'Close',
                builder: (context) => RudiBottomSheet(
                  title: const Text('Options'),
                  trailing: showClose
                      ? const RudiBottomSheetCloseButton(semanticLabel: 'Close')
                      : null,
                  children: [
                    for (var i = 0; i < (long ? 30 : 2); i++)
                      RudiSettingsTile(title: 'Item $i'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

final class const _NavigationHarness({required final bool rtl})
    extends StatefulWidget {
  @override
  State<_NavigationHarness> createState() => _NavigationHarnessState();
}

final class _NavigationHarnessState() extends State<_NavigationHarness> {
  int index = 0;
  @override
  Widget build(BuildContext context) => RudiApp(
    home: Directionality(
      textDirection: widget.rtl ? .rtl : .ltr,
      child: Center(
        child: RudiFloatingNavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          destinations: [
            for (var n = 0; n < 4; n++)
              RudiNavigationDestination(
                icon: const SizedBox.square(dimension: 24),
                label: 'Tab $n',
              ),
          ],
        ),
      ),
    ),
  );
}
