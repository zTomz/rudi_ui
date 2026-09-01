import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:solar_icons/solar_icons.dart';

void main() {
  DevicePreview.enable(
    enabled: true,
    padding: const EdgeInsets.all(16),
    backgroundDecoration: const BoxDecoration(color: Color(0xFF10100F)),
  );
  runApp(const RudiPreviewApp());
}

final class RudiPreviewApp extends StatefulWidget {
  const RudiPreviewApp({super.key});
  @override
  State<RudiPreviewApp> createState() => _RudiPreviewAppState();
}

final class _RudiPreviewAppState extends State<RudiPreviewApp> {
  RudiThemeMode _themeMode = RudiThemeMode.system;
  @override
  Widget build(BuildContext context) => RudiApp(
    title: 'Rudi UI Preview',
    themeMode: _themeMode,
    theme: _previewTheme(RudiThemeData.light()),
    darkTheme: _previewTheme(RudiThemeData.dark()),
    home: _PreviewWorkspace(
      themeMode: _themeMode,
      onThemeModeChanged: (value) => setState(() => _themeMode = value),
    ),
  );
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

final class _PreviewWorkspace extends StatefulWidget {
  const _PreviewWorkspace({
    required this.themeMode,
    required this.onThemeModeChanged,
  });
  final RudiThemeMode themeMode;
  final ValueChanged<RudiThemeMode> onThemeModeChanged;
  @override
  State<_PreviewWorkspace> createState() => _PreviewWorkspaceState();
}

final class _PreviewWorkspaceState extends State<_PreviewWorkspace> {
  int _page = 0;
  String _deviceId = 'real';
  Orientation _orientation = Orientation.portrait;
  bool _motion = true;
  int _repeats = 4;
  Duration _duration = const Duration(minutes: 12);
  DevicePreviewController? get _preview => DevicePreview.maybeController;
  Future<void> _selectDevice(DevicePreset? preset) async {
    if (preset == null) {
      await _preview?.reset();
      if (mounted) setState(() => _deviceId = 'real');
      return;
    }
    await _preview?.applyPreset(preset, orientation: _orientation);
    if (mounted) setState(() => _deviceId = preset.id);
  }

  Future<void> _rotate() async {
    final next = _orientation == Orientation.portrait
        ? Orientation.landscape
        : Orientation.portrait;
    await _preview?.setOrientation(next);
    if (mounted) setState(() => _orientation = next);
  }

