import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui_example/main.dart';

void main() {
  testWidgets('showcase renders without Material or Cupertino', (tester) async {
    await tester.pumpWidget(const RudiShowcaseApp());

    expect(find.text('Rudi UI'), findsOneWidget);
    expect(find.text('Show message'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
