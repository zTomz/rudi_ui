import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() => runApp(const RudiShowcaseApp());

/// Widgets-only showcase for Rudi UI.
final class RudiShowcaseApp extends StatefulWidget {
  /// Creates the showcase.
  const RudiShowcaseApp({super.key});

  @override
  State<RudiShowcaseApp> createState() => _RudiShowcaseAppState();
}

final class _RudiShowcaseAppState extends State<RudiShowcaseApp> {
  RudiThemeMode _themeMode = RudiThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return RudiApp(
      title: 'Rudi UI',
      themeMode: _themeMode,
      home: _Showcase(
        themeMode: _themeMode,
        onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}

final class _Showcase extends StatefulWidget {
  const _Showcase({required this.themeMode, required this.onThemeModeChanged});

  final RudiThemeMode themeMode;
  final ValueChanged<RudiThemeMode> onThemeModeChanged;

  @override
  State<_Showcase> createState() => _ShowcaseState();
}

final class _ShowcaseState extends State<_Showcase> {
  int _destination = 0;
  int _number = 3;
  Duration _duration = const Duration(minutes: 5);

  @override
  Widget build(BuildContext context) {
    return RudiNavigationShell(
      selectedIndex: _destination,
      onDestinationSelected: (value) => setState(() => _destination = value),
      destinations: const [
        RudiNavigationDestination(
          icon: RudiGlyph(RudiGlyphType.info),
          selectedIcon: RudiGlyph(RudiGlyphType.check),
          label: 'Components',
        ),
        RudiNavigationDestination(
          icon: RudiGlyph(RudiGlyphType.chevron),
          label: 'Patterns',
        ),
      ],
      body: RudiPage(
        constrainContent: true,
        child: ListView(
          children: [
            Text('Rudi UI', style: context.rudiTheme.text.display),
            const SizedBox(height: 8),
            Text(
              'A widgets-only, accessible Flutter design system.',
              style: context.rudiTheme.text.body.copyWith(
                color: context.rudiTheme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                RudiButton(
                  label: 'Show message',
                  onPressed: () => RudiMessenger.of(
                    context,
                  ).show(const RudiSnack(message: 'Hello from Rudi UI')),
                ),
                RudiButton(
                  label: 'Open dialog',
                  variant: RudiButtonVariant.subtle,
                  onPressed: () => showRudiDialog<void>(
                    context: context,
                    barrierLabel: 'Dismiss dialog',
                    builder: (dialogContext) => RudiDialog(
                      title: const Text('Independent by design'),
                      content: const Text(
                        'This dialog uses no Material or Cupertino widgets.',
                      ),
                      actions: [
                        RudiButton(
                          label: 'Done',
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
                RudiButton(
                  label: 'Toggle theme',
                  variant: RudiButtonVariant.subtle,
                  onPressed: () => widget.onThemeModeChanged(
                    widget.themeMode == RudiThemeMode.dark
                        ? RudiThemeMode.light
                        : RudiThemeMode.dark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const RudiTextField(
              label: 'Example field',
              hint: 'Type with keyboard or IME',
              maxLength: 80,
            ),
            const SizedBox(height: 24),
            RudiNumberInput(
              label: 'Repeats',
              value: _number,
              min: 1,
              max: 10,
              decreaseSemanticLabel: 'Decrease repeats',
              increaseSemanticLabel: 'Increase repeats',
              onChanged: (value) => setState(() => _number = value.toInt()),
            ),
            const SizedBox(height: 24),
            RudiDurationRuler(
              value: _duration,
              min: const Duration(minutes: 1),
              max: const Duration(minutes: 30),
              divisions: 29,
              semanticLabel: 'Duration',
              semanticValueBuilder: (value) => '${value.inMinutes} minutes',
              onChanged: (value) => setState(() => _duration = value),
            ),
            Text(
              '${_duration.inMinutes} minutes',
              textAlign: TextAlign.center,
              style: context.rudiTheme.text.label,
            ),
            const SizedBox(height: 32),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RudiProgressRing(value: 0.68, size: 120),
                RudiTickProgress(value: 0.68, size: 120),
              ],
            ),
            const SizedBox(height: 32),
            RudiSettingsSection(
              title: 'Preferences',
              children: [
                RudiOptionTile<RudiThemeMode>(
                  value: RudiThemeMode.system,
                  groupValue: widget.themeMode,
                  label: 'System theme',
                  onSelected: widget.onThemeModeChanged,
                ),
                RudiOptionTile<RudiThemeMode>(
                  value: RudiThemeMode.light,
                  groupValue: widget.themeMode,
                  label: 'Light theme',
                  onSelected: widget.onThemeModeChanged,
                ),
                RudiOptionTile<RudiThemeMode>(
                  value: RudiThemeMode.dark,
                  groupValue: widget.themeMode,
                  label: 'Dark theme',
                  onSelected: widget.onThemeModeChanged,
                ),
              ],
            ),
            const SizedBox(height: 32),
            RudiHoldToConfirm(
              label: 'Hold to confirm',
              onConfirmed: () => RudiMessenger.of(
                context,
              ).show(const RudiSnack(message: 'Confirmed')),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