  @override
  Widget build(BuildContext context) {
    const destinations = [
      RudiNavigationDestination(
        icon: Icon(SolarIconsOutline.home),
        selectedIcon: Icon(SolarIconsBold.home),
        label: 'Overview',
      ),
      RudiNavigationDestination(
        icon: Icon(SolarIconsOutline.widget),
        selectedIcon: Icon(SolarIconsBold.widget),
        label: 'Controls',
      ),
      RudiNavigationDestination(
        icon: Icon(SolarIconsOutline.settingsMinimalistic),
        selectedIcon: Icon(SolarIconsBold.settingsMinimalistic),
        label: 'States',
      ),
    ];
    return RudiPage(
      padding: EdgeInsets.zero,
      navigation: RudiFloatingNavigationBar(
        backgroundColor: const Color(0xFF10100F),
        indicatorColor: const Color(0xFFF7F7F5),
        selectedColor: const Color(0xFF10100F),
        unselectedColor: const Color(0xFFF7F7F5),
        destinations: destinations,
        selectedIndex: _page,
        onDestinationSelected: (value) => setState(() => _page = value),
      ),
      child: Column(
        children: [
          _PreviewToolbar(
            deviceId: _deviceId,
            onDeviceSelected: _selectDevice,
            onRotate: _rotate,
            themeMode: widget.themeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : context.rudiTheme.motion.slow,
              child: switch (_page) {
                0 => _OverviewPage(
                  key: const ValueKey('overview'),
                  onNavigate: (value) => setState(() => _page = value),
                ),
                1 => _ControlsPage(
                  key: const ValueKey('controls'),
                  repeats: _repeats,
                  duration: _duration,
                  onRepeatsChanged: (value) => setState(() => _repeats = value),
                  onDurationChanged: (value) =>
                      setState(() => _duration = value),
                ),
                _ => _StatesPage(
                  key: const ValueKey('states'),
                  motion: _motion,
                  onMotionChanged: (value) => setState(() => _motion = value),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

final class _PreviewToolbar extends StatelessWidget {
  const _PreviewToolbar({
    required this.deviceId,
    required this.onDeviceSelected,
    required this.onRotate,
    required this.themeMode,
    required this.onThemeModeChanged,
  });
  final String deviceId;
  final ValueChanged<DevicePreset?> onDeviceSelected;
  final VoidCallback onRotate;
  final RudiThemeMode themeMode;
  final ValueChanged<RudiThemeMode> onThemeModeChanged;
  static const _devices = [
    DevicePresets.iPhone16,
    DevicePresets.pixel10,
    DevicePresets.iPadPro11M4,
    DevicePresets.smallDesktopWindow,
  ];
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: theme.spacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colors.outline)),
      ),
      child: Row(
        children: [
          Text('RUDI', style: theme.text.title),
          const SizedBox(width: 10),
          Text(
            'PREVIEW',
            style: theme.text.caption.copyWith(color: theme.colors.accent),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
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
            ),
          ),
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
        ],
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: RudiPressable(
        onPressed: onPressed,
        builder: (context, state) => AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : theme.motion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? theme.colors.foreground : theme.colors.surface,
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

abstract final class _PageLayout {
  static Widget build(BuildContext context, List<Widget> children) => ListView(
    key: const ValueKey('component-catalog-scroll'),
    padding: const EdgeInsets.fromLTRB(20, 32, 20, 176),
    children: [
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    ],
  );
}

final class _OverviewPage extends StatelessWidget {
  const _OverviewPage({required this.onNavigate, super.key});
  final ValueChanged<int> onNavigate;
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return _PageLayout.build(context, [
      Semantics(
        header: true,
        child: Container(
          padding: EdgeInsets.all(theme.spacing.xl),
          decoration: BoxDecoration(
            color: theme.colors.foreground,
            borderRadius: BorderRadius.circular(theme.radii.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RUDI UI',
                style: theme.text.label.copyWith(color: theme.colors.accent),
              ),
              const SizedBox(height: 16),
              Text(
                'A calmer way to\nbuild Flutter.',
                style: theme.text.display.copyWith(
                  color: theme.colors.background,
                ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  'An independent, accessible UI system for the surfaces people use every day.',
                  style: theme.text.body.copyWith(
                    color: theme.colors.background.withValues(alpha: .72),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              RudiButton(
                label: 'Explore controls',
                leading: const RudiGlyph(RudiGlyphType.chevron),
                onPressed: () => onNavigate(1),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 56),
      const _SectionHeader(
        eyebrow: 'Latest components',
        title: 'Small set. Complete behavior.',
        description:
            'The newest building blocks are shown in a real interface, not a wall of isolated demos.',
      ),
      const SizedBox(height: 24),
      LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= 720
            ? const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _NavigationFeature()),
                  SizedBox(width: 48),
                  Expanded(child: _ProgressFeature()),
                ],
              )
            : const Column(
                children: [
                  _NavigationFeature(),
                  SizedBox(height: 40),
                  _ProgressFeature(),
                ],
              ),
      ),
      const SizedBox(height: 64),
      const _SectionHeader(
        eyebrow: 'Interaction',
        title: 'Built to be used.',
        description:
            'Open a route, trigger feedback, or try direct manipulation.',
      ),
      const SizedBox(height: 24),
      const _RouteActions(),
    ]);
  }
}

final class _NavigationFeature extends StatefulWidget {
  const _NavigationFeature();
  @override
  State<_NavigationFeature> createState() => _NavigationFeatureState();
}

final class _NavigationFeatureState extends State<_NavigationFeature> {
  int _selected = 0;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Floating navigation', style: context.rudiTheme.text.title),
      const SizedBox(height: 8),
      Text(
        'A continuous selection indicator keeps compact navigation unmistakable.',
        style: context.rudiTheme.text.body.copyWith(
          color: context.rudiTheme.colors.mutedForeground,
        ),
      ),
      const SizedBox(height: 24),
      Center(
        child: RudiFloatingNavigationBar(
          backgroundColor: const Color(0xFF10100F),
          indicatorColor: const Color(0xFFF7F7F5),
          selectedColor: const Color(0xFF10100F),
          unselectedColor: const Color(0xFFF7F7F5),
          selectedIndex: _selected,
          onDestinationSelected: (value) => setState(() => _selected = value),
          destinations: const [
            RudiNavigationDestination(
              icon: Icon(SolarIconsOutline.home),
              selectedIcon: Icon(SolarIconsBold.home),
              label: 'Browse',
            ),
            RudiNavigationDestination(
              icon: Icon(SolarIconsOutline.widget),
              selectedIcon: Icon(SolarIconsBold.widget),
              label: 'Move',
            ),
            RudiNavigationDestination(
              icon: Icon(SolarIconsOutline.settingsMinimalistic),
              selectedIcon: Icon(SolarIconsBold.settingsMinimalistic),
              label: 'Alert',
            ),
          ],
        ),
      ),
    ],
  );
}

final class _ProgressFeature extends StatelessWidget {
  const _ProgressFeature();
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Progress with intent', style: theme.text.title),
        const SizedBox(height: 8),
        Text(
          'Motion respects system preferences while status stays readable.',
          style: theme.text.body.copyWith(color: theme.colors.mutedForeground),
        ),
        const SizedBox(height: 28),
        const RudiLinearProgress(
          value: .68,
          semanticLabel: '68 percent complete',
        ),
        const SizedBox(height: 24),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            RudiProgressRing(value: .68, size: 96),
            RudiTickProgress(value: .68, size: 96),
          ],
        ),
      ],
    );
  }
}

final class _RouteActions extends StatelessWidget {
  const _RouteActions();
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 12,
    children: [
      RudiButton(
        label: 'Show message',
        leading: const RudiGlyph(RudiGlyphType.check),
        onPressed: () => RudiMessenger.of(
          context,
        ).show(const RudiSnack(message: 'Saved locally.', actionLabel: 'Undo')),
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
              'Routes, focus behavior and surfaces are built with Flutter core widgets.',
            ),
            actions: [
              RudiButton(
                label: 'Done',
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ],
          ),
        ),
      ),
      RudiButton(
        label: 'Open sheet',
        variant: RudiButtonVariant.subtle,
        onPressed: () => showRudiBottomSheet<void>(
          context: context,
          title: 'A native Rudi surface',
          barrierLabel: 'Dismiss bottom sheet',
          builder: (sheetContext) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Drag, tap the barrier or press Escape to dismiss this route.',
                style: sheetContext.rudiTheme.text.body,
              ),
              const SizedBox(height: 24),
              RudiButton(
                label: 'Done',
                onPressed: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

final class _ControlsPage extends StatelessWidget {
  const _ControlsPage({
    required this.repeats,
    required this.duration,
    required this.onRepeatsChanged,
    required this.onDurationChanged,
    super.key,
  });
  final int repeats;
  final Duration duration;
  final ValueChanged<int> onRepeatsChanged;
  final ValueChanged<Duration> onDurationChanged;
  @override
  Widget build(BuildContext context) => _PageLayout.build(context, [
    const _SectionHeader(
      eyebrow: 'Controls',
      title: 'Direct, precise, accessible.',
      description:
          'Controls share touch targets, keyboard behavior and reduced-motion support.',
    ),
    const SizedBox(height: 36),
    const RudiTextField(
      label: 'Routine name',
      hint: 'Morning focus',
      maxLength: 48,
    ),
    const SizedBox(height: 28),
    RudiNumberInput(
      value: repeats,
      min: 1,
      max: 12,
      label: 'Repeats',
      decreaseSemanticLabel: 'Decrease repeats',
      increaseSemanticLabel: 'Increase repeats',
      onChanged: (value) => onRepeatsChanged(value.toInt()),
    ),
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
    const SizedBox(height: 8),
    Text(
      '${duration.inMinutes} minutes',
      textAlign: TextAlign.center,
      style: context.rudiTheme.text.label,
    ),
    const SizedBox(height: 56),
    const _SectionHeader(
      eyebrow: 'Calendar',
      title: 'A month that moves naturally.',
      description:
          'Swipe between months and keep day states readable without shrinking their touch targets.',
    ),
    const SizedBox(height: 24),
    Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: const _CalendarPreview(),
      ),
    ),
    const SizedBox(height: 56),
    const _SectionHeader(
      eyebrow: 'Confirmation',
      title: 'When a tap should mean more.',
      description:
          'Hold and swipe affordances prevent accidental consequential actions.',
    ),
    const SizedBox(height: 24),
    const _ConfirmationControls(),
  ]);
}

final class _CalendarPreview extends StatefulWidget {
  const _CalendarPreview();

