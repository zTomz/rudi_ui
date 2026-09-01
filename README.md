# Rudi UI

<p align="center">
  <img src="assets/images/rudi-ui-icon.png" alt="Rudi UI icon" width="160" />
</p>

Rudi UI is an independent, opinionated Flutter design system built on the
framework's core widget libraries. It does not depend on Material UI or
Cupertino UI.

The repository root is the publishable `rudi_ui` package. It also contains a
minimal widgets-only `example` and the Flutter 3.47 `preview` web app.

The packages currently target Flutter 3.47 or newer and Dart 3.13 or newer.
Rudi UI deliberately ships no font files and names no font family. Consuming
applications own their typography assets and licensing. The packages are under
active development toward a stable 1.0 API.

## Usage

```yaml
dependencies:
  rudi_ui: ^0.2.0
```

```dart
import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() => runApp(
  RudiApp(
    title: 'Example',
    home: RudiPage(
      child: Center(
        child: RudiButton(label: 'Continue', onPressed: () {}),
      ),
    ),
  ),
);
```

## Live preview

The interactive component catalog is deployed to
[ztomz.github.io/rudi_ui](https://ztomz.github.io/rudi_ui/). Its device lab uses
`device_preview` presets to switch between representative phones, tablets and
desktop windows. The site injects Google Sans and Unbounded through
`google_fonts` to demonstrate branded typography; neither the dependency nor
the font files are part of the published `rudi_ui` package.

## Development

```shell
flutter pub get
dart format --output=none --set-exit-if-changed lib test example tool
dart analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart
```

Rudi UI uses the platform font by default. Applications can inject licensed
font families through the immutable `RudiTextTheme` roles.

## 0.2 development

The 0.2 changes are local and not yet published. Consume this checkout using a path override until a public Git revision or package release is available.

- `RudiFloatingNavigationBar`: compact floating navigation with a continuously moving selection indicator, selected/unselected color slots, RTL, keyboard focus and reduced motion support. Supply `selectedIcon` on each destination for a filled variant.
- `RudiPage.navigation`: automatically centers navigation above the bottom safe area as a floating overlay.
- `RudiPressable(ink: true)`: opt-in ripple painted above the content, clipped to the control bounds, with gesture cancellation and reduced-motion feedback. Settings tiles enable it by default; enclosing rounded groups also clip the ink to their corners.
- `RudiSettingsGroup` and `RudiSwitchTile`: separated setting rows with grouped outer corners and a single accessible toggle target.
- `RudiCalendar`: localized, swipeable month navigation with full-cell touch targets and available, in-progress, completed and unavailable day states.
- `showRudiBottomSheet`: optional `title` and `closeIcon`, captured themes, header-only drag, spring return, scrollable body, keyboard insets and safe margins. Pass `closeIcon: null` to hide the button; dismissal through the barrier, drag and system back remains available. Existing builder/barrierLabel calls remain valid. The route owns vertical scrolling; supply non-scrollable content such as a Column.
- `RudiApp`: system-bar icon brightness follows light/dark appearance.

Rudi still uses only Flutter SDK production dependencies. Cue can coordinate scene transitions in consuming apps, as Sudoku does, without becoming a package dependency.
