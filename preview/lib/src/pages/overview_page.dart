import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:solar_icons/solar_icons.dart';

import '../shared/catalog_page.dart';
import '../workspace/catalog_destination.dart';

final class OverviewPage extends StatelessWidget {
  const OverviewPage({required this.onNavigate, super.key});

  final ValueChanged<CatalogDestination> onNavigate;

  @override
  Widget build(BuildContext context) {
    return CatalogPage(
      children: [
        _SystemIntro(onExplore: () => onNavigate(CatalogDestination.actions)),
        const SizedBox(height: 72),
        const SectionHeading(
          eyebrow: 'Application shell',
          title: 'Safe areas are part of the component.',
          description: 'RudiApp, RudiPage, RudiAppBar, and RudiBackButton establish the platform-neutral page structure used by every example.',
        ),
        const SizedBox(height: 28),
        const Specimen(
          title: 'Page and app bar',
          description: 'The app bar owns its top inset while the page manages readable content and navigation space.',
          child: _PageShellSpecimen(),
        ),
        const SizedBox(height: 72),
        const SectionHeading(
          eyebrow: 'Interaction primitives',
          title: 'Made to be touched.',
          description: 'Every example is live. Use a mouse, keyboard, touch, or assistive technology to inspect the behavior.',
        ),
        const SizedBox(height: 36),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 760) {
              return const Column(
                children: [
                  _NavigationSpecimen(),
                  SizedBox(height: 48),
                  _ProgressSpecimen(),
                ],
              );
            }
            return const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _NavigationSpecimen()),
                SizedBox(width: 56),
                Expanded(child: _ProgressSpecimen()),
              ],
            );
          },
        ),
        const SizedBox(height: 72),
        const SectionHeading(
          eyebrow: 'Overlay routes',
          title: 'Context without dead ends.',
          description: 'Messages, dialogs, and sheets preserve focus, semantics, and platform-appropriate dismissal.',
        ),
        const SizedBox(height: 28),
        const _RouteActions(),
      ],
    );
  }
}

final class _SystemIntro extends StatelessWidget {
  const _SystemIntro({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Semantics(
      header: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 390),
        padding: EdgeInsets.all(theme.spacing.xl),
        decoration: BoxDecoration(
          color: theme.colors.foreground,
          borderRadius: BorderRadius.circular(theme.radii.xl),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 700;
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'RUDI UI / COMPONENT LAB',
                  style: theme.text.caption.copyWith(
                    color: theme.colors.accent,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Calm surfaces.\nComplete behavior.',
                  style: theme.text.display.copyWith(
                    color: theme.colors.background,
                  ),
                ),
                const SizedBox(height: 18),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Text(
                    'A widgets-only Flutter system for interfaces that stay clear under real input, state, and accessibility needs.',
                    style: theme.text.body.copyWith(
                      color: theme.colors.background.withValues(alpha: .72),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                RudiButton(
                  label: 'Explore controls',
                  expand: false,
                  leading: const RudiGlyph(RudiGlyphType.chevron),
                  variant: RudiButtonVariant.subtle,
                  onPressed: onExplore,
                ),
              ],
            );
            final signal = _SystemSignal(wide: wide);
            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [copy, const SizedBox(height: 38), signal],
              );
            }
            return Row(
              children: [
                Expanded(flex: 3, child: copy),
                const SizedBox(width: 48),
                Expanded(flex: 2, child: signal),
              ],
            );
          },
        ),
      ),
    );
  }
}

