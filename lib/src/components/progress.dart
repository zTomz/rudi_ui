import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';

/// Creates a localized accessibility label for a duration value.
typedef RudiDurationLabelBuilder = String Function(Duration value);

/// A linear progress indicator with optional indeterminate animation.
final class RudiLinearProgress extends StatefulWidget {
  /// Creates a linear progress indicator.
  const RudiLinearProgress({
    this.value,
    this.semanticLabel,
    this.height = 8,
    super.key,
  }) : assert(value == null || (value >= 0 && value <= 1));

  /// Progress from zero to one, or null for an indeterminate indicator.
  final double? value;

  /// Optional accessibility label.
  final String? semanticLabel;

  /// Track height.
  final double height;

  @override
  State<RudiLinearProgress> createState() => _RudiLinearProgressState();
}

final class _RudiLinearProgressState extends State<RudiLinearProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.value == null) {
      unawaited(_controller.repeat());
    }
  }

  @override
  void didUpdateWidget(RudiLinearProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      unawaited(_controller.repeat());
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Semantics(
      label: widget.semanticLabel,
      value: widget.value == null ? null : '${(widget.value! * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radii.pill),
        child: ColoredBox(
          color: theme.colors.surface,
          child: SizedBox(
            height: widget.height,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final reduced = MediaQuery.disableAnimationsOf(context);
                final start = widget.value == null
                    ? (reduced ? 0.25 : _controller.value * 1.4 - 0.4)
                    : 0.0;
                final width = widget.value ?? 0.3;
                return CustomPaint(
                  painter: _LinearProgressPainter(
                    color: theme.colors.accent,
                    start: start,
                    width: width,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

final class _LinearProgressPainter extends CustomPainter {
  const _LinearProgressPainter({
    required this.color,
    required this.start,
    required this.width,
  });

  final Color color;
  final double start;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final left = start.clamp(0.0, 1.0) * size.width;
    final right = (start + width).clamp(0.0, 1.0) * size.width;
    canvas.drawRect(
      Rect.fromLTRB(left, 0, right, size.height),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_LinearProgressPainter oldDelegate) {
    return color != oldDelegate.color ||
        start != oldDelegate.start ||
        width != oldDelegate.width;
  }
}

/// A circular progress visualization.
final class RudiProgressRing extends StatelessWidget {
  /// Creates a progress ring.
  const RudiProgressRing({
    required this.value,
    this.child,
    this.size = 160,
    this.strokeWidth = 12,
    this.semanticLabel,
    super.key,
  }) : assert(value >= 0 && value <= 1);

  /// Progress from zero to one.
  final double value;

  /// Optional centered content.
  final Widget? child;

  /// Ring diameter.
  final double size;

  /// Ring stroke width.
  final double strokeWidth;

  /// Optional accessibility label.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Semantics(
      label: semanticLabel,
      value: '${(value * 100).round()}%',
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(
            value: value,
            track: theme.colors.surface,
            progress: theme.colors.accent,
            strokeWidth: strokeWidth,
          ),
          child: child == null ? null : Center(child: child),
        ),
      ),
    );
  }
}

final class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.track,
    required this.progress,
    required this.strokeWidth,
  });

  final double value;
  final Color track;
  final Color progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = strokeWidth / 2;
    final arcRect = rect.deflate(inset);
    final base = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2, false, base);
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      base
        ..color = progress
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return value != oldDelegate.value ||
        track != oldDelegate.track ||
        progress != oldDelegate.progress ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}

/// A tick-based progress visualization.
final class RudiTickProgress extends StatelessWidget {
  /// Creates a tick progress visualization.
  const RudiTickProgress({
    required this.value,
    this.tickCount = 32,
    this.size = 160,
    this.semanticLabel,
    super.key,
  }) : assert(value >= 0 && value <= 1),
       assert(tickCount > 0);

  /// Progress from zero to one.
  final double value;

  /// Number of ticks.
  final int tickCount;

  /// Visualization size.
  final double size;

  /// Optional accessibility label.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Semantics(
      label: semanticLabel,
      value: '${(value * 100).round()}%',
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _TickPainter(
            value: value,
            tickCount: tickCount,
            track: theme.colors.outline,
            progress: theme.colors.accent,
          ),
        ),
      ),
    );
  }
}

final class _TickPainter extends CustomPainter {
  const _TickPainter({
    required this.value,
    required this.tickCount,
    required this.track,
    required this.progress,
  });

  final double value;
  final int tickCount;
  final Color track;
  final Color progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    for (var index = 0; index < tickCount; index++) {
      final angle = -math.pi / 2 + index / tickCount * math.pi * 2;
      final active = index / tickCount <= value;
      final outer = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      final inner =
          center +
          Offset(math.cos(angle), math.sin(angle)) *
              (radius - (active ? 14 : 9));
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..color = active ? progress : track
          ..strokeWidth = active ? 4 : 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_TickPainter oldDelegate) {
    return value != oldDelegate.value ||
        tickCount != oldDelegate.tickCount ||
        track != oldDelegate.track ||
        progress != oldDelegate.progress;
  }
}

