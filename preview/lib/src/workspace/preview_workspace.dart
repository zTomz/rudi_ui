import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:solar_icons/solar_icons.dart';

import '../pages/controls_page.dart';
import '../pages/actions_page.dart';
import '../pages/calendar_page.dart';
import '../pages/feedback_page.dart';
import '../pages/navigation_page.dart';
import '../pages/overview_page.dart';
import '../pages/overlays_page.dart';
import '../pages/settings_page.dart';
import 'catalog_destination.dart';

final class PreviewWorkspace extends StatefulWidget {
  const PreviewWorkspace({
    required this.themeMode,
    required this.onThemeModeChanged,
    super.key,
  });

  final RudiThemeMode themeMode;
  final ValueChanged<RudiThemeMode> onThemeModeChanged;

  @override
  State<PreviewWorkspace> createState() => _PreviewWorkspaceState();
}

final class _PreviewWorkspaceState extends State<PreviewWorkspace>
    with SingleTickerProviderStateMixin {
  CatalogDestination _destination = CatalogDestination.overview;
  String _deviceId = 'real';
  Orientation _orientation = Orientation.portrait;
  int _transitionDirection = 1;
  late final AnimationController _pageTransition = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    value: 1,
  );

  DevicePreviewController? get _preview => DevicePreview.maybeController;

  Future<void> _selectDevice(DevicePreset? preset) async {
    if (preset == null) {
      await _preview?.reset();
    } else {
      await _preview?.applyPreset(preset, orientation: _orientation);
    }
    if (!mounted) return;
    setState(() => _deviceId = preset?.id ?? 'real');
  }

  Future<void> _rotate() async {
    final next = _orientation == Orientation.portrait
        ? Orientation.landscape
        : Orientation.portrait;
    await _preview?.setOrientation(next);
    if (!mounted) return;
    setState(() => _orientation = next);
  }

  @override
  void dispose() {
    _pageTransition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return ColoredBox(
      color: theme.colors.background,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final expanded = constraints.maxWidth >= 960;
            final content = Column(
              children: [
                _Toolbar(
                  compact: !expanded,
                  deviceId: _deviceId,
                  onDeviceSelected: _selectDevice,
                  onRotate: _rotate,
                  themeMode: widget.themeMode,
                  onThemeModeChanged: widget.onThemeModeChanged,
                ),
                if (!expanded)
                  _CompactNavigation(
                    selected: _destination,
                    onSelected: _selectDestination,
                  ),
                Expanded(child: _buildPage(context)),
              ],
            );

            if (!expanded) return content;
            return Row(
              children: [
                _CatalogSidebar(
                  selected: _destination,
                  onSelected: _selectDestination,
                ),
                SizedBox(
                  width: 1,
                  child: ColoredBox(color: theme.colors.outline),
                ),
                Expanded(child: content),
              ],
            );
          },
        ),
      ),
    );
  }

  void _selectDestination(CatalogDestination value) {
    if (value == _destination) return;
    setState(() {
      _transitionDirection = value.index > _destination.index ? 1 : -1;
      _destination = value;
    });
    if (MediaQuery.disableAnimationsOf(context)) {
      _pageTransition.value = 1;
    } else {
      _pageTransition.forward(from: 0);
    }
  }

  Widget _buildPage(BuildContext context) {
    final page = switch (_destination) {
      CatalogDestination.overview => OverviewPage(
        key: const ValueKey('overview'),
        onNavigate: _selectDestination,
      ),
      CatalogDestination.actions => const ActionsPage(key: ValueKey('actions')),
      CatalogDestination.forms => const ControlsPage(key: ValueKey('forms')),
      CatalogDestination.navigation => const NavigationPage(
        key: ValueKey('navigation'),
      ),
      CatalogDestination.settings => const SettingsPage(
        key: ValueKey('settings'),
      ),
      CatalogDestination.feedback => const FeedbackPage(
        key: ValueKey('feedback'),
      ),
      CatalogDestination.overlays => const OverlaysPage(
        key: ValueKey('overlays'),
      ),
      CatalogDestination.calendar => const CalendarPage(
        key: ValueKey('calendar'),
      ),
    };
    final position =
        Tween<Offset>(
          begin: Offset(.025 * _transitionDirection, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _pageTransition,
            curve: context.rudiTheme.motion.standardCurve,
          ),
        );
    return ClipRect(
      child: SlideTransition(position: position, child: page),
    );
  }
}

