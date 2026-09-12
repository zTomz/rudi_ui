import 'package:flutter/widgets.dart';

/// A destination displayed by [RudiFloatingNavigationBar].
@immutable
final class RudiNavigationDestination {
  /// Creates a floating-navigation destination.
  const RudiNavigationDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.action,
  });

  /// Icon shown while this destination is not selected.
  final Widget icon;

  /// Accessible label for this destination.
  final String label;

  /// Optional icon shown while this destination is selected.
  final Widget? selectedIcon;

  /// Optional contextual action displayed beside the selected destination.
  final RudiNavigationAction? action;
}

/// Contextual action displayed beside a floating navigation bar.
@immutable
final class RudiNavigationAction {
  /// Creates a contextual navigation action.
  const RudiNavigationAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.pressProgress,
  });

  /// Action icon.
  final Widget icon;

  /// Accessible action label.
  final String label;

  /// Called when the action is activated, or null when disabled.
  final VoidCallback? onPressed;

  /// Optional external 0–1 press animation used by previews or tutorials.
  final Animation<double>? pressProgress;
}
