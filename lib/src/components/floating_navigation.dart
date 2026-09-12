import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import 'actions.dart';
import 'navigation.dart';

abstract final class _NavigationMetrics {
  static const itemSize = 64.0;
  static const itemIconSize = 28.0;
  static const actionSize = 88.0;
  static const actionIconSize = 36.0;
  static const actionSlotWidth = 96.0;
  static const containerHeight = 72.0;
  static const containerPadding = 8.0;
}

/// Floating navigation with circular selection and an optional contextual action.
final class RudiFloatingNavigationBar extends StatelessWidget {
  /// Creates a Rudi floating navigation bar.
  const RudiFloatingNavigationBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.compact = false,
    super.key,
  }) : assert(destinations.length >= 2 && destinations.length <= 5),
       assert(selectedIndex >= 0 && selectedIndex < destinations.length);

  /// Destinations displayed in the navigation capsule.
  final List<RudiNavigationDestination> destinations;

  /// Currently selected destination.
  final int selectedIndex;

  /// Called when a destination is activated.
  final ValueChanged<int> onDestinationSelected;

  /// Uses reduced outer margins for embedded and compact layouts.
  final bool compact;

  /// Key applied when an external action press animation is supplied.
  static const actionPressKey = ValueKey('rudi-navigation-action-press');

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final action = destinations[selectedIndex].action;
    return SafeArea(
      top: false,
      minimum: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.only(
          left: compact ? theme.spacing.xs : theme.spacing.md,
          right: compact ? theme.spacing.xs : theme.spacing.md,
          bottom: compact ? theme.spacing.sm : theme.spacing.lg,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colors.primary,
                  borderRadius: BorderRadius.circular(
                    _NavigationMetrics.containerHeight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                    _NavigationMetrics.containerPadding,
                  ),
                  child: SizedBox(
                    height: _NavigationMetrics.containerHeight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final (index, destination) in destinations.indexed)
                          _NavigationItem(
                            index: index,
                            destination: destination,
                            selected: index == selectedIndex,
                            onPressed: () => onDestinationSelected(index),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              _NavigationActionSlot(action: action),
            ],
          ),
        ),
      ),
    );
  }
}

final class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.index,
    required this.destination,
    required this.selected,
    required this.onPressed,
  });

  final int index;
  final RudiNavigationDestination destination;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      selected: selected,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: theme.spacing.xs),
        child: RudiPressable(
          key: ValueKey('nav-$index'),
          semanticLabel: destination.label,
          onPressed: onPressed,
          builder: (context, state) => AnimatedScale(
            scale: state.pressed ? 0.9 : 1,
            duration: reduced ? Duration.zero : theme.motion.fast,
            curve: theme.motion.standardCurve,
            child: AnimatedContainer(
              duration: reduced ? Duration.zero : theme.motion.normal,
              curve: theme.motion.standardCurve,
              width: _NavigationMetrics.itemSize,
              height: _NavigationMetrics.itemSize,
              decoration: BoxDecoration(
                color: selected
                    ? theme.colors.background
                    : const Color(0x00000000),
                shape: BoxShape.circle,
                border: state.focused
                    ? Border.all(color: theme.colors.focus, width: 2)
                    : null,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: reduced ? Duration.zero : theme.motion.fast,
                  child: IconTheme(
                    key: ValueKey(selected),
                    data: IconThemeData(
                      color: selected
                          ? theme.colors.foreground
                          : theme.colors.onPrimary,
                      size: _NavigationMetrics.itemIconSize,
                    ),
                    child: selected
                        ? destination.selectedIcon ?? destination.icon
                        : destination.icon,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _NavigationActionSlot extends StatefulWidget {
  const _NavigationActionSlot({required this.action});

  final RudiNavigationAction? action;

  @override
  State<_NavigationActionSlot> createState() => _NavigationActionSlotState();
}

final class _NavigationActionSlotState extends State<_NavigationActionSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  RudiNavigationAction? _visibleAction;

  @override
  void initState() {
    super.initState();
    _visibleAction = widget.action;
    _controller =
        AnimationController(
          value: widget.action == null ? 0 : 1,
          duration: const Duration(milliseconds: 350),
          reverseDuration: const Duration(milliseconds: 180),
          vsync: this,
        )..addStatusListener((status) {
          if (status == AnimationStatus.dismissed && widget.action == null) {
            setState(() => _visibleAction = null);
          }
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motion = context.rudiTheme.motion;
    _controller
      ..duration = motion.normal
      ..reverseDuration = motion.fast;
  }

  @override
  void didUpdateWidget(_NavigationActionSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.action != null) {
      _visibleAction = widget.action;
      _controller.forward();
    } else if (oldWidget.action != null) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.duration = Duration.zero;
      _controller.reverseDuration = Duration.zero;
    }
    final curved = CurvedAnimation(
      parent: _controller,
      curve: context.rudiTheme.motion.standardCurve,
    );
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) => SizedBox(
        width: _NavigationMetrics.actionSlotWidth * curved.value,
        height: _NavigationMetrics.actionSize,
        child: ClipRect(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: curved.value,
            child: Opacity(
              opacity: curved.value,
              child: Transform.translate(
                offset: Offset(-56 * (1 - curved.value), 0),
                child: child,
              ),
            ),
          ),
        ),
      ),
      child: _visibleAction == null
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: _NavigationAction(action: _visibleAction!),
            ),
    );
  }
}

final class _NavigationAction extends StatelessWidget {
  const _NavigationAction({required this.action});

  final RudiNavigationAction action;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    Widget button = RudiPressable(
      semanticLabel: action.label,
      onPressed: action.onPressed,
      builder: (context, state) => AnimatedScale(
        scale: state.pressed ? 0.9 : 1,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : theme.motion.fast,
        child: Container(
          width: _NavigationMetrics.actionSize,
          height: _NavigationMetrics.actionSize,
          decoration: BoxDecoration(
            color: state.enabled ? theme.colors.accent : theme.colors.surface,
            shape: BoxShape.circle,
            border: state.focused
                ? Border.all(color: theme.colors.focus, width: 2)
                : null,
          ),
          child: Center(
            child: IconTheme(
              data: IconThemeData(
                color: state.enabled
                    ? theme.colors.onAccent
                    : theme.colors.mutedForeground,
                size: _NavigationMetrics.actionIconSize,
              ),
              child: action.icon,
            ),
          ),
        ),
      ),
    );
    if (action.pressProgress case final progress?) {
      button = ScaleTransition(
        key: RudiFloatingNavigationBar.actionPressKey,
        scale: Tween(begin: 1.0, end: 0.9).animate(progress),
        child: button,
      );
    }
    return button;
  }
}
