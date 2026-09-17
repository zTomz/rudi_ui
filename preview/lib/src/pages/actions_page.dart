import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:solar_icons/solar_icons.dart';

import '../shared/catalog_page.dart';

final class ActionsPage extends StatelessWidget {
  const ActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    void notify(String message) {
      RudiMessenger.of(context).show(RudiSnack(message: message));
    }

    return CatalogPage(
      children: [
        const SectionHeading(
          eyebrow: 'Components',
          title: 'Actions',
          description: 'Buttons and deliberate gestures with consistent targets, feedback, focus, and disabled behavior.',
        ),
        const SizedBox(height: 48),
        Specimen(
          title: 'Button',
          description:
              'Three emphasis levels plus loading and disabled states.',
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              RudiButton(
                label: 'Primary',
                expand: false,
                onPressed: () => notify('Primary action.'),
              ),
              RudiButton(
                label: 'Subtle',
                expand: false,
                variant: RudiButtonVariant.subtle,
                onPressed: () => notify('Subtle action.'),
              ),
              RudiButton(
                label: 'Destructive',
                expand: false,
                variant: RudiButtonVariant.destructive,
                onPressed: () => notify('Destructive action.'),
              ),
              RudiButton(
                label: 'Working',
                expand: false,
                loading: true,
                onPressed: () {},
              ),
              const RudiButton(
                label: 'Disabled',
                expand: false,
                onPressed: null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 56),
        Specimen(
          title: 'Icon button and glyphs',
          description: 'Icon-only controls retain a 48-point target and require a semantic label.',
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 18,
            runSpacing: 18,
            children: [
              RudiIconButton(
                icon: const Icon(SolarIconsOutline.addCircle),
                semanticLabel: 'Add item',
                onPressed: () => notify('Item added.'),
              ),
              RudiIconButton(
                icon: const Icon(SolarIconsOutline.settingsMinimalistic),
                semanticLabel: 'Open settings',
                onPressed: () => notify('Settings opened.'),
              ),
              const RudiIconButton(
                icon: Icon(SolarIconsOutline.bellOff),
                semanticLabel: 'Notifications unavailable',
                onPressed: null,
              ),
              const RudiGlyph(RudiGlyphType.check, size: 28),
              const RudiGlyph(RudiGlyphType.info, size: 28),
              const RudiGlyph(RudiGlyphType.error, size: 28),
              const RudiGlyph(RudiGlyphType.chevron, size: 28),
            ],
          ),
        ),
        const SizedBox(height: 56),
        Specimen(
          title: 'Pressable',
          description: 'The low-level primitive exposes hover, focus, pressed, and enabled state.',
          child: const _PressableDemo(),
        ),
        const SizedBox(height: 56),
        Specimen(
          title: 'Confirmation gestures',
          description: 'Hold and swipe interactions make consequential actions intentional.',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final hold = RudiHoldToConfirm(
                label: 'Hold to confirm',
                icon: const RudiGlyph(RudiGlyphType.check),
                semanticHint: 'Press and hold to confirm',
                onConfirmed: () => notify('Hold confirmed.'),
              );
              final swipe = RudiSwipeAction(
                label: 'Swipe to finish',
                thumb: const RudiGlyph(RudiGlyphType.chevron),
                semanticHint: 'Swipe right to confirm',
                completedSemanticHint: 'Completed',
                loadingSemanticHint: 'Loading',
                onConfirmed: () => notify('Swipe confirmed.'),
              );
              if (constraints.maxWidth < 700) {
                return Column(
                  children: [hold, const SizedBox(height: 16), swipe],
                );
              }
              return Row(
                children: [
                  Expanded(child: hold),
                  const SizedBox(width: 20),
                  Expanded(child: swipe),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

final class _PressableDemo extends StatelessWidget {
  const _PressableDemo();

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return RudiPressable(
      semanticLabel: 'Interactive pressable example',
      onPressed: () =>
          RudiMessenger.of(context)
              .show(const RudiSnack(message: 'Pressable activated.')),
      builder: (context, state) => AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : theme.motion.fast,
        width: 240,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: state.pressed || state.focused
              ? theme.colors.foreground
              : state.hovered
              ? theme.colors.surface
              : theme.colors.background,
          border: Border.all(
            color: state.focused ? theme.colors.focus : theme.colors.outline,
            width: state.focused ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(theme.radii.lg),
        ),
        child: Text(
          state.pressed
              ? 'Pressed'
              : state.focused
              ? 'Focused'
              : state.hovered
              ? 'Hovered'
              : 'Interact with me',
          textAlign: TextAlign.center,
          style: theme.text.label.copyWith(
            color: state.pressed || state.focused
                ? theme.colors.background
                : theme.colors.foreground,
          ),
        ),
      ),
    );
  }
}
