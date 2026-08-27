import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';

/// Built-in interface glyphs used by Rudi UI.
enum RudiGlyphType {
  /// Close or dismiss.
  close,

  /// Confirmation checkmark.
  check,

  /// Directional chevron.
  chevron,

  /// Information marker.
  info,

  /// Error marker.
  error,
}

/// A small, dependency-free Rudi interface glyph.
final class RudiGlyph extends StatelessWidget {
  /// Creates a painted glyph.
  const RudiGlyph(this.type, {this.size = 24, this.color, super.key});

  /// Glyph to draw.
  final RudiGlyphType type;

  /// Square glyph size.
  final double size;

  /// Explicit color, or the active icon/theme color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor =
        color ??
        IconTheme.of(context).color ??
        RudiTheme.maybeOf(context)?.colors.foreground ??
        const Color(0xFF141314);
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RudiGlyphPainter(type: type, color: resolvedColor),
      ),
    );
  }
}

final class _RudiGlyphPainter extends CustomPainter {
  const _RudiGlyphPainter({required this.type, required this.color});

  final RudiGlyphType type;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final path = Path();
    switch (type) {
      case RudiGlyphType.close:
        path
          ..moveTo(size.width * 0.25, size.height * 0.25)
          ..lineTo(size.width * 0.75, size.height * 0.75)
          ..moveTo(size.width * 0.75, size.height * 0.25)
          ..lineTo(size.width * 0.25, size.height * 0.75);
      case RudiGlyphType.check:
        path
          ..moveTo(size.width * 0.18, size.height * 0.52)
          ..lineTo(size.width * 0.42, size.height * 0.74)
          ..lineTo(size.width * 0.82, size.height * 0.28);
      case RudiGlyphType.chevron:
        path
          ..moveTo(size.width * 0.34, size.height * 0.2)
          ..lineTo(size.width * 0.66, size.height * 0.5)
          ..lineTo(size.width * 0.34, size.height * 0.8);
      case RudiGlyphType.info:
        canvas.drawCircle(size.center(Offset.zero), size.width * 0.36, paint);
        canvas.drawCircle(
          Offset(size.width * 0.5, size.height * 0.32),
          paint.strokeWidth * 0.6,
          paint..style = PaintingStyle.fill,
        );
        path
          ..moveTo(size.width * 0.5, size.height * 0.46)
          ..lineTo(size.width * 0.5, size.height * 0.68);
      case RudiGlyphType.error:
        canvas.drawCircle(size.center(Offset.zero), size.width * 0.36, paint);
        path
          ..moveTo(size.width * 0.5, size.height * 0.29)
          ..lineTo(size.width * 0.5, size.height * 0.56);
        canvas.drawCircle(
          Offset(size.width * 0.5, size.height * 0.7),
          paint.strokeWidth * 0.6,
          paint..style = PaintingStyle.fill,
        );
    }
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RudiGlyphPainter oldDelegate) {
    return type != oldDelegate.type || color != oldDelegate.color;
  }
}
