import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Spacing values used throughout Rudi UI.
@immutable
final class RudiSpacing {
  /// Creates a spacing scale.
  const RudiSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  /// The standard Rudi spacing scale.
  static const standard = RudiSpacing(
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
    xxl: 48,
  );

  /// Extra-small spacing.
  final double xs;

  /// Small spacing.
  final double sm;

  /// Medium spacing.
  final double md;

  /// Large spacing.
  final double lg;

  /// Extra-large spacing.
  final double xl;

  /// Double-extra-large spacing.
  final double xxl;
}

/// Corner radii used throughout Rudi UI.
@immutable
final class RudiRadii {
  /// Creates a radius scale.
  const RudiRadii({
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.pill,
  });

  /// The standard Rudi radius scale.
  static const standard = RudiRadii(sm: 4, md: 8, lg: 16, xl: 24, pill: 999);

  /// Small corner radius.
  final double sm;

  /// Medium corner radius.
  final double md;

  /// Large corner radius.
  final double lg;

  /// Extra-large corner radius.
  final double xl;

  /// Fully rounded corner radius.
  final double pill;
}

/// Motion durations, curves, and spring behavior used by Rudi UI.
@immutable
final class RudiMotion {
  /// Creates a motion specification.
  const RudiMotion({
    required this.fast,
    required this.normal,
    required this.slow,
    required this.standardCurve,
    required this.emphasizedCurve,
    required this.spring,
  });

  /// The standard Rudi motion specification.
  static const standard = RudiMotion(
    fast: Duration(milliseconds: 120),
    normal: Duration(milliseconds: 220),
    slow: Duration(milliseconds: 360),
    standardCurve: Curves.easeOutCubic,
    emphasizedCurve: Curves.easeOutBack,
    spring: SpringDescription(mass: 1, stiffness: 420, damping: 30),
  );

  /// A motion-free specification for reduced-motion environments.
  static const reduced = RudiMotion(
    fast: Duration.zero,
    normal: Duration.zero,
    slow: Duration.zero,
    standardCurve: Curves.linear,
    emphasizedCurve: Curves.linear,
    spring: SpringDescription(mass: 1, stiffness: 1000, damping: 1000),
  );

  /// Duration for immediate state transitions.
  final Duration fast;

  /// Duration for common component transitions.
  final Duration normal;

  /// Duration for larger layout transitions.
  final Duration slow;

  /// Default transition curve.
  final Curve standardCurve;

  /// Curve for prominent transitions.
  final Curve emphasizedCurve;

  /// Spring used for direct-manipulation transitions.
  final SpringDescription spring;
}

/// Width breakpoints used for adaptive Rudi UI layouts.
abstract final class RudiBreakpoints {
  /// Width at which compact layouts become medium layouts.
  static const compact = 600.0;

  /// Width at which medium layouts become expanded layouts.
  static const expanded = 1024.0;

  /// Maximum width for readable page content.
  static const contentMaxWidth = 840.0;
}
