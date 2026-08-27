# Rudi UI

Rudi UI is an independent, opinionated Flutter design system built on the
framework's core widget libraries. It does not depend on Material UI or
Cupertino UI.

The repository root is the publishable `rudi_ui` package. It also contains a
minimal widgets-only `example` and the Flutter 3.47 `preview` web app.

The packages currently target Flutter 3.44 or newer and Dart 3.12 or newer.
Rudi UI deliberately ships no font files and names no font family. Consuming
applications own their typography assets and licensing. The packages are under
active development toward a stable 1.0 API.

## Usage

```yaml
dependencies:
  rudi_ui: ^0.1.0
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
