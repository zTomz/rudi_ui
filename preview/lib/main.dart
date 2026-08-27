import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() {
  DevicePreview.enable(
    enabled: true,
    padding: const EdgeInsets.all(24),
    backgroundDecoration: const BoxDecoration(color: Color(0xFF090A0B)),
  );
  runApp(const RudiPreviewApp());
}

/// Interactive, font-independent Rudi UI component lab.
final class RudiPreviewApp extends StatefulWidget {
  /// Creates the preview application.
  const RudiPreviewApp({super.key});

  @override
  State<RudiPreviewApp> createState() => _RudiPreviewAppState();
}

final class _RudiPreviewAppState extends State<RudiPreviewApp> {
  RudiThemeMode _themeMode = RudiThemeMode.system;

  @override
  Widget build(BuildContext context) {
    final light = _previewTheme(RudiThemeData.light());
    final dark = _previewTheme(RudiThemeData.dark());
    return RudiApp(
      title: 'Rudi UI — Component Lab',
      themeMode: _themeMode,
      theme: light,
      darkTheme: dark,
      home: _ComponentLab(
        themeMode: _themeMode,
        onThemeModeChanged: (value) => setState(() => _themeMode = value),
      ),
    );
  }
}

RudiThemeData _previewTheme(RudiThemeData base) {
  TextStyle body(TextStyle style) => GoogleFonts.googleSans(textStyle: style);
  TextStyle display(TextStyle style) => GoogleFonts.unbounded(textStyle: style);
  return base.copyWith(
    text: base.text.copyWith(
      display: display(base.text.display),
      headline: display(base.text.headline),
      title: display(base.text.title),
      body: body(base.text.body),
      label: body(base.text.label),
      caption: body(base.text.caption),
    ),
  );
}

final class _ComponentLab extends StatefulWidget {
  const _ComponentLab({
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final RudiThemeMode themeMode;
  final ValueChanged<RudiThemeMode> onThemeModeChanged;

  @override
  State<_ComponentLab> createState() => _ComponentLabState();
}

final class _ComponentLabState extends State<_ComponentLab> {
  String _deviceId = 'real';
  Orientation _orientation = Orientation.portrait;
  int _repeats = 4;
  Duration _duration = const Duration(minutes: 8);

  DevicePreviewController? get _preview => DevicePreview.maybeController;

  Future<void> _selectDevice(DevicePreset? preset) async {
    final controller = _preview;
    if (controller == null) return;
    if (preset == null) {
      await controller.reset();
      if (mounted) setState(() => _deviceId = 'real');
      return;
    }
    await controller.applyPreset(preset, orientation: _orientation);
    if (mounted) setState(() => _deviceId = preset.id);
  }

  Future<void> _toggleOrientation() async {
    final next = _orientation == Orientation.portrait
        ? Orientation.landscape
        : Orientation.portrait;
    await _preview?.setOrientation(next);
    if (mounted) setState(() => _orientation = next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return ColoredBox(
      color: theme.colors.background,
      child: SafeArea(
        child: Column(
          children: [
            _DeviceLabBar(
              selectedId: _deviceId,
              orientation: _orientation,
              onSelected: _selectDevice,
              onRotate: _toggleOrientation,
            ),
            Container(height: 1, color: theme.colors.outline),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = constraints.maxWidth >= 900
                      ? 48.0
                      : constraints.maxWidth >= 600
                      ? 32.0
                      : 20.0;
                  return ListView(
                    key: const ValueKey('component-catalog-scroll'),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      36,
                      horizontalPadding,
                      72,
                    ),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _LabHero(),
                              const SizedBox(height: 56),
                              _ResponsivePair(
                                first: _ActionSection(
                                  onThemeModeChanged: widget.onThemeModeChanged,
                                  themeMode: widget.themeMode,
                                ),
                                second: const _TypographySection(),
                              ),
                              const SizedBox(height: 56),
                              _InputSection(
                                repeats: _repeats,
                                duration: _duration,
                                onRepeatsChanged: (value) =>
                                    setState(() => _repeats = value),
                                onDurationChanged: (value) =>
                                    setState(() => _duration = value),
                              ),
                              const SizedBox(height: 56),
                              const _ResponsivePair(
                                first: _ProgressSection(),
                                second: _SettingsSection(),
                              ),
                              const SizedBox(height: 56),
                              const _GestureSection(),
                              const SizedBox(height: 72),
                              Text(
                                'Built only with Flutter core widgets.',
                                textAlign: TextAlign.center,
                                style: theme.text.caption.copyWith(
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _DeviceLabBar extends StatelessWidget {
  const _DeviceLabBar({
    required this.selectedId,
    required this.orientation,
    required this.onSelected,
    required this.onRotate,
  });

  final String selectedId;
  final Orientation orientation;
  final ValueChanged<DevicePreset?> onSelected;
  final VoidCallback onRotate;

  static const _devices = <DevicePreset>[
    DevicePresets.iPhone16,
    DevicePresets.pixel10,
    DevicePresets.iPadPro11M4,
    DevicePresets.smallDesktopWindow,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return SizedBox(
      height: 68,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: theme.spacing.md),
            child: Text('RUDI / LAB', style: theme.text.label),
          ),
          SizedBox(width: theme.spacing.md),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(vertical: theme.spacing.sm),
              child: Row(
                children: [
                  _DeviceChoice(
                    label: 'Real window',
                    selected: selectedId == 'real',
                    onPressed: () => onSelected(null),
                  ),
                  for (final device in _devices)
                    _DeviceChoice(
                      label: device.name,
                      selected: selectedId == device.id,
                      onPressed: () => onSelected(device),
                    ),
                ],
              ),
            ),
          ),
          RudiIconButton(
            semanticLabel: orientation == Orientation.portrait
                ? 'Preview landscape'
                : 'Preview portrait',
            onPressed: onRotate,
            icon: RudiGlyph(
              orientation == Orientation.portrait
                  ? RudiGlyphType.chevron
                  : RudiGlyphType.check,
            ),
          ),
          SizedBox(width: theme.spacing.sm),
        ],
      ),
    );
  }
}

final class _DeviceChoice extends StatelessWidget {
  const _DeviceChoice({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Padding(
      padding: EdgeInsets.only(right: theme.spacing.sm),
      child: RudiPressable(
        onPressed: onPressed,
        builder: (context, state) => AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : theme.motion.fast,
          constraints: const BoxConstraints(minHeight: 44),
          padding: EdgeInsets.symmetric(horizontal: theme.spacing.md),
          decoration: BoxDecoration(
            color: selected || state.hovered
                ? theme.colors.foreground
                : theme.colors.surface,
            borderRadius: BorderRadius.circular(theme.radii.pill),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.text.caption.copyWith(
              color: selected || state.hovered
                  ? theme.colors.background
                  : theme.colors.foreground,
            ),
          ),
        ),
      ),
    );
  }
}

final class _LabHero extends StatelessWidget {
  const _LabHero();

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RUDI UI',
            style: theme.text.label.copyWith(color: theme.colors.accent),
          ),
          SizedBox(height: theme.spacing.sm),
          Text(
            'One system.\nEvery Flutter surface.',
            style: theme.text.display,
          ),
          SizedBox(height: theme.spacing.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              'A font-independent, accessible component system built without Material or Cupertino UI. This lab injects Google Fonts separately.',
              style: theme.text.body.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _ResponsivePair extends StatelessWidget {
  const _ResponsivePair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 760) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 48),
              Expanded(child: second),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [first, const SizedBox(height: 48), second],
        );
      },
    );
  }
}