/// A scrollable ruler for selecting a bounded duration.
final class RudiDurationRuler extends StatefulWidget {
  /// Creates a duration ruler.
  const RudiDurationRuler({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.semanticLabel,
    required this.semanticValueBuilder,
    this.divisions,
    super.key,
  });

  /// Selected duration.
  final Duration value;

  /// Minimum selectable duration.
  final Duration min;

  /// Maximum selectable duration.
  final Duration max;

  /// Called while selection changes.
  final ValueChanged<Duration>? onChanged;

  /// Accessibility label.
  final String semanticLabel;

  /// Creates localized accessibility values for the selected duration.
  final RudiDurationLabelBuilder semanticValueBuilder;

  /// Optional number of discrete intervals.
  final int? divisions;

  @override
  State<RudiDurationRuler> createState() => _RudiDurationRulerState();
}

final class _RudiDurationRulerState extends State<RudiDurationRuler> {
  static const _tickSpacing = 14.0;

  late final ScrollController _scrollController;
  late int _currentIndex;
  double _scrollOffset = 0;
  bool _isSnapping = false;
  bool _isSyncing = false;

  int get _divisionCount {
    final explicit = widget.divisions;
    if (explicit != null) {
      return math.max(1, explicit);
    }
    final seconds = widget.max.inSeconds - widget.min.inSeconds;
    return math.max(1, seconds);
  }

  int _indexForValue(Duration value) {
    final range = widget.max.inMilliseconds - widget.min.inMilliseconds;
    if (range <= 0) {
      return 0;
    }
    final fraction = (value.inMilliseconds - widget.min.inMilliseconds) / range;
    return (fraction.clamp(0.0, 1.0) * _divisionCount).round();
  }

  Duration _valueForIndex(int index) {
    final normalized = index.clamp(0, _divisionCount) / _divisionCount;
    final range = widget.max.inMilliseconds - widget.min.inMilliseconds;
    return Duration(
      milliseconds: widget.min.inMilliseconds + (range * normalized).round(),
    );
  }

  double _offsetForIndex(int index) =>
      index.clamp(0, _divisionCount) * _tickSpacing;

