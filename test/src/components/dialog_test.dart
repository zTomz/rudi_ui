import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() {
  testWidgets('normal dialog uses the compact Loop composition', (
    tester,
  ) async {
    const firstActionKey = ValueKey('first-action');
    const secondActionKey = ValueKey('second-action');
    const iconKey = ValueKey('dialog-icon');

    await tester.pumpWidget(
      _host(
        const RudiDialog(
          icon: SizedBox(key: iconKey),
          title: Text('Title'),
          content: Text('Content'),
          actions: [
            SizedBox(key: firstActionKey, height: 48),
            SizedBox(key: secondActionKey, height: 48),
          ],
        ),
      ),
    );

    final iconTheme = IconTheme.of(tester.element(find.byKey(iconKey)));
    final first = tester.getRect(find.byKey(firstActionKey));
    final second = tester.getRect(find.byKey(secondActionKey));

    expect(iconTheme.size, 60);
    expect(first.width, 290);
    expect(second.width, 290);
    expect(second.top, greaterThan(first.bottom));
  });

  testWidgets('expanded dialog lays actions out in one row', (tester) async {
    const firstActionKey = ValueKey('first-action');
    const secondActionKey = ValueKey('second-action');
    const iconKey = ValueKey('dialog-icon');

    await tester.pumpWidget(
      _host(
        const RudiDialog(
          expanded: true,
          icon: SizedBox(key: iconKey),
          title: Text('Title'),
          content: Text('Content'),
          actions: [
            SizedBox(key: firstActionKey, height: 48),
            SizedBox(key: secondActionKey, height: 48),
          ],
        ),
      ),
    );

    final iconTheme = IconTheme.of(tester.element(find.byKey(iconKey)));
    final first = tester.getRect(find.byKey(firstActionKey));
    final second = tester.getRect(find.byKey(secondActionKey));

    expect(iconTheme.size, 40);
    expect(first.top, second.top);
    expect(first.width, closeTo(296, 0.01));
    expect(second.width, closeTo(296, 0.01));
  });
}

Widget _host(Widget child) {
  return MediaQuery(
    data: const MediaQueryData(size: Size(800, 600)),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: RudiTheme(data: RudiThemeData.light(), child: child),
    ),
  );
}