final class _Section extends StatelessWidget {
  const _Section({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: theme.text.caption.copyWith(color: theme.colors.accent),
        ),
        SizedBox(height: theme.spacing.xs),
        Text(title, style: theme.text.headline),
        SizedBox(height: theme.spacing.sm),
        Text(
          description,
          style: theme.text.body.copyWith(color: theme.colors.mutedForeground),
        ),
        SizedBox(height: theme.spacing.lg),
        child,
      ],
    );
  }
}

final class _ActionSection extends StatelessWidget {
  const _ActionSection({
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final RudiThemeMode themeMode;
  final ValueChanged<RudiThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    return _Section(
      eyebrow: 'Actions',
      title: 'Clear by default',
      description:
          'Pointer, keyboard, focus, loading and disabled states share one interaction model.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RudiButton(
            label: 'Show message',
            onPressed: () => RudiMessenger.of(
              context,
            ).show(const RudiSnack(message: 'Rudi UI is ready.')),
          ),
          const SizedBox(height: 12),
          RudiButton(
            label: 'Open dialog',
            variant: RudiButtonVariant.subtle,
            onPressed: () => showRudiDialog<void>(
              context: context,
              barrierLabel: 'Dismiss dialog',
              builder: (dialogContext) => RudiDialog(
                title: const Text('Independent by design'),
                content: const Text(
                  'This route, surface and interaction use Flutter core widgets.',
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
          const SizedBox(height: 12),
          RudiButton(
            label: 'Open bottom sheet',
            variant: RudiButtonVariant.subtle,
            onPressed: () => showRudiBottomSheet<void>(
              context: context,
              barrierLabel: 'Dismiss bottom sheet',
              builder: (sheetContext) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'A native Rudi surface',
                      style: sheetContext.rudiTheme.text.headline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Drag the sheet down, use Escape or tap the barrier to dismiss it.',
                      style: sheetContext.rudiTheme.text.body,
                    ),
                    const SizedBox(height: 24),
                    RudiButton(
                      label: 'Done',
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          RudiButton(
            label: themeMode == RudiThemeMode.dark
                ? 'Use light theme'
                : 'Use dark theme',
            variant: RudiButtonVariant.subtle,
            onPressed: () => onThemeModeChanged(
              themeMode == RudiThemeMode.dark
                  ? RudiThemeMode.light
                  : RudiThemeMode.dark,
            ),
          ),
          const SizedBox(height: 12),
          const RudiButton(label: 'Unavailable action', onPressed: null),
        ],
      ),
    );
  }
}

final class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) {
    final text = context.rudiTheme.text;
    return _Section(
      eyebrow: 'Typography',
      title: 'Roles, not font files',
      description:
          'Rudi defines hierarchy and rhythm. The consuming app owns every font family and its license.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Display 40', style: text.display),
          const SizedBox(height: 12),
          Text('Headline 28', style: text.headline),
          const SizedBox(height: 12),
          Text('Title 20', style: text.title),
          const SizedBox(height: 12),
          Text(
            'Body text remains readable across platforms.',
            style: text.body,
          ),
          const SizedBox(height: 12),
          Text('LABEL 15', style: text.label),
          const SizedBox(height: 12),
          Text('Caption 13', style: text.caption),
        ],
      ),
    );
  }
}

