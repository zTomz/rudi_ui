import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() {
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
    'floating indicator reaches last requested tab after rapid taps, including RTL',
    (tester) async {
      for (final rtl in [false, true]) {
        await tester.pumpWidget(_NavigationHarness(rtl: rtl));
        for (final index in [3, 1, 2, 0, 3]) {
          await tester.tap(find.byKey(ValueKey('nav-$index')));
          await tester.pump(const Duration(milliseconds: 40));
        }
        await tester.pumpAndSettle();
        final target = tester.getCenter(find.byKey(const ValueKey('nav-3')));
        final indicator = tester.getCenter(find.byType(AnimatedPositioned));
        expect(indicator.dx, closeTo(target.dx, .1));
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
                title: 'Options',
                barrierLabel: 'Close',
                closeIcon: showClose
                    ? const RudiGlyph(RudiGlyphType.close)
                    : null,
                builder: (context) => Column(
                  mainAxisSize: .min,
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
