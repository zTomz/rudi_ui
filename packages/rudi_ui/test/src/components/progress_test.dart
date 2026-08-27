import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() {
  testWidgets('duration ruler updates from pointer position', (tester) async {
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
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    final ruler = find.byType(RudiDurationRuler);
    await tester.tapAt(tester.getTopLeft(ruler) + const Offset(225, 32));

    expect(selected, isNotNull);
    expect(selected!.inSeconds, closeTo(450, 15));
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
