import 'dart:async';

import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';

/// Visual interaction state supplied by [RudiPressable].
@immutable
final class RudiInteractionState {
  /// Creates an interaction state.
  const RudiInteractionState({
    required this.enabled,
    required this.hovered,
    required this.focused,
    required this.pressed,
  });

  /// Whether the control can be activated.
  final bool enabled;

  /// Whether a mouse pointer is hovering over the control.
  final bool hovered;

  /// Whether the control has keyboard focus.
  final bool focused;

  /// Whether a pointer currently presses the control.
  final bool pressed;
}

/// Builds the content of a [RudiPressable] from its interaction state.
typedef RudiPressableBuilder =
    Widget Function(BuildContext context, RudiInteractionState state);

/// A platform-neutral accessible interaction primitive.
final class RudiPressable extends StatefulWidget {
  /// Creates a pressable control.
  const RudiPressable({
    required this.builder,
    this.onPressed,
    this.onLongPress,
    this.semanticLabel,
    this.autofocus = false,
    this.enableFeedback = true,
    this.cursor = SystemMouseCursors.click,
    super.key,
  });

  /// Builds the control for the current interaction state.
  final RudiPressableBuilder builder;

  /// Called when the control is activated.
  final VoidCallback? onPressed;

  /// Called after a long press.
  final VoidCallback? onLongPress;

  /// Accessibility label for controls without visible text.
  final String? semanticLabel;

  /// Whether the control requests focus initially.
  final bool autofocus;

  /// Whether the active [RudiFeedbackPolicy] may emit feedback.
  final bool enableFeedback;

  /// Mouse cursor used while enabled.
  final MouseCursor cursor;

  @override
  State<RudiPressable> createState() => _RudiPressableState();
}

final class _RudiPressableState extends State<RudiPressable> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _activate() {
    if (!_enabled) {
      return;
    }
    if (widget.enableFeedback) {
      unawaited(context.rudiTheme.feedback.selection());
    }
    widget.onPressed!();
  }

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = RudiInteractionState(
      enabled: _enabled,
      hovered: _hovered,
      focused: _focused,
      pressed: _pressed,
    );
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: _enabled,
        autofocus: widget.autofocus,
        mouseCursor: _enabled ? widget.cursor : SystemMouseCursors.basic,
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _enabled ? _activate : null,
          onLongPress: _enabled ? widget.onLongPress : null,
          onTapDown: _enabled ? (_) => _setPressed(true) : null,
          onTapUp: _enabled ? (_) => _setPressed(false) : null,
          onTapCancel: _enabled ? () => _setPressed(false) : null,
          child: widget.builder(context, state),
        ),
      ),
    );
  }
}

/// Visual variants supported by [RudiButton].
enum RudiButtonVariant {
  /// Highest-emphasis action.
  primary,

  /// Lower-emphasis action.
  subtle,

  /// Destructive action.
  destructive,
}

/// A labeled Rudi UI action button.
final class RudiButton extends StatelessWidget {
  /// Creates a labeled button.
  const RudiButton({
    required this.label,
    required this.onPressed,
    this.leading,
    this.variant = RudiButtonVariant.primary,
    this.loading = false,
    this.expand = false,
    this.autofocus = false,
    super.key,
  });

  /// Visible action label.
  final String label;

  /// Called when activated, or null when disabled.
  final VoidCallback? onPressed;

  /// Optional widget before the label.
  final Widget? leading;

  /// Visual emphasis.
  final RudiButtonVariant variant;

  /// Whether an indeterminate progress mark replaces [leading].
  final bool loading;

  /// Whether the button fills the available width.
  final bool expand;

  /// Whether the button requests focus initially.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final colors = theme.colors;
    final (background, foreground) = switch (variant) {
      RudiButtonVariant.primary => (colors.primary, colors.onPrimary),
      RudiButtonVariant.subtle => (colors.surface, colors.foreground),
      RudiButtonVariant.destructive => (colors.error, colors.onError),
    };
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : theme.motion.fast;

