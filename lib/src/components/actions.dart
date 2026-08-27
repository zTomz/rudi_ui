import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/physics.dart';
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
                borderRadius: BorderRadius.circular(theme.radii.pill),
                border: state.focused
                    ? Border.all(color: borderColor, width: 2)
                    : null,
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
    this.icon,
    this.duration = const Duration(milliseconds: 1600),
    this.semanticHint,
    this.onHapticPulse,
    this.onHapticCompleted,
    super.key,
  });

  /// Visible action label.
  final String label;

  /// Called once the hold completes.
  final VoidCallback? onConfirmed;

  /// Optional icon displayed before [label].
  final Widget? icon;

  /// Required hold duration.
  final Duration duration;

  /// Localized accessibility instruction.
  final String? semanticHint;

  /// Called repeatedly with increasing progress while the control is held.
  final ValueChanged<double>? onHapticPulse;

  /// Called once when the hold completes.
  final VoidCallback? onHapticCompleted;

  @override
  State<RudiHoldToConfirm> createState() => _RudiHoldToConfirmState();
}

final class _RudiHoldToConfirmState extends State<RudiHoldToConfirm>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    reverseDuration: const Duration(milliseconds: 240),
  )..addStatusListener(_handleStatus);
  Timer? _hapticTimer;
  bool _isHolding = false;
  bool _isCompleted = false;

  void _handleStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed ||
        !_isHolding ||
        _isCompleted ||
        widget.onConfirmed == null) {
      return;
    }
    _isHolding = false;
    _isCompleted = true;
    _hapticTimer?.cancel();
    widget.onHapticCompleted?.call();
    unawaited(context.rudiTheme.feedback.confirmation());
    widget.onConfirmed!();
    if (!mounted) {
      return;
    }
    setState(() {});
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 0;
      setState(() => _isCompleted = false);
      return;
    }
    _controller
        .animateBack(
          0,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        )
        .whenCompleteOrCancel(() {
          if (mounted) {
            setState(() => _isCompleted = false);
          }
        });
  }

  @override
  void didUpdateWidget(RudiHoldToConfirm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
  }

  @override
  void dispose() {
    _hapticTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleHapticPulse() {
    _hapticTimer?.cancel();
    _hapticTimer = Timer(_pulseIntervalForProgress(_controller.value), () {
      if (!_isHolding || _isCompleted) {
        return;
      }
      widget.onHapticPulse?.call(_curvedHoldProgress(_controller.value));
      _scheduleHapticPulse();
    });
  }

  void _start() {
    if (widget.onConfirmed == null || _isHolding || _isCompleted) {
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _isHolding = true;
      _controller.value = 1;
      _handleStatus(AnimationStatus.completed);
      return;
    }
    _controller.stop();
    _isHolding = true;
    widget.onHapticPulse?.call(_curvedHoldProgress(_controller.value));
    _scheduleHapticPulse();
    unawaited(_controller.forward());
  }

  void _cancel() {
    if (!_isHolding || _isCompleted) {
      return;
    }
    _isHolding = false;
    _hapticTimer?.cancel();
    unawaited(
      _controller.animateBack(
        0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Semantics(
      container: true,
      button: true,
      enabled: widget.onConfirmed != null && !_isCompleted,
      label: widget.label,
      hint: widget.semanticHint,
      onLongPress: widget.onConfirmed != null && !_isCompleted
          ? _handleSemanticHold
          : null,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final idleColor = Color.lerp(
              theme.colors.error,
              theme.colors.surface,
              theme.brightness == Brightness.light ? 0.78 : 0.58,
            )!;
            final progress = _curvedHoldProgress(_controller.value);
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: !_isCompleted && widget.onConfirmed != null
                      ? (_) => _start()
                      : null,
                  onTapUp: !_isCompleted && widget.onConfirmed != null
                      ? (_) => _cancel()
                      : null,
                  onTapCancel: !_isCompleted && widget.onConfirmed != null
                      ? _cancel
                      : null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: ColoredBox(
                      color: idleColor,
                      child: SizedBox(
                        key: const ValueKey('hold-to-confirm-button'),
                        height: 56,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _RudiHoldContent(
                              label: widget.label,
                              icon: widget.icon,
                              color: theme.colors.error,
                            ),
                            FractionallySizedBox(
                              alignment: AlignmentDirectional.centerStart,
                              widthFactor: progress,
                              child: ClipRect(
                                child: DecoratedBox(
                                  key: const ValueKey('hold-to-confirm-fill'),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.lerp(
                                          idleColor,
                                          theme.colors.error,
                                          0.72,
                                        )!,
                                        theme.colors.error,
                                      ],
                                    ),
                                  ),
                                  child: OverflowBox(
                                    alignment: AlignmentDirectional.centerStart,
                                    minWidth: width,
                                    maxWidth: width,
                                    child: SizedBox(
                                      width: width,
                                      child: _RudiHoldContent(
                                        label: widget.label,
                                        icon: widget.icon,
                                        color: theme.colors.onError,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _handleSemanticHold() {
    if (_isCompleted || widget.onConfirmed == null) {
      return;
    }
    _isHolding = true;
    _controller.value = 1;
    _handleStatus(AnimationStatus.completed);
  }
}

double _curvedHoldProgress(double progress) =>
    Curves.easeOutQuad.transform(progress.clamp(0.0, 1.0));

Duration _pulseIntervalForProgress(double progress) {
  final smoothed = Curves.easeInOut.transform(progress.clamp(0.0, 1.0));
  return Duration(milliseconds: 180 - (100 * smoothed).round());
}

final class _RudiHoldContent extends StatelessWidget {
  const _RudiHoldContent({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final Widget? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: color, size: 20),
              child: icon!,
            ),
            SizedBox(width: theme.spacing.sm),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: theme.text.label.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
    this.height = 72,
    this.threshold = 1,
    this.enabled = true,
    this.loading = false,
    this.completed,
    this.semanticHint,
    this.completedSemanticHint,
    this.loadingSemanticHint,
    this.hapticsEnabled = true,
    this.onHapticPulse,
    this.onHapticCompleted,
    super.key,
  }) : assert(height >= 48),
       assert(threshold > 0 && threshold <= 1);

  /// Visible instruction label.
  final String label;

  /// Widget displayed inside the draggable thumb.
  final Widget thumb;

  /// Called after the drag passes [threshold].
  final VoidCallback? onConfirmed;

  /// Overall control height.
  final double height;

  /// Fraction of available drag distance required to confirm.
  final double threshold;

  /// Whether the control accepts interaction.
  final bool enabled;

  /// Whether the thumb displays a loading indicator.
  final bool loading;

  /// Optional externally controlled completion state.
  final bool? completed;

  /// Localized instruction announced before completion.
  final String? semanticHint;

  /// Localized completion announcement.
  final String? completedSemanticHint;

  /// Localized loading announcement.
  final String? loadingSemanticHint;

  /// Whether haptic callbacks are active.
  final bool hapticsEnabled;

  /// Called repeatedly with current drag progress.
  final ValueChanged<double>? onHapticPulse;

  /// Called once when completion begins.
  final VoidCallback? onHapticCompleted;

  @override
  State<RudiSwipeAction> createState() => _RudiSwipeActionState();
}

final class _RudiSwipeActionState extends State<RudiSwipeAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: widget.completed == true ? 1 : 0,
  );
  Timer? _hapticTimer;
  bool _internalCompleted = false;
  bool _isCompleting = false;
  bool _isDragging = false;
  bool _callbackPending = false;
  double _dragProgress = 0;
  double _dragTravel = 1;

  bool get _isCompleted => widget.completed ?? _internalCompleted;

  bool get _canInteract =>
      widget.onConfirmed != null &&
      widget.enabled &&
      !widget.loading &&
      !_isCompleted &&
      !_isCompleting;

  @override
  void didUpdateWidget(RudiSwipeAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.completed != null &&
        widget.completed != oldWidget.completed &&
        !_isCompleting) {
      _callbackPending = false;
      _isDragging = false;
      _hapticTimer?.cancel();
      if (widget.completed!) {
        unawaited(_controller.animateTo(1, curve: Curves.easeOutCubic));
      } else {
        _springBack();
      }
    }
    if ((!widget.enabled || widget.loading) && _isDragging) {
      _isDragging = false;
      _hapticTimer?.cancel();
      _isCompleted ? _controller.value = 1 : _springBack();
    }
  }

  @override
  void dispose() {
    _hapticTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleHapticPulse() {
    _hapticTimer?.cancel();
    _hapticTimer = Timer(_pulseIntervalForProgress(_dragProgress), () {
      if (!_isDragging) {
        return;
      }
      widget.onHapticPulse?.call(_dragProgress);
      _scheduleHapticPulse();
    });
  }

  void _complete({double velocity = 0}) {
    if (!_canInteract) {
      return;
    }
    _hapticTimer?.cancel();
    if (widget.hapticsEnabled) {
      widget.onHapticCompleted?.call();
    }
    setState(() {
      if (widget.completed == null) {
        _internalCompleted = true;
      } else {
        _isCompleting = true;
      }
      _callbackPending = true;
    });
    _controller
        .animateTo(
          1,
          duration: Duration(
            milliseconds: (220 / math.max(1, velocity.abs())).round(),
          ),
          curve: Curves.easeOutCubic,
        )
        .whenCompleteOrCancel(_finishCompletion);
  }

  void _finishCompletion() {
    if (!mounted || !_callbackPending) {
      return;
    }
    _callbackPending = false;
    widget.onConfirmed?.call();
    if (!mounted) {
      return;
    }
    if (widget.completed != null) {
      setState(() => _isCompleting = false);
    } else {
      _resetAfterCompletion();
    }
  }

  void _resetAfterCompletion() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 0;
      setState(() => _internalCompleted = false);
      return;
    }
    _controller
        .animateWith(
          SpringSimulation(
            const SpringDescription(mass: 1, stiffness: 440, damping: 34),
            _controller.value,
            0,
            0,
            snapToEnd: true,
          ),
        )
        .whenCompleteOrCancel(() {
          if (mounted) {
            setState(() => _internalCompleted = false);
          }
        });
  }

  void _springBack({double velocity = 0}) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 0;
      return;
    }
    unawaited(
      _controller.animateWith(
        SpringSimulation(
          const SpringDescription(mass: 1, stiffness: 440, damping: 34),
          _controller.value,
          0,
          velocity,
          snapToEnd: true,
        ),
      ),
    );
  }

  void _startDrag(DragStartDetails details, double width, double handleSize) {
    final progress = _controller.value.clamp(0.0, 1.0);
    final foregroundRight = _RudiSwipeMetrics.foregroundRight(
      width: width,
      progress: progress,
      handleSize: handleSize,
    );
    if (details.localPosition.dx >
        foregroundRight + _RudiSwipeMetrics.idleInset) {
      return;
    }
    _controller.stop();
    _isDragging = true;
    _dragProgress = progress;
    _dragTravel = math.max(
      1,
      width - handleSize - (_RudiSwipeMetrics.idleInset * 2),
    );
    if (widget.hapticsEnabled) {
      widget.onHapticPulse?.call(progress);
      _scheduleHapticPulse();
    }
  }

  void _updateDrag(DragUpdateDetails details) {
    if (!_isDragging) {
      return;
    }
    _dragProgress = (_dragProgress + details.delta.dx / _dragTravel).clamp(
      0.0,
      1.0,
    );
    _controller.value = _dragProgress;
  }

  void _endDrag(DragEndDetails details) {
    if (!_isDragging) {
      return;
    }
    _isDragging = false;
    _hapticTimer?.cancel();
    final velocity = ((details.primaryVelocity ?? 0) / _dragTravel).clamp(
      -3.0,
      3.0,
    );
    if (_dragProgress >= widget.threshold) {
      _complete(velocity: velocity);
    } else {
      _springBack(velocity: velocity);
    }
  }

  void _cancelDrag() {
    if (!_isDragging) {
      return;
    }
    _isDragging = false;
    _hapticTimer?.cancel();
    _springBack();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final handleSize = widget.height - (_RudiSwipeMetrics.idleInset * 2);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Semantics(
          container: true,
          button: true,
          enabled: _canInteract,
          label: widget.label,
          hint: _isCompleted || _isCompleting
              ? widget.completedSemanticHint
              : widget.loading
              ? widget.loadingSemanticHint
              : widget.semanticHint,
          onTap: _canInteract ? _complete : null,
          child: ExcludeSemantics(
            child: Opacity(
              opacity: widget.enabled ? 1 : 0.48,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final progress = _controller.value.clamp(0.0, 1.0);
                  final width = constraints.maxWidth;
                  final foregroundInset =
                      _RudiSwipeMetrics.idleInset * (1 - progress);
                  final foregroundHeight =
                      widget.height - (foregroundInset * 2);
                  final thumbRight = _RudiSwipeMetrics.foregroundRight(
                    width: width,
                    progress: progress,
                    handleSize: handleSize,
                  );
                  final thumbLeft = thumbRight - handleSize;
                  final foregroundRight =
                      thumbRight + (_RudiSwipeMetrics.idleInset * progress);
                  final foregroundWidth = foregroundRight - foregroundInset;
                  final foregroundTextWidth = thumbRight - foregroundInset;
                  final iconLeft =
                      thumbLeft +
                      handleSize / 2 -
                      _RudiSwipeMetrics.iconSize / 2;
                  final labelStyle = theme.text.label.copyWith(
                    fontWeight: FontWeight.w600,
                  );

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: _canInteract
                        ? (details) => _startDrag(details, width, handleSize)
                        : null,
                    onHorizontalDragUpdate: _canInteract ? _updateDrag : null,
                    onHorizontalDragEnd: _canInteract ? _endDrag : null,
                    onHorizontalDragCancel: _canInteract ? _cancelDrag : null,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.height / 2),
                      child: ColoredBox(
                        color: theme.colors.primary,
                        child: SizedBox(
                          height: widget.height,
                          width: double.infinity,
                          child: Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              Center(
                                child: Text(
                                  widget.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: labelStyle.copyWith(
                                    color: theme.colors.onPrimary,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: foregroundInset,
                                top: foregroundInset,
                                width: foregroundWidth,
                                height: foregroundHeight,
                                child: DecoratedBox(
                                  key: const ValueKey('swipe-foreground'),
                                  decoration: BoxDecoration(
                                    color: theme.colors.onPrimary,
                                    borderRadius: BorderRadius.circular(
                                      foregroundHeight / 2,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: thumbLeft,
                                top: _RudiSwipeMetrics.idleInset,
                                width: handleSize,
                                height: handleSize,
                                child: DecoratedBox(
                                  key: const ValueKey('swipe-thumb'),
                                  decoration: BoxDecoration(
                                    color: theme.colors.onPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: foregroundInset,
                                top: foregroundInset,
                                width: foregroundTextWidth,
                                height: foregroundHeight,
                                child: ClipRRect(
                                  key: const ValueKey(
                                    'swipe-foreground-text-clip',
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    foregroundHeight / 2,
                                  ),
                                  child: OverflowBox(
                                    alignment: Alignment.centerLeft,
                                    minWidth: width,
                                    maxWidth: width,
                                    minHeight: widget.height,
                                    maxHeight: widget.height,
                                    child: Transform.translate(
                                      offset: Offset(-foregroundInset, 0),
                                      child: SizedBox(
                                        width: width,
                                        height: widget.height,
                                        child: Center(
                                          child: Text(
                                            widget.label,
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
                                            softWrap: false,
                                            style: labelStyle.copyWith(
                                              color: theme.colors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: thumbLeft,
                                top: _RudiSwipeMetrics.idleInset,
                                width: handleSize,
                                height: handleSize,
                                child: ClipOval(
                                  key: const ValueKey('swipe-thumb-fade'),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colors.onPrimary.withAlpha(0),
                                          theme.colors.onPrimary,
                                        ],
                                        stops: const [0, 0.375],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: iconLeft,
                                top:
                                    (widget.height -
                                        _RudiSwipeMetrics.iconSize) /
                                    2,
                                child: SizedBox.square(
                                  dimension: _RudiSwipeMetrics.iconSize,
                                  child: widget.loading
                                      ? _RudiLoadingMark(
                                          color: theme.colors.primary,
                                        )
                                      : IconTheme(
                                          data: IconThemeData(
                                            color: theme.colors.primary,
                                            size: _RudiSwipeMetrics.iconSize,
                                          ),
                                          child: widget.thumb,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

abstract final class _RudiSwipeMetrics {
  static const idleInset = 8.0;
  static const iconSize = 24.0;

  static double foregroundRight({
    required double width,
    required double progress,
    required double handleSize,
  }) {
    final travel = math.max(0, width - handleSize - (idleInset * 2));
    return idleInset + handleSize + (travel * progress);
  }
}

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