  @override
  void initState() {
    super.initState();
    _currentIndex = _indexForValue(widget.value);
    _scrollOffset = _offsetForIndex(_currentIndex);
    _scrollController = ScrollController(initialScrollOffset: _scrollOffset)
      ..addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(RudiDurationRuler oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _indexForValue(widget.value);
    if (target == _currentIndex || !_scrollController.hasClients) {
      return;
    }
    _currentIndex = target;
    final offset = _offsetForIndex(target);
    _isSnapping = true;
    _isSyncing = true;
    unawaited(
      _scrollController
          .animateTo(
            offset,
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
          )
          .whenComplete(() {
            if (!mounted) {
              return;
            }
            _isSnapping = false;
            _isSyncing = false;
            setState(() => _scrollOffset = offset);
          }),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    final index = (_scrollController.offset / _tickSpacing).round().clamp(
      0,
      _divisionCount,
    );
    setState(() => _scrollOffset = _scrollController.offset);
    if (index == _currentIndex) {
      return;
    }
    _currentIndex = index;
    if (!_isSyncing && widget.onChanged != null) {
      unawaited(context.rudiTheme.feedback.selection());
      widget.onChanged!(_valueForIndex(index));
    }
  }

  void _snap() {
    if (_isSnapping ||
        !_scrollController.hasClients ||
        _scrollController.position.outOfRange) {
      return;
    }
    final target = _offsetForIndex(_currentIndex);
    if ((_scrollController.offset - target).abs() < 0.5) {
      return;
    }
    _isSnapping = true;
    unawaited(
      _scrollController
          .animateTo(
            target,
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
          )
          .whenComplete(() {
            if (!mounted) {
              return;
            }
            _isSnapping = false;
            setState(() => _scrollOffset = target);
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final currentValue = _valueForIndex(_currentIndex);
    final increasedValue = _valueForIndex(_currentIndex + 1);
    final decreasedValue = _valueForIndex(_currentIndex - 1);
    return Semantics(
      slider: true,
      enabled: widget.onChanged != null,
      label: widget.semanticLabel,
      value: widget.semanticValueBuilder(currentValue),
      increasedValue: widget.semanticValueBuilder(increasedValue),
      decreasedValue: widget.semanticValueBuilder(decreasedValue),
      onIncrease: widget.onChanged == null
          ? null
          : () => widget.onChanged!(increasedValue),
      onDecrease: widget.onChanged == null
          ? null
          : () => widget.onChanged!(decreasedValue),
      child: Opacity(
        opacity: widget.onChanged == null ? 0.48 : 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(theme.radii.lg),
          child: ColoredBox(
            color: theme.colors.primary,
            child: SizedBox(
              height: 72,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollEndNotification) {
                        _snap();
                      }
                      return false;
                    },
                    child: IgnorePointer(
                      ignoring: widget.onChanged == null,
                      child: Scrollable(
                        controller: _scrollController,
                        axisDirection: AxisDirection.right,
                        physics: const BouncingScrollPhysics(),
                        viewportBuilder: (context, position) {
                          return _RudiRulerViewport(
                            offset: position,
                            minScrollExtent: 0,
                            maxScrollExtent: _divisionCount * _tickSpacing,
                          );
                        },
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _RudiRulerPainter(
                        scrollOffset: _scrollOffset,
                        accentColor: theme.colors.accent,
                        majorTickColor: theme.colors.onPrimary,
                        tickColor: theme.colors.onPrimary.withAlpha(150),
                        tickSpacing: _tickSpacing,
                        divisionCount: _divisionCount,
                      ),
                    ),
                  ),
                  _RudiRulerEdgeGradient(
                    alignment: Alignment.centerLeft,
                    backgroundColor: theme.colors.primary,
                  ),
                  _RudiRulerEdgeGradient(
                    alignment: Alignment.centerRight,
                    backgroundColor: theme.colors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _RudiRulerViewport extends LeafRenderObjectWidget {
  const _RudiRulerViewport({
    required this.offset,
    required this.minScrollExtent,
    required this.maxScrollExtent,
  });

  final ViewportOffset offset;
  final double minScrollExtent;
  final double maxScrollExtent;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderRudiRulerViewport(
      offset: offset,
      minScrollExtent: minScrollExtent,
      maxScrollExtent: maxScrollExtent,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderRudiRulerViewport renderObject,
  ) {
    renderObject
      ..offset = offset
      ..minScrollExtent = minScrollExtent
      ..maxScrollExtent = maxScrollExtent;
  }
}

final class _RenderRudiRulerViewport extends RenderBox {
  _RenderRudiRulerViewport({
    required this._offset,
    required this._minScrollExtent,
    required this._maxScrollExtent,
  });

  ViewportOffset _offset;
  double _minScrollExtent;
  double _maxScrollExtent;

  set offset(ViewportOffset value) {
    if (identical(value, _offset)) {
      return;
    }
    _offset = value;
    markNeedsLayout();
  }

  set minScrollExtent(double value) {
    if (value == _minScrollExtent) {
      return;
    }
    _minScrollExtent = value;
    markNeedsLayout();
  }

  set maxScrollExtent(double value) {
    if (value == _maxScrollExtent) {
      return;
    }
    _maxScrollExtent = value;
    markNeedsLayout();
  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.biggest;
  }

  @override
  void performLayout() {
    _offset.applyViewportDimension(size.width);
    _offset.applyContentDimensions(_minScrollExtent, _maxScrollExtent);
  }

  @override
  bool hitTestSelf(Offset position) => true;
}

final class _RudiRulerPainter extends CustomPainter {
  const _RudiRulerPainter({
    required this.scrollOffset,
    required this.accentColor,
    required this.majorTickColor,
    required this.tickColor,
    required this.tickSpacing,
    required this.divisionCount,
  });

  final double scrollOffset;
  final Color accentColor;
  final Color majorTickColor;
  final Color tickColor;
  final double tickSpacing;
  final int divisionCount;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final selectedIndex = scrollOffset / tickSpacing;
    final clampedSelection = selectedIndex.clamp(0.0, divisionCount.toDouble());
    final firstVisible =
        (selectedIndex - size.width / tickSpacing / 2).floor() - 1;
    final lastVisible =
        (selectedIndex + size.width / tickSpacing / 2).ceil() + 1;
    for (var index = firstVisible; index <= lastVisible; index++) {
      if (index < 0 || index > divisionCount) {
        continue;
      }
      final selected = index == clampedSelection.round();
      final major = index % 5 == 0;
      final height = major ? 40.0 : 34.0;
      final width = selected ? 9.0 : 6.0;
      final color = selected
          ? accentColor
          : major
          ? majorTickColor
          : tickColor;
      final x = center.dx + (index - selectedIndex) * tickSpacing - width / 2;
      final rect = Rect.fromLTWH(x, center.dy - height / 2, width, height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(width / 2)),
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RudiRulerPainter oldDelegate) {
    return scrollOffset != oldDelegate.scrollOffset ||
        accentColor != oldDelegate.accentColor ||
        majorTickColor != oldDelegate.majorTickColor ||
        tickColor != oldDelegate.tickColor ||
        tickSpacing != oldDelegate.tickSpacing ||
        divisionCount != oldDelegate.divisionCount;
  }
}

final class _RudiRulerEdgeGradient extends StatelessWidget {
  const _RudiRulerEdgeGradient({
    required this.alignment,
    required this.backgroundColor,
  });

  final Alignment alignment;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final left = alignment == Alignment.centerLeft;
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: left ? Alignment.centerLeft : Alignment.centerRight,
              end: left ? Alignment.centerRight : Alignment.centerLeft,
              colors: [backgroundColor, backgroundColor.withAlpha(0)],
            ),
          ),
          child: const SizedBox(width: 56, height: double.infinity),
        ),
      ),
    );
  }
}
