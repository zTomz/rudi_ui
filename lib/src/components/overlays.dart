import 'dart:async';

import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import 'actions.dart';
import 'icons.dart';

const _snackStackPeek = 12.0;

/// Semantic presentation used by a [RudiSnack].
enum RudiSnackVariant {
  /// Uses the active theme accent.
  standard,

  /// Uses the active theme accent with informational semantics.
  info,

  /// Uses the active theme error color.
  error,

  /// Uses the active theme's muted foreground color.
  debug,
}

/// Immutable description of a transient Rudi message.
@immutable
final class RudiSnack {
  /// Creates a transient message.
  const RudiSnack({
    required this.message,
    this.icon,
    this.accentColor,
    this.duration = const Duration(seconds: 4),
    this.actionLabel,
    this.onAction,
    this.maxLines = 1,
  }) : variant = RudiSnackVariant.standard;

  /// Creates an informational message with an info icon.
  const RudiSnack.info({
    required this.message,
    this.icon = const RudiGlyph(RudiGlyphType.info),
    this.accentColor,
    this.duration = const Duration(seconds: 4),
    this.actionLabel,
    this.onAction,
    this.maxLines = 1,
  }) : variant = RudiSnackVariant.info;

  /// Creates an error message with an error icon.
  const RudiSnack.error({
    required this.message,
    this.icon = const RudiGlyph(RudiGlyphType.error),
    this.accentColor,
    this.duration = const Duration(seconds: 4),
    this.actionLabel,
    this.onAction,
    this.maxLines = 1,
  }) : variant = RudiSnackVariant.error;

  /// Creates a visually muted diagnostic message.
  const RudiSnack.debug({
    required this.message,
    this.icon,
    this.accentColor,
    this.duration = const Duration(seconds: 4),
    this.actionLabel,
    this.onAction,
    this.maxLines = 1,
  }) : variant = RudiSnackVariant.debug;

  /// Visible message.
  final String message;

  /// Optional leading widget.
  final Widget? icon;

  /// Overrides the gradient, border, dot pattern and action-label color.
  ///
  /// Without an override, the selected [variant] resolves its semantic color
  /// from the active theme.
  final Color? accentColor;

  /// Semantic presentation selected by the constructor.
  final RudiSnackVariant variant;

  /// Display duration.
  final Duration duration;

  /// Optional action label.
  final String? actionLabel;

  /// Optional action callback.
  final VoidCallback? onAction;

  /// Maximum number of message lines.
  final int? maxLines;
}

/// Programmatic controller for a [RudiMessenger].
final class RudiMessengerController {
  RudiMessengerState? _state;

  /// Shows a transient message above any messages that are already visible.
  void show(RudiSnack snack) => _state?.show(snack);

  /// Dismisses the current message.
  void hideCurrent() => _state?.hideCurrent();

  /// Dismisses and removes all active messages.
  void clear() => _state?.clear();
}

/// Hosts transient messages above its child without Material's Scaffold.
final class RudiMessenger extends StatefulWidget {
  /// Creates a messenger host.
  const RudiMessenger({
    required this.child,
    this.controller,
    this.maxVisibleSnacks = 4,
    super.key,
  }) : assert(maxVisibleSnacks > 0);

  /// Content below transient messages.
  final Widget child;

  /// Optional external controller.
  final RudiMessengerController? controller;

  /// Maximum number of messages rendered in the visible stack.
  final int maxVisibleSnacks;

  /// Returns the closest messenger state.
  static RudiMessengerState of(BuildContext context) {
    final state = maybeOf(context);
    assert(state != null, 'No RudiMessenger found in context.');
    return state!;
  }

  /// Returns the closest messenger state, if present.
  static RudiMessengerState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<RudiMessengerState>();
  }

  @override
  State<RudiMessenger> createState() => RudiMessengerState();
}

/// Mutable state and imperative API for [RudiMessenger].
final class RudiMessengerState extends State<RudiMessenger> {
  final List<_SnackEntry> _snacks = [];
  final Map<int, Timer> _timers = {};
  int _nextSnackId = 0;

  /// Shows a transient message above any messages that are already visible.
  void show(RudiSnack snack) {
    final entry = _SnackEntry(id: _nextSnackId++, snack: snack);
    setState(() => _snacks.add(entry));
    _timers[entry.id] = Timer(snack.duration, () => _beginDismiss(entry.id));
  }

