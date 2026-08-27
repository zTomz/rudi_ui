import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'feedback.dart';
import 'tokens.dart';

/// Semantic colors used by every Rudi UI component.
@immutable
final class RudiColorScheme {
  /// Creates a semantic color scheme.
  const RudiColorScheme({
    required this.background,
    required this.foreground,
    required this.mutedForeground,
    required this.surface,
    required this.surfaceContainer,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.error,
    required this.onError,
    required this.outline,
    required this.scrim,
    required this.focus,
  });

  /// Page background color.
  final Color background;

  /// Primary content color.
  final Color foreground;

  /// Secondary content color.
  final Color mutedForeground;

  /// Component surface color.
  final Color surface;

  /// Raised or grouped surface color.
  final Color surfaceContainer;

  /// Primary action background color.
  final Color primary;

  /// Content color placed on [primary].
  final Color onPrimary;

  /// Accent and selection color.
  final Color accent;

  /// Content color placed on [accent].
  final Color onAccent;

  /// Error and destructive action color.
  final Color error;

  /// Content color placed on [error].
  final Color onError;

  /// Borders and separators.
  final Color outline;

  /// Modal barrier color.
  final Color scrim;

  /// Keyboard focus indication color.
  final Color focus;

  /// Returns a copy with selected values replaced.
  RudiColorScheme copyWith({
    Color? background,
    Color? foreground,
    Color? mutedForeground,
    Color? surface,
    Color? surfaceContainer,
    Color? primary,
    Color? onPrimary,
    Color? accent,
    Color? onAccent,
    Color? error,
    Color? onError,
    Color? outline,
    Color? scrim,
    Color? focus,
  }) {
    return RudiColorScheme(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      surface: surface ?? this.surface,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      outline: outline ?? this.outline,
      scrim: scrim ?? this.scrim,
      focus: focus ?? this.focus,
    );
  }

  /// Interpolates between two color schemes.
  static RudiColorScheme lerp(
    RudiColorScheme first,
    RudiColorScheme second,
    double t,
  ) {
    Color blend(Color a, Color b) => Color.lerp(a, b, t)!;
    return RudiColorScheme(
      background: blend(first.background, second.background),
      foreground: blend(first.foreground, second.foreground),
      mutedForeground: blend(first.mutedForeground, second.mutedForeground),
      surface: blend(first.surface, second.surface),
      surfaceContainer: blend(first.surfaceContainer, second.surfaceContainer),
      primary: blend(first.primary, second.primary),
      onPrimary: blend(first.onPrimary, second.onPrimary),
      accent: blend(first.accent, second.accent),
      onAccent: blend(first.onAccent, second.onAccent),
      error: blend(first.error, second.error),
      onError: blend(first.onError, second.onError),
      outline: blend(first.outline, second.outline),
      scrim: blend(first.scrim, second.scrim),
      focus: blend(first.focus, second.focus),
    );
  }
}

/// Typography roles used by Rudi UI.
@immutable
final class RudiTextTheme {
  /// Creates a typography theme.
  const RudiTextTheme({
    required this.display,
    required this.headline,
    required this.title,
    required this.body,
    required this.label,
    required this.caption,
  });

