import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() {
  testWidgets('navigation shell uses bottom navigation on compact widths', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const _NavigationApp());

    final bar = tester.widget<RudiNavigationBar>(
      find.byType(RudiNavigationBar),
    );
    expect(bar.axis, Axis.horizontal);
  });

  testWidgets('navigation shell uses side navigation on expanded widths', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const _NavigationApp());

    final bar = tester.widget<RudiNavigationBar>(
      find.byType(RudiNavigationBar),
    );
    expect(bar.axis, Axis.vertical);
  });
}

final class _NavigationApp extends StatelessWidget {
  const _NavigationApp();

  @override
  Widget build(BuildContext context) {
    return RudiApp(
      home: RudiNavigationShell(
        body: const SizedBox.expand(),
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        destinations: const [
          RudiNavigationDestination(icon: SizedBox(), label: 'One'),
          RudiNavigationDestination(icon: SizedBox(), label: 'Two'),
        ],
      ),
    );
  }
}
