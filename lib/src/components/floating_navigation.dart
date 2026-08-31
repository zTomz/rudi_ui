import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import 'actions.dart';
import 'navigation.dart';

/// Compact floating navigation with one continuous selection indicator.
/// Labels remain available to assistive technology; use RudiNavigationBar
/// instead when visible text labels are needed.
final class const RudiFloatingNavigationBar({
  required final List<RudiNavigationDestination> destinations,
  required final int selectedIndex,
  required final ValueChanged<int> onDestinationSelected,
  final Color? backgroundColor,
  final Color? indicatorColor,
  final Color? unselectedColor,
  final Color? selectedColor,
  super.key,
}) extends StatelessWidget {
  this
    : assert(destinations.length >= 2 && destinations.length <= 5),
      assert(selectedIndex >= 0 && selectedIndex < destinations.length);

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return SizedBox(
      width: destinations.length * 64.0 + 12,
      height: 68,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.colors.foreground,
          borderRadius: .circular(44),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff000000).withValues(alpha: .12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const .all(6),
          child: LayoutBuilder(
            builder: (context, bounds) {
              final slot = bounds.maxWidth / destinations.length;
              final rtl = Directionality.of(context) == TextDirection.rtl;
              final visualIndex = rtl
                  ? destinations.length - selectedIndex - 1
                  : selectedIndex;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: reduced
                        ? Duration.zero
                        : const Duration(milliseconds: 360),
                    curve: Curves.easeOutQuart,
                    left: visualIndex * slot + 4,
                    top: 0,
                    bottom: 0,
                    width: slot - 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: indicatorColor ?? theme.colors.background,
                        borderRadius: .circular(40),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (final (index, destination) in destinations.indexed)
                        Expanded(
                          child: Semantics(
                            selected: index == selectedIndex,
                            child: RudiPressable(
                              key: ValueKey('nav-$index'),
                              semanticLabel: destination.label,
                              onPressed: () => onDestinationSelected(index),
                              builder: (context, state) => AnimatedScale(
                                scale: state.pressed ? .9 : 1,
                                duration: reduced
                                    ? Duration.zero
                                    : theme.motion.fast,
                                curve: theme.motion.standardCurve,
                                child: Container(
                                  height: 56,
                                  alignment: .center,
                                  decoration: BoxDecoration(
                                    borderRadius: .circular(40),
                                    border: state.focused
                                        ? Border.all(
                                            color: theme.colors.accent,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: TweenAnimationBuilder<Color?>(
                                    tween: ColorTween(
                                      end: index == selectedIndex
                                          ? selectedColor ?? theme.colors.accent
                                          : unselectedColor ??
                                                theme.colors.background,
                                    ),
                                    duration: reduced
                                        ? Duration.zero
                                        : theme.motion.fast,
                                    builder: (context, color, child) =>
                                        IconTheme(
                                          data: IconThemeData(
                                            color: color,
                                            size: 26,
                                          ),
                                          child: child!,
                                        ),
                                    child: index == selectedIndex
                                        ? destination.selectedIcon ??
                                              destination.icon
                                        : destination.icon,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
