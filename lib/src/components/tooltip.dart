import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import 'actions.dart';
import 'icons.dart';

/// A passive tooltip shown for hover, keyboard focus, or a long press.
///
/// Unlike [RudiInfoTooltip], tapping the child keeps activating the child.
final class RudiTooltip extends StatefulWidget {
  /// Creates a tooltip around an interactive child.
  const RudiTooltip({
    required this.message,
    required this.child,
    this.waitDuration = const Duration(milliseconds: 500),
    this.showDuration = const Duration(seconds: 2),
    this.maxWidth = 240,
    super.key,
  });

  /// Localized text displayed in the tooltip.
  final String message;

  /// Interactive content that owns its own semantics and activation.
  final Widget child;

  /// Hover delay before the tooltip appears.
  final Duration waitDuration;

  /// Maximum time the tooltip remains visible.
  final Duration showDuration;

  /// Maximum width of the tooltip bubble.
  final double maxWidth;

  @override
  State<RudiTooltip> createState() => _RudiTooltipState();
}

final class _RudiTooltipState extends State<RudiTooltip>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _controller = OverlayPortalController();
  Timer? _showTimer;
  Timer? _hideTimer;
  Rect _target = Rect.zero;
  late final AnimationController _animation =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 160),
        reverseDuration: const Duration(milliseconds: 100),
      )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed && _controller.isShowing) {
          _controller.hide();
        }
      });

  void _scheduleShow() {
    _showTimer?.cancel();
    _showTimer = Timer(widget.waitDuration, _show);
  }

  void _show() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      _target = box.localToGlobal(Offset.zero) & box.size;
    }
    final wasShowing = _controller.isShowing;
    if (!wasShowing) {
      _controller.show();
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.value = 1;
    } else if (!wasShowing) {
      unawaited(_animation.forward(from: 0));
    } else if (_animation.status == AnimationStatus.reverse) {
      unawaited(_animation.forward());
    }
    _hideTimer = Timer(widget.showDuration, _hide);
  }

  void _hide() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    if (!_controller.isShowing) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.value = 0;
    } else {
      unawaited(_animation.reverse());
    }
  }

  void _handleLongPress() {
    unawaited(context.rudiTheme.feedback.selection());
    _show();
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) => CustomSingleChildLayout(
        delegate: _RudiTooltipPositionDelegate(
          target: _target,
          margin: theme.spacing.md,
          gap: theme.spacing.xs,
        ),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _animation,
            curve: Curves.easeOutCubic,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.maxWidth.clamp(
                0,
                MediaQuery.sizeOf(context).width - theme.spacing.md * 2,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.primary,
                borderRadius: BorderRadius.circular(theme.radii.md),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.sm,
                  vertical: theme.spacing.xs,
                ),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    widget.message,
                    style: theme.text.caption.copyWith(
                      color: theme.colors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => _scheduleShow(),
        onExit: (_) => _hide(),
        child: Focus(
          canRequestFocus: false,
          onFocusChange: (focused) => focused ? _show() : _hide(),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            excludeFromSemantics: true,
            onLongPress: _handleLongPress,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

final class _RudiTooltipPositionDelegate extends SingleChildLayoutDelegate {
  const _RudiTooltipPositionDelegate({
    required this.target,
    required this.margin,
    required this.gap,
  });

  final Rect target;
  final double margin;
  final double gap;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.loose(constraints.biggest);

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final maxX = math.max(margin, size.width - margin - childSize.width);
    final x = (target.center.dx - childSize.width / 2).clamp(margin, maxX);
    final above = target.top - gap - childSize.height;
    final y = above >= margin
        ? above
        : math.min(
            target.bottom + gap,
            size.height - margin - childSize.height,
          );
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_RudiTooltipPositionDelegate oldDelegate) =>
      target != oldDelegate.target ||
      margin != oldDelegate.margin ||
      gap != oldDelegate.gap;
}

/// A compact, anchored explanation opened from an information button.
final class RudiInfoTooltip extends StatefulWidget {
  /// Creates an information tooltip.
  const RudiInfoTooltip({
    required this.message,
    required this.semanticLabel,
    this.child,
    this.maxWidth = 240,
    this.duration = const Duration(seconds: 2),
    super.key,
  });

  /// Explanation displayed in the tooltip.
  final String message;

  /// Accessible label for the information button.
  final String semanticLabel;

  /// Optional trigger content. Defaults to Rudi's information glyph.
  final Widget? child;

  /// Maximum width of the tooltip bubble.
  final double maxWidth;

  /// Time before the tooltip closes automatically.
  final Duration duration;

  @override
  State<RudiInfoTooltip> createState() => _RudiInfoTooltipState();
}

final class _RudiInfoTooltipState extends State<RudiInfoTooltip>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();
  Timer? _dismissTimer;
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    reverseDuration: const Duration(milliseconds: 140),
  )..addStatusListener(_handleAnimationStatus);

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && _controller.isShowing) {
      _controller.hide();
    }
  }

  void _toggle() {
    if (_controller.isShowing) {
      _hide();
      return;
    }
    _controller.show();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.value = 1;
    } else {
      unawaited(_animation.forward(from: 0));
    }
    _dismissTimer?.cancel();
    _dismissTimer = Timer(widget.duration, _hide);
  }

  void _hide() {
    _dismissTimer?.cancel();
    if (!_controller.isShowing) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.value = 0;
    } else {
      unawaited(_animation.reverse());
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return TapRegion(
      groupId: this,
      onTapOutside: (_) => _hide(),
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (context) => UnconstrainedBox(
          alignment: isRtl ? Alignment.topLeft : Alignment.topRight,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: isRtl ? Alignment.topLeft : Alignment.topRight,
            followerAnchor: isRtl
                ? Alignment.bottomLeft
                : Alignment.bottomRight,
            offset: const Offset(0, -8),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.82, end: 1).animate(
                  CurvedAnimation(
                    parent: _animation,
                    curve: Curves.easeOutBack,
                    reverseCurve: Curves.easeInCubic,
                  ),
                ),
                alignment: isRtl ? Alignment.bottomLeft : Alignment.bottomRight,
                child: TapRegion(
                  groupId: this,
                  child: Semantics(
                    liveRegion: true,
                    container: true,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: widget.maxWidth.clamp(
                          0,
                          MediaQuery.sizeOf(context).width -
                              (theme.spacing.md * 2),
                        ),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colors.primary,
                          borderRadius: BorderRadius.circular(theme.radii.lg),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: theme.spacing.md,
                            vertical: theme.spacing.sm,
                          ),
                          child: Text(
                            widget.message,
                            style: theme.text.body.copyWith(
                              color: theme.colors.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        child: CompositedTransformTarget(
          link: _layerLink,
          child: RudiPressable.scale(
            semanticLabel: widget.semanticLabel,
            onPressed: _toggle,
            child: SizedBox.square(
              dimension: 40,
              child: Center(
                child:
                    widget.child ??
                    RudiGlyph(
                      RudiGlyphType.info,
                      size: 20,
                      color: theme.colors.mutedForeground,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
