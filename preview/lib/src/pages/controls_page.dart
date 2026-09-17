import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../shared/catalog_page.dart';

final class ControlsPage extends StatefulWidget {
  const ControlsPage({super.key});

  @override
  State<ControlsPage> createState() => _ControlsPageState();
}

final class _ControlsPageState extends State<ControlsPage> {
  final _formKey = GlobalKey<FormState>();
  int _repeats = 4;
  Duration _duration = const Duration(minutes: 12);

  @override
  Widget build(BuildContext context) {
    return CatalogPage(
      children: [
        const SectionHeading(
          eyebrow: 'Components',
          title: 'Forms',
          description: 'Text, numeric, and direct-manipulation inputs with focus, keyboard, validation, and semantic behavior built in.',
        ),
        const SizedBox(height: 48),
        Specimen(
          title: 'Text field',
          description: 'A labeled text input with hint, counter, validation, and disabled states.',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: const Column(
              children: [
                RudiTextField(
                  label: 'Routine name',
                  hint: 'Morning focus',
                  maxLength: 48,
                ),
                SizedBox(height: 24),
                RudiTextField(
                  label: 'Read-only value',
                  hint: 'Synced from your workspace',
                  enabled: false,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 56),
        Specimen(
          title: 'Form field',
          description: 'The form-integrated variant participates in validation and saving without changing its visual language.',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  RudiTextFormField(
                    label: 'Workspace handle',
                    hint: 'rudi-lab',
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'Enter a workspace handle.'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  RudiButton(
                    label: 'Validate form',
                    expand: false,
                    onPressed: () => _formKey.currentState?.validate(),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 56),
        Specimen(
          title: 'Number input',
          description: 'Increment, decrement, type, or use arrow keys while the value remains clamped.',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: RudiNumberInput(
              value: _repeats,
              min: 1,
              max: 12,
              label: 'Repeats',
              decreaseSemanticLabel: 'Decrease repeats',
              increaseSemanticLabel: 'Increase repeats',
              onChanged: (value) => setState(() => _repeats = value.toInt()),
            ),
          ),
        ),
        const SizedBox(height: 56),
        Specimen(
          title: 'Duration ruler',
          description: 'A tactile time selector that supports dragging, scrolling, and keyboard adjustment.',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                RudiDurationRuler(
                  value: _duration,
                  min: const Duration(minutes: 1),
                  max: const Duration(minutes: 30),
                  divisions: 29,
                  semanticLabel: 'Duration',
                  semanticValueBuilder: (value) => '${value.inMinutes} minutes',
                  onChanged: (value) => setState(() => _duration = value),
                ),
                const SizedBox(height: 10),
                Text(
                  '${_duration.inMinutes} minutes',
                  style: context.rudiTheme.text.label,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