final class _PageShellSpecimen extends StatelessWidget {
  const _PageShellSpecimen();

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radii.lg),
        child: SizedBox(
          height: 210,
          child: RudiPage(
            padding: EdgeInsets.zero,
            safeAreaTop: false,
            safeAreaBottom: false,
            child: Column(
              children: [
                RudiAppBar.back(
                  backButtonSemanticLabel: 'Back to catalog',
                  title: const Text('Routine'),
                  onBack: () =>
                      RudiMessenger.of(context)
                          .show(const RudiSnack(message: 'Back selected.')),
                  trailing: const RudiInfoTooltip(
                    semanticLabel: 'About this page',
                    message: 'A compact application shell built from Rudi UI.',
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Page content',
                      style: theme.text.body.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _SystemSignal extends StatelessWidget {
  const _SystemSignal({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: wide
              ? BorderSide(color: theme.colors.background.withValues(alpha: .2))
              : BorderSide.none,
          top: wide
              ? BorderSide.none
              : BorderSide(
                  color: theme.colors.background.withValues(alpha: .2),
                ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: wide ? 28 : 0, top: wide ? 0 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SignalRow(value: '20+', label: 'public components'),
            const SizedBox(height: 20),
            _SignalRow(value: '0', label: 'Material dependencies'),
            const SizedBox(height: 20),
            _SignalRow(value: 'AA', label: 'contrast target'),
          ],
        ),
      ),
    );
  }
}

final class _SignalRow extends StatelessWidget {
  const _SignalRow({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            value,
            style: theme.text.title.copyWith(color: theme.colors.background),
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: theme.text.caption.copyWith(
              color: theme.colors.background.withValues(alpha: .64),
            ),
          ),
        ),
      ],
    );
  }
}

final class _NavigationSpecimen extends StatefulWidget {
  const _NavigationSpecimen();

  @override
  State<_NavigationSpecimen> createState() => _NavigationSpecimenState();
}

final class _NavigationSpecimenState extends State<_NavigationSpecimen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Specimen(
      title: 'Floating navigation',
      description: 'Selection stays clear while a contextual action appears only where it is useful.',
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final destinations = [
              RudiNavigationDestination(
                icon: const Icon(SolarIconsOutline.home),
                selectedIcon: const Icon(SolarIconsBold.home),
                label: 'Browse',
                action: RudiNavigationAction(
                  icon: const Icon(SolarIconsOutline.addCircle),
                  label: 'Create item',
                  onPressed: () => RudiMessenger.of(context).show(
                    const RudiSnack(message: 'Contextual action activated.'),
                  ),
                ),
              ),
              const RudiNavigationDestination(
                icon: Icon(SolarIconsOutline.widget),
                selectedIcon: Icon(SolarIconsBold.widget),
                label: 'Move',
              ),
              if (constraints.maxWidth >= 360)
                const RudiNavigationDestination(
                  icon: Icon(SolarIconsOutline.settingsMinimalistic),
                  selectedIcon: Icon(SolarIconsBold.settingsMinimalistic),
                  label: 'Alert',
                ),
            ];
            final selected = _selected.clamp(0, destinations.length - 1);
            return RudiFloatingNavigationBar(
              compact: true,
              selectedIndex: selected,
              onDestinationSelected: (value) =>
                  setState(() => _selected = value),
              destinations: destinations,
            );
          },
        ),
      ),
    );
  }
}

final class _ProgressSpecimen extends StatelessWidget {
  const _ProgressSpecimen();

  @override
  Widget build(BuildContext context) {
    return const Specimen(
      title: 'Progress with intent',
      description:
          'Continuous, radial, and tactile progress share one semantic value.',
      child: Column(
        children: [
          RudiLinearProgress(value: .68, semanticLabel: '68 percent complete'),
          SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RudiProgressRing(value: .68, size: 92),
              RudiTickProgress(value: .68, size: 92),
            ],
          ),
        ],
      ),
    );
  }
}

final class _RouteActions extends StatelessWidget {
  const _RouteActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        RudiButton(
          label: 'Show message',
          expand: false,
          leading: const RudiGlyph(RudiGlyphType.check),
          onPressed: () => RudiMessenger.of(context).show(
            const RudiSnack(
              message: 'Saved locally.',
              icon: RudiGlyph(RudiGlyphType.check),
            ),
          ),
        ),
        RudiButton(
          label: 'Open dialog',
          expand: false,
          variant: RudiButtonVariant.subtle,
          onPressed: () => _showDialog(context),
        ),
        RudiButton(
          label: 'Open sheet',
          expand: false,
          variant: RudiButtonVariant.subtle,
          onPressed: () => _showSheet(context),
        ),
      ],
    );
  }

  void _showDialog(BuildContext context) {
    showRudiDialog<void>(
      context: context,
      barrierLabel: 'Dismiss dialog',
      builder: (dialogContext) => RudiDialog(
        title: const Text('Independent by design'),
        content: const Text(
          'Routes, focus behavior, and surfaces are built with Flutter core widgets.',
        ),
        actions: [
          RudiButton(
            label: 'Done',
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showRudiBottomSheet<void>(
      context: context,
      barrierLabel: 'Dismiss bottom sheet',
      builder: (sheetContext) => RudiBottomSheet(
        title: const Text('A native Rudi surface'),
        trailing: const RudiBottomSheetCloseButton(
          semanticLabel: 'Dismiss bottom sheet',
        ),
        children: [
          Text(
            'Drag, tap the barrier, or press Escape to dismiss this route.',
            style: sheetContext.rudiTheme.text.body,
          ),
        ],
        actions: [
          RudiButton(
            label: 'Done',
            onPressed: () => Navigator.pop(sheetContext),
          ),
        ],
      ),
    );
  }
}
