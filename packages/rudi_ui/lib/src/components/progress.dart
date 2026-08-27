import 'dart:async';
import 'dart:math' as math;

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

/// A continuous ruler for selecting a bounded duration.
final class RudiDurationRuler extends StatelessWidget {
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

  Duration _valueForFraction(double fraction) {
    var normalized = fraction.clamp(0.0, 1.0);
    if (divisions case final count?) {
      normalized = (normalized * count).round() / count;
    }
    final range = max.inMilliseconds - min.inMilliseconds;
    return Duration(
      milliseconds: min.inMilliseconds + (range * normalized).round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final range = max.inMilliseconds - min.inMilliseconds;
    final fraction = (value.inMilliseconds - min.inMilliseconds) / range;
    void update(Offset localPosition, double width) {
      if (onChanged == null || width <= 0) {
        return;
      }
      final directionalFraction =
          Directionality.of(context) == TextDirection.ltr
          ? localPosition.dx / width
          : 1 - localPosition.dx / width;
      onChanged!(_valueForFraction(directionalFraction));
    }

    return Semantics(
      slider: true,
      enabled: onChanged != null,
      label: semanticLabel,
      value: semanticValueBuilder(value),
      increasedValue: semanticValueBuilder(_valueForFraction(fraction + 0.05)),
      decreasedValue: semanticValueBuilder(_valueForFraction(fraction - 0.05)),
      onIncrease: onChanged == null
          ? null
          : () => onChanged!(_valueForFraction(fraction + 0.05)),
      onDecrease: onChanged == null
          ? null
          : () => onChanged!(_valueForFraction(fraction - 0.05)),
      child: SizedBox(
        height: 64,
        child: LayoutBuilder(
          builder: (context, constraints) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) =>
                update(details.localPosition, constraints.maxWidth),
            onHorizontalDragUpdate: (details) =>
                update(details.localPosition, constraints.maxWidth),
            child: CustomPaint(
              painter: _RulerPainter(
                fraction: fraction,
                divisions: divisions ?? 20,
                track: theme.colors.outline,
                active: theme.colors.accent,
                direction: Directionality.of(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _RulerPainter extends CustomPainter {
  const _RulerPainter({
    required this.fraction,
    required this.divisions,
    required this.track,
    required this.active,
    required this.direction,
  });

  final double fraction;
  final int divisions;
  final Color track;
  final Color active;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final baseline = size.height * 0.7;
    for (var index = 0; index <= divisions; index++) {
      final normalized = index / divisions;
      final directional = direction == TextDirection.ltr
          ? normalized
          : 1 - normalized;
      final x = directional * size.width;
      final major = index % 5 == 0;
      canvas.drawLine(
        Offset(x, baseline - (major ? 22 : 12)),
        Offset(x, baseline),
        Paint()
          ..color = normalized <= fraction ? active : track
          ..strokeWidth = major ? 3 : 2
          ..strokeCap = StrokeCap.round,
      );
    }
    final thumbFraction = direction == TextDirection.ltr
        ? fraction
        : 1 - fraction;
    canvas.drawCircle(
      Offset(thumbFraction * size.width, baseline),
      9,
      Paint()..color = active,
    );
  }

  @override
  bool shouldRepaint(_RulerPainter oldDelegate) {
    return fraction != oldDelegate.fraction ||
        divisions != oldDelegate.divisions ||
        track != oldDelegate.track ||
        active != oldDelegate.active ||
        direction != oldDelegate.direction;
  }
}