final class _InputSection extends StatelessWidget {
  const _InputSection({
    required this.repeats,
    required this.duration,
    required this.onRepeatsChanged,
    required this.onDurationChanged,
  });

  final int repeats;
  final Duration duration;
  final ValueChanged<int> onRepeatsChanged;
  final ValueChanged<Duration> onDurationChanged;

  @override
  Widget build(BuildContext context) {
    return _Section(
      eyebrow: 'Input',
      title: 'Made for real interaction',
      description:
          'Try keyboard input, selection, stepping and precise pointer or touch changes.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fields = [
            const RudiTextField(
              label: 'Routine name',
              hint: 'Morning focus',
              maxLength: 48,
            ),
            RudiNumberInput(
              value: repeats,
              min: 1,
              max: 12,
              label: 'Repeats',
              decreaseSemanticLabel: 'Decrease repeats',
              increaseSemanticLabel: 'Increase repeats',
              onChanged: (value) => onRepeatsChanged(value.toInt()),
            ),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (constraints.maxWidth >= 760)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: fields.first),
                    const SizedBox(width: 32),
                    Expanded(child: fields.last),
                  ],
                )
              else ...[
                fields.first,
                const SizedBox(height: 24),
                fields.last,
              ],
              const SizedBox(height: 32),
              RudiDurationRuler(
                value: duration,
                min: const Duration(minutes: 1),
                max: const Duration(minutes: 30),
                divisions: 29,
                semanticLabel: 'Duration',
                semanticValueBuilder: (value) => '${value.inMinutes} minutes',
                onChanged: onDurationChanged,
              ),
              Text(
                '${duration.inMinutes} minutes',
                textAlign: TextAlign.center,
                style: context.rudiTheme.text.label,
              ),
            ],
          );
        },
      ),
    );
  }
}

final class _ProgressSection extends StatelessWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      eyebrow: 'Progress',
      title: 'Quiet momentum',
      description:
          'Determinate and indeterminate progress honors reduced-motion preferences.',
      child: const Column(
        children: [
          RudiLinearProgress(value: 0.68, semanticLabel: '68 percent'),
          SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RudiProgressRing(value: 0.68, size: 112),
              RudiTickProgress(value: 0.68, size: 112),
            ],
          ),
        ],
      ),
    );
  }
}

final class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      eyebrow: 'Settings',
      title: 'Structured choices',
      description:
          'Grouped controls retain clear focus order and selection semantics.',
      child: RudiSettingsSection(
        children: [
          const RudiSettingsTile(
            title: 'Accessible motion',
            subtitle: 'Follows the system preference',
            leading: RudiGlyph(RudiGlyphType.check),
            selected: true,
          ),
          RudiExpandableControl(
            header: const Text('More options'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Expandable content stays in the same logical focus group.',
                style: context.rudiTheme.text.body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _GestureSection extends StatelessWidget {
  const _GestureSection();

  @override
  Widget build(BuildContext context) {
    void confirmed() => RudiMessenger.of(
      context,
    ).show(const RudiSnack(message: 'Gesture confirmed.'));

    return _Section(
      eyebrow: 'Gestures',
      title: 'Deliberate actions feel deliberate',
      description:
          'Hold and swipe controls provide tactile alternatives for consequential actions.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hold = RudiHoldToConfirm(
            label: 'Hold to confirm',
            icon: const RudiGlyph(RudiGlyphType.close),
            semanticHint: 'Press and hold to confirm',
            onConfirmed: confirmed,
          );
          final swipe = RudiSwipeAction(
            label: 'Swipe to finish',
            thumb: const RudiGlyph(RudiGlyphType.chevron),
            semanticHint: 'Swipe right to confirm',
            completedSemanticHint: 'Completed',
            loadingSemanticHint: 'Loading',
            onConfirmed: confirmed,
          );
          if (constraints.maxWidth >= 760) {
            return Row(
              children: [
                Expanded(child: hold),
                const SizedBox(width: 32),
                Expanded(child: swipe),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [hold, const SizedBox(height: 20), swipe],
          );
        },
      ),
    );
  }
}
