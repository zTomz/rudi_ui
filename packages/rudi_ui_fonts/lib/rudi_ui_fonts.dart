/// Optional typography assets and theme integration for Rudi UI.
library;

import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

/// Font-family identifiers bundled by the Rudi UI font package.
abstract final class RudiFontFamilies {
  /// Google Sans body font.
  static const googleSans = 'packages/rudi_ui_fonts/GoogleSans';

  /// Unbounded display font.
  static const unbounded = 'packages/rudi_ui_fonts/Unbounded';
}

/// Adds the optional branded typography to a Rudi theme.
extension RudiFontThemeExtension on RudiThemeData {
  /// Returns a copy using Unbounded for display roles and Google Sans elsewhere.
  RudiThemeData withRudiFonts() {
    TextStyle googleSans(TextStyle style) =>
        style.copyWith(fontFamily: RudiFontFamilies.googleSans);
    TextStyle unbounded(TextStyle style) => style.copyWith(
      fontFamily: RudiFontFamilies.unbounded,
      fontVariations: [
        FontVariation.weight(
          (style.fontWeight ?? FontWeight.w400).value.toDouble(),
        ),
      ],
    );
    return copyWith(
      text: text.copyWith(
        display: unbounded(text.display),
        headline: unbounded(text.headline),
        title: unbounded(text.title),
        body: googleSans(text.body),
        label: googleSans(text.label),
        caption: googleSans(text.caption),
      ),
    );
  }
}
