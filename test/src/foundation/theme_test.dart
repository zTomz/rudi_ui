import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() {
  group('RudiThemeData', () {
    test('creates accessible accents for both brightness modes', () {
      final light = RudiThemeData.light(accent: const Color(0xFFFAFAF7));
      final dark = RudiThemeData.dark(accent: const Color(0xFF111214));

      expect(
        _contrast(light.colors.accent, light.colors.background),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(dark.colors.accent, dark.colors.background),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('interpolates colors and typography', () {
      final light = RudiThemeData.light();
      final dark = RudiThemeData.dark();
      final middle = RudiThemeData.lerp(light, dark, 0.5);

      expect(
        middle.colors.background,
        Color.lerp(light.colors.background, dark.colors.background, 0.5),
      );
      expect(middle.text.body.fontSize, closeTo(16, 0.001));
      expect(middle.brightness, Brightness.dark);
    });

    test('uses the Loop-aligned dark palette', () {
      final dark = RudiThemeData.dark();

      expect(dark.colors.background, const Color(0xFF111214));
      expect(dark.colors.foreground, const Color(0xFFF2F4F5));
      expect(dark.colors.surface, const Color(0xFF24262A));
      expect(dark.colors.surfaceContainer, const Color(0xFF1C1E21));
      expect(dark.colors.primary, const Color(0xFF33363B));
      expect(dark.colors.onPrimary, const Color(0xFFF2F4F5));
      expect(dark.colors.accent, const Color(0xFF128FE2));
    });
  });
}

double _contrast(Color first, Color second) {
  final values = [first.computeLuminance(), second.computeLuminance()]..sort();
  return (values.last + 0.05) / (values.first + 0.05);
}