final class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.compact,
    required this.deviceId,
    required this.onDeviceSelected,
    required this.onRotate,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  static const _devices = [
    DevicePresets.iPhone16,
    DevicePresets.pixel10,
    DevicePresets.iPadPro11M4,
    DevicePresets.smallDesktopWindow,
  ];

  final bool compact;
  final String deviceId;
  final ValueChanged<DevicePreset?> onDeviceSelected;
  final VoidCallback onRotate;
  final RudiThemeMode themeMode;
  final ValueChanged<RudiThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final devicePicker = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 0),
      child: Row(
        children: [
          _ToolbarChoice(
            label: 'Window',
            selected: deviceId == 'real',
            onPressed: () => onDeviceSelected(null),
          ),
          for (final device in _devices)
            _ToolbarChoice(
              label: device.name,
              selected: deviceId == device.id,
              onPressed: () => onDeviceSelected(device),
            ),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colors.outline)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, compact ? 10 : 12, 16, 10),
        child: compact
            ? Column(
                children: [
                  Row(children: _actions(context, showTitle: true)),
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerLeft, child: devicePicker),
                ],
              )
            : Row(
                children: [
                  Expanded(child: devicePicker),
                  const SizedBox(width: 12),
                  ..._actions(context),
                ],
              ),
      ),
    );
  }

  List<Widget> _actions(BuildContext context, {bool showTitle = false}) {
    return [
      if (showTitle) ...[
        Text('COMPONENT LAB', style: context.rudiTheme.text.label),
        const Spacer(),
      ],
      if (deviceId != 'real')
        RudiIconButton(
          semanticLabel: 'Rotate preview',
          icon: const Icon(SolarIconsOutline.smartphoneRotateOrientation),
          onPressed: onRotate,
        ),
      RudiIconButton(
        semanticLabel: themeMode == RudiThemeMode.dark
            ? 'Use light theme'
            : 'Use dark theme',
        icon: Icon(
          themeMode == RudiThemeMode.dark
              ? SolarIconsOutline.sun
              : SolarIconsOutline.moon,
        ),
        onPressed: () => onThemeModeChanged(
          themeMode == RudiThemeMode.dark
              ? RudiThemeMode.light
              : RudiThemeMode.dark,
        ),
      ),
    ];
  }
}

final class _ToolbarChoice extends StatelessWidget {
  const _ToolbarChoice({
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
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: RudiPressable(
        onPressed: onPressed,
        builder: (context, state) => AnimatedContainer(
          duration: reduceMotion ? Duration.zero : theme.motion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? theme.colors.foreground
                : state.hovered
                ? theme.colors.surface
                : const Color(0x00000000),
            borderRadius: BorderRadius.circular(theme.radii.pill),
          ),
          child: Text(
            label,
            style: theme.text.caption.copyWith(
              color: selected
                  ? theme.colors.background
                  : theme.colors.foreground,
            ),
          ),
        ),
      ),
    );
  }
}

final class _CatalogSidebar extends StatelessWidget {
  const _CatalogSidebar({required this.selected, required this.onSelected});

  final CatalogDestination selected;
  final ValueChanged<CatalogDestination> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return SizedBox(
      width: 260,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RUDI', style: theme.text.headline),
            const SizedBox(height: 4),
            Text(
              'UI SYSTEM / 0.5.0',
              style: theme.text.caption.copyWith(
                color: theme.colors.accent,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 36),
            Text(
              'CATALOG',
              style: theme.text.caption.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final destination in CatalogDestination.values)
                    _SidebarDestination(
                      destination: destination,
                      selected: destination == selected,
                      onPressed: () => onSelected(destination),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Widgets only.\nAccessible by default.',
              style: theme.text.caption.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _SidebarDestination extends StatelessWidget {
  const _SidebarDestination({
    required this.destination,
    required this.selected,
    required this.onPressed,
  });

  final CatalogDestination destination;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RudiPressable(
        key: ValueKey('nav-${destination.index}'),
        semanticLabel: destination.label,
        onPressed: onPressed,
        builder: (context, state) => AnimatedContainer(
          duration: reduceMotion ? Duration.zero : theme.motion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? theme.colors.foreground
                : state.hovered
                ? theme.colors.surface
                : const Color(0x00000000),
            borderRadius: BorderRadius.circular(theme.radii.md),
          ),
          child: Row(
            children: [
              Icon(
                _iconFor(destination),
                size: 19,
                color: selected
                    ? theme.colors.background
                    : theme.colors.foreground,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.label,
                      style: theme.text.label.copyWith(
                        color: selected
                            ? theme.colors.background
                            : theme.colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destination.description,
                      style: theme.text.caption.copyWith(
                        color: selected
                            ? theme.colors.background.withValues(alpha: .68)
                            : theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _CompactNavigation extends StatelessWidget {
  const _CompactNavigation({required this.selected, required this.onSelected});

  final CatalogDestination selected;
  final ValueChanged<CatalogDestination> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colors.outline)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final destination in CatalogDestination.values)
              RudiPressable(
                key: ValueKey('nav-${destination.index}'),
                onPressed: () => onSelected(destination),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  child: Text(
                    destination.label,
                    style: theme.text.label.copyWith(
                      color: destination == selected
                          ? theme.colors.accent
                          : theme.colors.mutedForeground,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

IconData _iconFor(CatalogDestination destination) => switch (destination) {
  CatalogDestination.overview => SolarIconsOutline.home,
  CatalogDestination.actions => SolarIconsOutline.cursorSquare,
  CatalogDestination.forms => SolarIconsOutline.textField,
  CatalogDestination.navigation => SolarIconsOutline.mapArrowSquare,
  CatalogDestination.settings => SolarIconsOutline.settingsMinimalistic,
  CatalogDestination.feedback => SolarIconsOutline.infoCircle,
  CatalogDestination.overlays => SolarIconsOutline.windowFrame,
  CatalogDestination.calendar => SolarIconsOutline.calendar,
};