  @override
  State<_CalendarPreview> createState() => _CalendarPreviewState();
}

final class _CalendarPreviewState extends State<_CalendarPreview> {
  static final _today = DateTime(2026, 9, 20);
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final Set<String> _completed = {'2026-09-02', '2026-09-08', '2026-09-17'};
  final Set<String> _inProgress = {'2026-09-14'};

  String _key(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  RudiCalendarDayState _stateFor(DateTime date) {
    final key = _key(date);
    if (date.isAfter(_today)) return RudiCalendarDayState.unavailable;
    if (_completed.contains(key)) return RudiCalendarDayState.completed;
    if (_inProgress.contains(key)) return RudiCalendarDayState.inProgress;
    return RudiCalendarDayState.available;
  }

  void _toggle(DateTime date) {
    final key = _key(date);
    setState(() {
      _inProgress.remove(key);
      if (!_completed.remove(key)) _completed.add(key);
    });
  }

  @override
  Widget build(BuildContext context) => RudiCalendar(
    initialMonth: DateTime(2026, 9),
    firstMonth: DateTime(2026, 7),
    lastMonth: DateTime(2026, 9),
    today: _today,
    weekdayLabels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    monthLabelBuilder: (month) => '${_months[month.month - 1]} ${month.year}',
    dayStateBuilder: _stateFor,
    daySemanticLabelBuilder: (day, state) =>
        '${_months[day.month - 1]} ${day.day}, ${state.name}',
    previousMonthSemanticLabel: 'Previous month',
    nextMonthSemanticLabel: 'Next month',
    onDayPressed: _toggle,
    gridHeight: 288,
  );
}

final class _ConfirmationControls extends StatelessWidget {
  const _ConfirmationControls();
  @override
  Widget build(BuildContext context) {
    void confirm() => RudiMessenger.of(
      context,
    ).show(const RudiSnack(message: 'Gesture confirmed.'));
    return LayoutBuilder(
      builder: (context, constraints) {
        final hold = RudiHoldToConfirm(
          label: 'Hold to confirm',
          icon: const RudiGlyph(RudiGlyphType.check),
          semanticHint: 'Press and hold to confirm',
          onConfirmed: confirm,
        );
        final swipe = RudiSwipeAction(
          label: 'Swipe to finish',
          thumb: const RudiGlyph(RudiGlyphType.chevron),
          semanticHint: 'Swipe right to confirm',
          completedSemanticHint: 'Completed',
          loadingSemanticHint: 'Loading',
          onConfirmed: confirm,
        );
        return constraints.maxWidth >= 720
            ? Row(
                children: [
                  Expanded(child: hold),
                  const SizedBox(width: 24),
                  Expanded(child: swipe),
                ],
              )
            : Column(children: [hold, const SizedBox(height: 16), swipe]);
      },
    );
  }
}

final class _StatesPage extends StatelessWidget {
  const _StatesPage({
    required this.motion,
    required this.onMotionChanged,
    super.key,
  });
  final bool motion;
  final ValueChanged<bool> onMotionChanged;
  @override
  Widget build(BuildContext context) => _PageLayout.build(context, [
    const _SectionHeader(
      eyebrow: 'States',
      title: 'Every outcome has a surface.',
      description:
          'The states below make recovery, waiting and empty moments part of the product.',
    ),
    const SizedBox(height: 32),
    RudiSettingsGroup(
      title: 'PREFERENCES',
      children: [
        RudiSwitchTile(
          title: 'Comfortable motion',
          subtitle: 'Preview component transitions',
          leading: const RudiGlyph(RudiGlyphType.info),
          value: motion,
          onChanged: onMotionChanged,
        ),
        const RudiSettingsTile(
          title: 'Keyboard-first controls',
          subtitle: 'Focus rings and semantic targets included',
          leading: RudiGlyph(RudiGlyphType.check),
          selected: true,
        ),
      ],
    ),
    const SizedBox(height: 48),
    LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= 720
          ? const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _EmptyState()),
                SizedBox(width: 32),
                Expanded(child: _ErrorState()),
              ],
            )
          : const Column(
              children: [_EmptyState(), SizedBox(height: 32), _ErrorState()],
            ),
    ),
    const SizedBox(height: 40),
    const RudiLoadingView(label: 'Loading a fresh component state…'),
  ]);
}

final class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => RudiEmptyView(
    title: 'Nothing to review',
    message: 'New work will appear here when it is ready.',
    action: RudiButton(
      label: 'Create item',
      onPressed: () => RudiMessenger.of(
        context,
      ).show(const RudiSnack(message: 'New item created.')),
    ),
  );
}

final class _ErrorState extends StatelessWidget {
  const _ErrorState();
  @override
  Widget build(BuildContext context) => RudiErrorView(
    title: 'Connection interrupted',
    message: 'Your work is safe. Try again when you are ready.',
    details: 'Preview error: request timed out after 8 seconds.',
    showDetailsLabel: 'Show details',
    hideDetailsLabel: 'Hide details',
    primaryAction: RudiButton(
      label: 'Try again',
      onPressed: () => RudiMessenger.of(
        context,
      ).show(const RudiSnack(message: 'Trying again…')),
    ),
  );
}

final class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.description,
  });
  final String eyebrow;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: theme.text.caption.copyWith(color: theme.colors.accent),
        ),
        const SizedBox(height: 8),
        Text(title, style: theme.text.headline),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            description,
            style: theme.text.body.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }
}
