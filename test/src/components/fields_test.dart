import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() {
  testWidgets('RudiTextField accepts input and enforces max length', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _TestApp(
        child: RudiTextField(
          controller: controller,
          label: 'Name',
          hint: 'Enter name',
          maxLength: 5,
        ),
      ),
    );

    expect(find.text('Enter name'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'Rudiger');
    await tester.pump();

    expect(controller.text, 'Rudig');
    expect(find.text('5/5'), findsOneWidget);
    expect(find.text('Enter name'), findsNothing);
  });

  testWidgets('RudiTextFormField exposes validation errors', (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      _TestApp(
        child: Form(
          key: formKey,
          child: RudiTextFormField(
            label: 'Required',
            validator: (value) =>
                value == null || value.isEmpty ? 'Missing value' : null,
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Missing value'), findsOneWidget);
  });

  testWidgets('RudiNumberInput clamps values at its bounds', (tester) async {
    num? value;
    await tester.pumpWidget(
      _TestApp(
        child: RudiNumberInput(
          value: 2,
          min: 1,
          max: 3,
          decreaseSemanticLabel: 'Decrease',
          increaseSemanticLabel: 'Increase',
          onChanged: (next) => value = next,
        ),
      ),
    );

    await tester.tap(find.text('+'));
    expect(value, 3);
  });
}

final class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RudiApp(home: RudiPage(child: child));
  }
}