  /// Dismisses the newest visible message.
  void hideCurrent() {
    for (final entry in _snacks.reversed) {
      if (!entry.dismissing) {
        _beginDismiss(entry.id);
        return;
      }
    }
  }

  /// Dismisses all active messages.
  void clear() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    if (_snacks.isNotEmpty) setState(_snacks.clear);
  }

  void _beginDismiss(int id) {
    if (!mounted) return;
    _timers.remove(id)?.cancel();
    final index = _snacks.indexWhere((entry) => entry.id == id);
    if (index == -1 || _snacks[index].dismissing) return;
    final visibleStart = (_snacks.length - widget.maxVisibleSnacks)
        .clamp(0, _snacks.length)
        .toInt();
    if (index < visibleStart) {
      _remove(id);
      return;
    }
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);
    if (animationsDisabled) {
      _remove(id);
      return;
    }
    setState(() => _snacks[index] = _snacks[index].startDismissing());
    _timers[id] = Timer(context.rudiTheme.motion.fast, () => _remove(id));
  }

  void _remove(int id) {
    _timers.remove(id)?.cancel();
    if (!mounted) return;
    final index = _snacks.indexWhere((entry) => entry.id == id);
    if (index != -1) setState(() => _snacks.removeAt(index));
  }

  void _attachController(RudiMessengerController? controller) {
    if (controller != null) {
      controller._state = this;
    }
  }

  void _detachController(RudiMessengerController? controller) {
    if (controller?._state == this) {
      controller?._state = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _attachController(widget.controller);
  }

  @override
  void didUpdateWidget(RudiMessenger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detachController(oldWidget.controller);
      _attachController(widget.controller);
    }
  }

  @override
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _detachController(widget.controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);
    final visibleStart = (_snacks.length - widget.maxVisibleSnacks)
        .clamp(0, _snacks.length)
        .toInt();
    final visibleSnacks = _snacks.sublist(visibleStart);
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        PositionedDirectional(
          start: theme.spacing.md,
          end: theme.spacing.md,
          top: MediaQuery.viewPaddingOf(context).top + theme.spacing.md,
          bottom: MediaQuery.viewPaddingOf(context).bottom + theme.spacing.md,
          child: IgnorePointer(
            ignoring: _snacks.isEmpty,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                for (final (index, entry) in visibleSnacks.indexed)
                  AnimatedPositionedDirectional(
                    key: ValueKey(entry.id),
                    start: 0,
                    end: 0,
                    bottom:
                        _snackStackPeek * (visibleSnacks.length - index - 1),
                    duration: animationsDisabled
                        ? Duration.zero
                        : theme.motion.fast,
                    curve: theme.motion.standardCurve,
                    child: _AnimatedSnackEntry(
                      entry: entry,
                      depth: visibleSnacks.length - index - 1,
                      animationsDisabled: animationsDisabled,
                      onDismiss: () => _beginDismiss(entry.id),
                      onSwiped: () => _remove(entry.id),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

@immutable
final class _SnackEntry {
  const _SnackEntry({
    required this.id,
    required this.snack,
    this.dismissing = false,
  });

  final int id;
  final RudiSnack snack;
  final bool dismissing;

  _SnackEntry startDismissing() =>
      _SnackEntry(id: id, snack: snack, dismissing: true);
}

final class _AnimatedSnackEntry extends StatelessWidget {
  const _AnimatedSnackEntry({
    required this.entry,
    required this.depth,
    required this.animationsDisabled,
    required this.onDismiss,
    required this.onSwiped,
  });

  final _SnackEntry entry;
  final int depth;
  final bool animationsDisabled;
  final VoidCallback onDismiss;
  final VoidCallback onSwiped;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final duration = animationsDisabled ? Duration.zero : theme.motion.fast;
    return AnimatedScale(
      scale: 1 - depth * .018,
      alignment: Alignment.bottomCenter,
      duration: duration,
      curve: theme.motion.standardCurve,
      child: IgnorePointer(
        ignoring: depth != 0,
        child: ExcludeSemantics(
          excluding: depth != 0,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: entry.dismissing ? 0 : 1),
            duration: animationsDisabled
                ? Duration.zero
                : entry.dismissing
                ? theme.motion.fast
                : theme.motion.normal,
            curve: theme.motion.standardCurve,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 12),
                child: child,
              ),
            ),
            child: Dismissible(
              key: ValueKey('rudi-snack-${entry.id}'),
              direction: DismissDirection.down,
              resizeDuration: null,
              onDismissed: (_) => onSwiped(),
              child: Align(
                alignment: Alignment.center,
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: _RudiSnackView(
                    snack: entry.snack,
                    onDismiss: onDismiss,
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

final class _RudiSnackView extends StatelessWidget {
  const _RudiSnackView({required this.snack, required this.onDismiss});

  final RudiSnack snack;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final accentColor =
        snack.accentColor ??
        switch (snack.variant) {
          RudiSnackVariant.standard ||
          RudiSnackVariant.info => theme.colors.accent,
          RudiSnackVariant.error => theme.colors.error,
          RudiSnackVariant.debug => theme.colors.mutedForeground,
        };
    final radius = BorderRadius.circular(theme.radii.pill);
    final surfaceStart = Color.lerp(
      const Color(0xFF12151A),
      accentColor,
      theme.highContrast ? .22 : .16,
    )!;
    final borderColor = theme.highContrast
        ? theme.colors.onPrimary
        : accentColor.withValues(alpha: .46);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
            colors: [surfaceStart, const Color(0xFF171A1F)],
            stops: const [.02, .58],
          ),
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: borderColor,
            width: theme.highContrast ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: ExcludeSemantics(
                child: CustomPaint(
                  painter: _SnackDotPatternPainter(
                    color: accentColor,
                    textDirection: Directionality.of(context),
                  ),
                ),
              ),
            ),
            Padding(
              padding: snack.icon == null
                  ? EdgeInsets.symmetric(
                      horizontal: theme.spacing.md,
                      vertical: theme.spacing.sm + theme.spacing.xs,
                    )
                  : EdgeInsets.fromLTRB(
                      theme.spacing.sm,
                      theme.spacing.sm,
                      theme.spacing.md,
                      theme.spacing.sm,
                    ),
              child: Row(
                children: [
                  if (snack.icon != null) ...[
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconTheme(
                        data: IconThemeData(
                          color: theme.colors.onPrimary,
                          size: 18,
                        ),
                        child: Transform.scale(
                          scale: 1.08,
                          child: Center(child: snack.icon),
                        ),
                      ),
                    ),
                    SizedBox(width: theme.spacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      snack.message,
                      maxLines: snack.maxLines,
                      overflow: snack.maxLines == null
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: theme.text.body.copyWith(
                        color: theme.colors.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (snack.actionLabel case final label?) ...[
                    SizedBox(width: theme.spacing.sm),
                    RudiPressable(
                      onPressed: () {
                        snack.onAction?.call();
                        onDismiss();
                      },
                      builder: (context, state) => Padding(
                        padding: EdgeInsets.all(theme.spacing.sm),
                        child: Text(
                          label,
                          style: theme.text.label.copyWith(color: accentColor),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _SnackDotPatternPainter extends CustomPainter {
  const _SnackDotPatternPainter({
    required this.color,
    required this.textDirection,
  });

  final Color color;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 11.0;
    final patternWidth = size.width.clamp(0, 154).toDouble();
    final columnCount = (patternWidth / spacing).ceil();
    final rowCount = (size.height / spacing).ceil() + 1;
    final paint = Paint();

    for (var column = 0; column < columnCount; column++) {
      final progress = column / columnCount;
      final horizontalFade = (1 - progress) * (1 - progress);
      for (var row = 0; row < rowCount; row++) {
        final x = column * spacing + (row.isOdd ? spacing / 2 : 0);
        if (x > patternWidth) continue;
        final verticalProgress = ((row * spacing) / size.height - .5).abs();
        final verticalFade = (1 - verticalProgress * .72).clamp(0, 1);
        final opacity = .44 * horizontalFade * verticalFade;
        paint.color = color.withValues(alpha: opacity);
        final resolvedX = textDirection == TextDirection.ltr
            ? x
            : size.width - x;
        canvas.drawCircle(Offset(resolvedX, row * spacing), 1.35, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SnackDotPatternPainter oldDelegate) {
    return color != oldDelegate.color ||
        textDirection != oldDelegate.textDirection;
  }
}
