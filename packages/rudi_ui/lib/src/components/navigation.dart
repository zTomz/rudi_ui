import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import '../foundation/tokens.dart';
import 'actions.dart';

/// Destination metadata consumed by [RudiNavigationBar].
@immutable
final class RudiNavigationDestination {
  /// Creates a navigation destination.
  const RudiNavigationDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  /// Unselected icon.
  final Widget icon;

  /// Accessible and visible label.
  final String label;

  /// Optional selected icon.
  final Widget? selectedIcon;
}

/// Optional prominent action displayed by a navigation bar.
@immutable
final class RudiNavigationAction {
  /// Creates a navigation action.
  const RudiNavigationAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  /// Action icon.
  final Widget icon;

  /// Accessibility label.
  final String label;

  /// Called when activated.
  final VoidCallback? onPressed;
}

/// An adaptive Rudi destination bar.
final class RudiNavigationBar extends StatelessWidget {
  /// Creates a navigation bar.
  const RudiNavigationBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.action,
    this.axis = Axis.horizontal,
    this.showLabels = true,
    super.key,
  }) : assert(destinations.length >= 2),
       assert(selectedIndex >= 0 && selectedIndex < destinations.length);

  /// Available destinations.
  final List<RudiNavigationDestination> destinations;

  /// Currently selected destination index.
  final int selectedIndex;

  /// Called when a destination is selected.
  final ValueChanged<int> onDestinationSelected;

  /// Optional prominent action.
  final RudiNavigationAction? action;

  /// Layout direction.
  final Axis axis;

  /// Whether destination labels are visually shown.
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final items = <Widget>[
      for (var index = 0; index < destinations.length; index++)
        _RudiNavigationItem(
          destination: destinations[index],
          selected: index == selectedIndex,
          showLabel: showLabels,
          onPressed: () => onDestinationSelected(index),
        ),
    ];
    if (action case final value?) {
      final actionWidget = RudiIconButton(
        icon: value.icon,
        semanticLabel: value.label,
        onPressed: value.onPressed,
        size: 64,
      );
      final insertionIndex = (items.length / 2).ceil();
      items.insert(insertionIndex, actionWidget);
    }

    return SafeArea(
      top: axis == Axis.vertical,
      left: axis == Axis.horizontal,
      right: axis == Axis.horizontal,
      bottom: axis == Axis.horizontal,
      minimum: EdgeInsets.all(theme.spacing.sm),
      child: Container(
        padding: EdgeInsets.all(theme.spacing.xs),
        decoration: BoxDecoration(
          color: theme.colors.surfaceContainer,
          borderRadius: BorderRadius.circular(theme.radii.xl),
          border: Border.all(color: theme.colors.outline),
        ),
        child: axis == Axis.horizontal
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: items.map((item) => Expanded(child: item)).toList(),
              )
            : Column(mainAxisSize: MainAxisSize.min, children: items),
      ),
    );
  }
}

final class _RudiNavigationItem extends StatelessWidget {
  const _RudiNavigationItem({
    required this.destination,
    required this.selected,
    required this.showLabel,
    required this.onPressed,
  });

  final RudiNavigationDestination destination;
  final bool selected;
  final bool showLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Semantics(
      selected: selected,
      label: destination.label,
      child: RudiPressable(
        onPressed: onPressed,
        semanticLabel: destination.label,
        builder: (context, state) => AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : theme.motion.fast,
          constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.sm,
            vertical: theme.spacing.xs,
          ),
          decoration: BoxDecoration(
            color: selected || state.hovered
                ? theme.colors.surface
                : const Color(0x00000000),
            borderRadius: BorderRadius.circular(theme.radii.lg),
            border: state.focused
                ? Border.all(color: theme.colors.focus, width: 2)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconTheme(
                data: IconThemeData(
                  color: selected
                      ? theme.colors.accent
                      : theme.colors.foreground,
                  size: 24,
                ),
                child: selected
                    ? destination.selectedIcon ?? destination.icon
                    : destination.icon,
              ),
              if (showLabel) ...[
                SizedBox(height: theme.spacing.xs),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.text.caption.copyWith(
                    color: selected
                        ? theme.colors.accent
                        : theme.colors.foreground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Switches between bottom and side navigation using available width.
final class RudiNavigationShell extends StatelessWidget {
  /// Creates an adaptive navigation shell.
  const RudiNavigationShell({
    required this.body,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.action,
    super.key,
  });

  /// Active destination content.
  final Widget body;

  /// Available destinations.
  final List<RudiNavigationDestination> destinations;

  /// Active destination index.
  final int selectedIndex;

  /// Called when a destination is selected.
  final ValueChanged<int> onDestinationSelected;

  /// Optional prominent navigation action.
  final RudiNavigationAction? action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final expanded = constraints.maxWidth >= RudiBreakpoints.expanded;
        final navigation = RudiNavigationBar(
          destinations: destinations,
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          action: action,
          axis: expanded ? Axis.vertical : Axis.horizontal,
          showLabels: constraints.maxWidth >= RudiBreakpoints.compact,
        );
        if (expanded) {
          return Row(
            children: [
              navigation,
              Expanded(child: body),
            ],
          );
        }
        return Column(
          children: [
            Expanded(child: body),
            navigation,
          ],
        );
      },
    );
  }
}
