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

  testWidgets('RudiTextField applies alignment, style, and content padding', (
    tester,
  ) async {
    const textStyle = TextStyle(fontSize: 28, fontWeight: FontWeight.w700);
    const contentPadding = EdgeInsets.symmetric(horizontal: 4, vertical: 2);
    const background = Color(0xFF123456);
    await tester.pumpWidget(
      const _TestApp(
        child: RudiTextField(
          hint: 'Number',
          textAlign: TextAlign.center,
          style: textStyle,
          contentPadding: contentPadding,
          backgroundColor: background,
        ),
      ),
    );

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.textAlign, TextAlign.center);
    expect(editable.style.fontSize, 28);
    expect(editable.style.fontWeight, FontWeight.w700);

    final surfacePadding = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(RudiTextField),
        matching: find.byType(AnimatedContainer),
      ),
    );
    expect(surfacePadding.padding, contentPadding);
    expect((surfacePadding.decoration! as BoxDecoration).color, background);
  });

  testWidgets('RudiTextField aligns a multiline hint with the first line', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        child: RudiTextField(hint: 'What happened?', minLines: 4, maxLines: 6),
      ),
    );

    final hintTop = tester.getTopLeft(find.text('What happened?')).dy;
    final editableTop = tester.getTopLeft(find.byType(EditableText)).dy;

    expect(hintTop, editableTop);
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
