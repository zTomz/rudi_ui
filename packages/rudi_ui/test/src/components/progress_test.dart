import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() {
  testWidgets('duration ruler scrolls and snaps like the Loop control', (
    tester,
  ) async {
    Duration? selected;
    await tester.pumpWidget(
      _TestApp(
        child: SizedBox(
          width: 300,
          child: RudiDurationRuler(
            value: const Duration(minutes: 5),
            min: Duration.zero,
            max: const Duration(minutes: 10),
            semanticLabel: 'Duration',
            semanticValueBuilder: (value) => '${value.inSeconds} seconds',
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    final ruler = find.byType(RudiDurationRuler);
    expect(tester.getSize(ruler).height, 72);
    await tester.drag(ruler, const Offset(-140, 0));
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
    expect(selected!.inSeconds, greaterThan(300));
  });

  testWidgets('progress widgets support large text scale without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        textScaler: const TextScaler.linear(2),
        child: const RudiProgressRing(value: 0.5, child: Text('50 percent')),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

final class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.textScaler});

  final Widget child;
  final TextScaler? textScaler;

  @override
  Widget build(BuildContext context) {
    return RudiApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: RudiPage(child: Center(child: child)),
    );
  }
}