  /// Creates the system-font Rudi typography.
  factory RudiTextTheme.system(Color color) {
    return RudiTextTheme(
      display: TextStyle(
        color: color,
        fontSize: 40,
        height: 1.1,
        fontWeight: FontWeight.w700,
      ),
      headline: TextStyle(
        color: color,
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
      title: TextStyle(
        color: color,
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ),
      body: TextStyle(
        color: color,
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w400,
      ),
      label: TextStyle(
        color: color,
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
      caption: TextStyle(
        color: color,
        fontSize: 13,
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Large display text.
  final TextStyle display;

  /// Section headline text.
  final TextStyle headline;

  /// Component title text.
  final TextStyle title;

  /// Body text.
  final TextStyle body;

  /// Interactive control label text.
  final TextStyle label;

  /// Supporting caption text.
  final TextStyle caption;

  /// Returns a copy with selected values replaced.
  RudiTextTheme copyWith({
    TextStyle? display,
    TextStyle? headline,
    TextStyle? title,
    TextStyle? body,
    TextStyle? label,
    TextStyle? caption,
  }) {
    return RudiTextTheme(
      display: display ?? this.display,
      headline: headline ?? this.headline,
      title: title ?? this.title,
      body: body ?? this.body,
      label: label ?? this.label,
      caption: caption ?? this.caption,
    );
  }

  /// Interpolates between two text themes.
  static RudiTextTheme lerp(
    RudiTextTheme first,
    RudiTextTheme second,
    double t,
  ) {
    TextStyle blend(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return RudiTextTheme(
      display: blend(first.display, second.display),
      headline: blend(first.headline, second.headline),
      title: blend(first.title, second.title),
      body: blend(first.body, second.body),
      label: blend(first.label, second.label),
      caption: blend(first.caption, second.caption),
    );
  }
}

/// Immutable configuration consumed by Rudi UI components.
@immutable
final class RudiThemeData {
  /// Creates a Rudi theme.
  const RudiThemeData({
    required this.brightness,
    required this.colors,
    required this.text,
    this.spacing = RudiSpacing.standard,
    this.radii = RudiRadii.standard,
    this.motion = RudiMotion.standard,
    this.feedback = const RudiFeedbackPolicy(),
    this.highContrast = false,
  });

  /// Creates the official light Rudi theme.
  factory RudiThemeData.light({
    Color accent = const Color(0xFF128FE2),
    bool highContrast = false,
    RudiFeedbackPolicy feedback = const RudiFeedbackPolicy(),
  }) {
    const background = Color(0xFFFAFAF7);
    final safeAccent = _contrastSafe(accent, background);
    final foreground = highContrast
        ? const Color(0xFF000000)
        : const Color(0xFF141314);
    final colors = RudiColorScheme(
      background: background,
      foreground: foreground,
      mutedForeground: const Color(0xFF626064),
      surface: const Color(0xFFECEAEC),
      surfaceContainer: const Color(0xFFF3F1F3),
      primary: const Color(0xFF242224),
      onPrimary: const Color(0xFFFFFFFF),
      accent: safeAccent,
      onAccent: _foregroundFor(safeAccent),
      error: const Color(0xFFB91C1C),
      onError: const Color(0xFFFFFFFF),
      outline: highContrast ? const Color(0xFF141314) : const Color(0xFFB8B5B9),
      scrim: const Color(0x8A000000),
      focus: safeAccent,
    );
    return RudiThemeData(
      brightness: Brightness.light,
      colors: colors,
      text: RudiTextTheme.system(foreground),
      feedback: feedback,
      highContrast: highContrast,
    );
  }

  /// Creates the official dark Rudi theme.
  factory RudiThemeData.dark({
    Color accent = const Color(0xFF43A9EB),
    bool highContrast = false,
    RudiFeedbackPolicy feedback = const RudiFeedbackPolicy(),
  }) {
    const background = Color(0xFF111214);
    final safeAccent = _contrastSafe(accent, background);
    final foreground = highContrast
        ? const Color(0xFFFFFFFF)
        : const Color(0xFFF2F4F5);
    final colors = RudiColorScheme(
      background: background,
      foreground: foreground,
      mutedForeground: const Color(0xFFB4B7BB),
      surface: const Color(0xFF24262A),
      surfaceContainer: const Color(0xFF1C1E21),
      primary: const Color(0xFF33363B),
      onPrimary: const Color(0xFFF2F4F5),
      accent: safeAccent,
      onAccent: _foregroundFor(safeAccent),
      error: const Color(0xFFF87171),
      onError: const Color(0xFF450A0A),
      outline: highContrast ? const Color(0xFFFFFFFF) : const Color(0xFF555960),
      scrim: const Color(0xB3000000),
      focus: safeAccent,
    );
    return RudiThemeData(
      brightness: Brightness.dark,
      colors: colors,
      text: RudiTextTheme.system(foreground),
      feedback: feedback,
      highContrast: highContrast,
    );
  }

  /// Theme brightness.
  final Brightness brightness;

  /// Semantic colors.
  final RudiColorScheme colors;

  /// Typography roles.
  final RudiTextTheme text;

  /// Spacing scale.
  final RudiSpacing spacing;

  /// Corner radii.
  final RudiRadii radii;

  /// Motion specification.
  final RudiMotion motion;

  /// Optional tactile and audible feedback policy.
  final RudiFeedbackPolicy feedback;

  /// Whether stronger visual differentiation is requested.
  final bool highContrast;

  /// Returns a copy with selected values replaced.
  RudiThemeData copyWith({
    Brightness? brightness,
    RudiColorScheme? colors,
    RudiTextTheme? text,
    RudiSpacing? spacing,
    RudiRadii? radii,
    RudiMotion? motion,
    RudiFeedbackPolicy? feedback,
    bool? highContrast,
  }) {
    return RudiThemeData(
      brightness: brightness ?? this.brightness,
      colors: colors ?? this.colors,
      text: text ?? this.text,
      spacing: spacing ?? this.spacing,
      radii: radii ?? this.radii,
      motion: motion ?? this.motion,
      feedback: feedback ?? this.feedback,
      highContrast: highContrast ?? this.highContrast,
    );
  }

  /// Interpolates between two themes.
  static RudiThemeData lerp(
    RudiThemeData first,
    RudiThemeData second,
    double t,
  ) {
    return RudiThemeData(
      brightness: t < 0.5 ? first.brightness : second.brightness,
      colors: RudiColorScheme.lerp(first.colors, second.colors, t),
      text: RudiTextTheme.lerp(first.text, second.text, t),
      spacing: t < 0.5 ? first.spacing : second.spacing,
      radii: t < 0.5 ? first.radii : second.radii,
      motion: t < 0.5 ? first.motion : second.motion,
      feedback: t < 0.5 ? first.feedback : second.feedback,
      highContrast: t < 0.5 ? first.highContrast : second.highContrast,
    );
  }
}

/// Supplies [RudiThemeData] to descendant widgets.
final class RudiTheme extends InheritedTheme {
  /// Creates a Rudi theme scope.
  const RudiTheme({required this.data, required super.child, super.key});

  /// Theme data exposed by this scope.
  final RudiThemeData data;

  /// Returns the closest theme or throws when none exists.
  static RudiThemeData of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No RudiTheme found in context.');
    return result!;
  }

  /// Returns the closest theme, if one exists.
  static RudiThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RudiTheme>()?.data;
  }

  @override
  bool updateShouldNotify(RudiTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return identical(child, this) ? child : RudiTheme(data: data, child: child);
  }
}

/// Animates changes between Rudi themes.
final class AnimatedRudiTheme extends ImplicitlyAnimatedWidget {
  /// Creates an animated theme scope.
  const AnimatedRudiTheme({
    required this.data,
    required this.child,
    super.duration = const Duration(milliseconds: 220),
    super.curve = Curves.easeOutCubic,
    super.key,
  });

  /// Target theme data.
  final RudiThemeData data;

  /// Widget below the theme.
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedRudiTheme> createState() =>
      _AnimatedRudiThemeState();
}

final class _AnimatedRudiThemeState
    extends AnimatedWidgetBaseState<AnimatedRudiTheme> {
  Tween<RudiThemeData>? _data;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _data =
        visitor(
              _data,
              widget.data,
              (dynamic value) =>
                  _RudiThemeDataTween(begin: value as RudiThemeData),
            )
            as Tween<RudiThemeData>?;
  }

  @override
  Widget build(BuildContext context) {
    return RudiTheme(data: _data!.evaluate(animation), child: widget.child);
  }
}

final class _RudiThemeDataTween extends Tween<RudiThemeData> {
  _RudiThemeDataTween({super.begin});

  @override
  RudiThemeData lerp(double t) => RudiThemeData.lerp(begin!, end!, t);
}

/// Convenient access to the active Rudi theme.
extension RudiThemeBuildContext on BuildContext {
  /// The active Rudi theme.
  RudiThemeData get rudiTheme => RudiTheme.of(this);
}

Color _foregroundFor(Color background) {
  return background.computeLuminance() > 0.42
      ? const Color(0xFF141314)
      : const Color(0xFFFFFFFF);
}

Color _contrastSafe(Color color, Color background) {
  const minimumContrast = 4.5;
  if (_contrastRatio(color, background) >= minimumContrast) {
    return color;
  }
  final target = background.computeLuminance() > 0.5
      ? const Color(0xFF000000)
      : const Color(0xFFFFFFFF);
  for (var step = 1; step <= 100; step++) {
    final candidate = Color.lerp(color, target, step / 100)!;
    if (_contrastRatio(candidate, background) >= minimumContrast) {
      return candidate;
    }
  }
  return target;
}

double _contrastRatio(Color first, Color second) {
  final lighter = math.max(first.computeLuminance(), second.computeLuminance());
  final darker = math.min(first.computeLuminance(), second.computeLuminance());
  return (lighter + 0.05) / (darker + 0.05);
}
