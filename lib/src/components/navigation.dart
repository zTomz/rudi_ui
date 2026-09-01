import 'package:flutter/widgets.dart';

/// A destination displayed by [RudiFloatingNavigationBar].
@immutable
final class RudiNavigationDestination {
  /// Creates a floating-navigation destination.
  const RudiNavigationDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  /// Icon shown while this destination is not selected.
  final Widget icon;

  /// Accessible label for this destination.
  final String label;

  /// Optional icon shown while this destination is selected.
  final Widget? selectedIcon;
}