    return RudiPressable(
      onPressed: loading ? null : onPressed,
      autofocus: autofocus,
      builder: (context, state) {
        final scale = state.pressed ? 0.97 : 1.0;
        final borderColor = state.focused ? colors.focus : background;
        return AnimatedScale(
          scale: scale,
          duration: duration,
          curve: theme.motion.standardCurve,
          child: AnimatedOpacity(
            opacity: state.enabled ? 1 : 0.48,
            duration: duration,
            child: Container(
              constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
              width: expand ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacing.lg,
                vertical: theme.spacing.sm,
              ),
              decoration: BoxDecoration(
                color: state.hovered
                    ? Color.lerp(background, foreground, 0.08)
                    : background,
                borderRadius: BorderRadius.circular(theme.radii.lg),
                border: Border.all(
                  color: borderColor,
                  width: state.focused ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    _RudiLoadingMark(color: foreground)
                  else if (leading != null)
                    IconTheme(
                      data: IconThemeData(color: foreground, size: 20),
                      child: leading!,
                    ),
                  if (loading || leading != null)
                    SizedBox(width: theme.spacing.sm),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: theme.text.label.copyWith(color: foreground),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// An icon-only action button.
final class RudiIconButton extends StatelessWidget {
  /// Creates an icon button.
  const RudiIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.size = 48,
    super.key,
  });

  /// Icon displayed by the button.
  final Widget icon;

  /// Required accessibility label.
  final String semanticLabel;

  /// Called when activated, or null when disabled.
  final VoidCallback? onPressed;

  /// Square touch-target size. Values below 48 are clamped to 48.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final targetSize = size < 48 ? 48.0 : size;
    return RudiPressable(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      builder: (context, state) {
        return AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : theme.motion.fast,
          width: targetSize,
          height: targetSize,
          decoration: BoxDecoration(
            color: state.pressed || state.hovered
                ? theme.colors.surface
                : const Color(0x00000000),
            borderRadius: BorderRadius.circular(theme.radii.pill),
            border: state.focused
                ? Border.all(color: theme.colors.focus, width: 2)
                : null,
          ),
          child: Center(
            child: IconTheme(
              data: IconThemeData(
                color: state.enabled
                    ? theme.colors.foreground
                    : theme.colors.mutedForeground,
                size: 24,
              ),
              child: icon,
            ),
          ),
        );
      },
    );
  }
}

/// A button that activates only after being held for [duration].
final class RudiHoldToConfirm extends StatefulWidget {
  /// Creates a hold-to-confirm action.
  const RudiHoldToConfirm({
    required this.label,
    required this.onConfirmed,
    this.duration = const Duration(milliseconds: 1200),
    super.key,
  });

  /// Visible action label.
  final String label;

  /// Called once the hold completes.
  final VoidCallback? onConfirmed;

  /// Required hold duration.
  final Duration duration;

  @override
  State<RudiHoldToConfirm> createState() => _RudiHoldToConfirmState();
}

final class _RudiHoldToConfirmState extends State<RudiHoldToConfirm>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(
        vsync: this,
        duration: widget.duration,
      )..addStatusListener((status) {
        if (status == AnimationStatus.completed && widget.onConfirmed != null) {
          unawaited(context.rudiTheme.feedback.confirmation());
          widget.onConfirmed!();
          _controller.value = 0;
        }
      });

  @override
  void didUpdateWidget(RudiHoldToConfirm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    if (widget.onConfirmed == null) {
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      widget.onConfirmed!();
      return;
    }
    _controller.forward(from: 0);
  }

  void _cancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Semantics(
      button: true,
      enabled: widget.onConfirmed != null,
      label: widget.label,
      onTap: widget.onConfirmed,
      child: Listener(
        onPointerDown: (_) => _start(),
        onPointerUp: (_) => _cancel(),
        onPointerCancel: (_) => _cancel(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              constraints: const BoxConstraints(minHeight: 52, minWidth: 120),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(theme.radii.lg),
                color: theme.colors.surface,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: _controller.value,
                      child: ColoredBox(color: theme.colors.error),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.spacing.lg,
                      vertical: theme.spacing.md,
                    ),
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: theme.text.label.copyWith(
                        color: theme.colors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A horizontally swiped confirmation control.
final class RudiSwipeAction extends StatefulWidget {
  /// Creates a swipe action.
  const RudiSwipeAction({
    required this.label,
    required this.thumb,
    required this.onConfirmed,
    this.threshold = 0.82,
    super.key,
  });

  /// Visible instruction label.
  final String label;

  /// Widget displayed inside the draggable thumb.
  final Widget thumb;

  /// Called after the drag passes [threshold].
  final VoidCallback? onConfirmed;

  /// Fraction of available drag distance required to confirm.
  final double threshold;

  @override
  State<RudiSwipeAction> createState() => _RudiSwipeActionState();
}

final class _RudiSwipeActionState extends State<RudiSwipeAction> {
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        const thumbSize = 56.0;
        final distance = mathMax(0, constraints.maxWidth - thumbSize);
        return Semantics(
          button: true,
          enabled: widget.onConfirmed != null,
          label: widget.label,
          onTap: widget.onConfirmed,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: theme.colors.surface,
              borderRadius: BorderRadius.circular(theme.radii.pill),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 72),
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.text.label,
                  ),
                ),
                PositionedDirectional(
                  start: _progress * distance,
                  child: GestureDetector(
                    onHorizontalDragUpdate: widget.onConfirmed == null
                        ? null
                        : (details) {
                            final delta =
                                Directionality.of(context) == TextDirection.ltr
                                ? details.delta.dx
                                : -details.delta.dx;
                            setState(() {
                              _progress = (_progress + delta / distance).clamp(
                                0.0,
                                1.0,
                              );
                            });
                          },
                    onHorizontalDragEnd: widget.onConfirmed == null
                        ? null
                        : (_) {
                            if (_progress >= widget.threshold) {
                              unawaited(theme.feedback.confirmation());
                              widget.onConfirmed!();
                            }
                            setState(() => _progress = 0);
                          },
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colors.primary,
                        borderRadius: BorderRadius.circular(theme.radii.pill),
                      ),
                      child: IconTheme(
                        data: IconThemeData(color: theme.colors.onPrimary),
                        child: widget.thumb,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

double mathMax(double first, double second) => first > second ? first : second;

final class _RudiLoadingMark extends StatefulWidget {
  const _RudiLoadingMark({required this.color});

  final Color color;

  @override
  State<_RudiLoadingMark> createState() => _RudiLoadingMarkState();
}

final class _RudiLoadingMarkState extends State<_RudiLoadingMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 18,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.rotate(
          angle: _controller.value * 6.283185307179586,
          child: CustomPaint(painter: _LoadingPainter(widget.color)),
        ),
      ),
    );
  }
}

final class _LoadingPainter extends CustomPainter {
  const _LoadingPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Offset.zero & size,
      0,
      4.4,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_LoadingPainter oldDelegate) => color != oldDelegate.color;
}
