# Rudi UI

Rudi UI is an independent, opinionated Flutter design system built on the
framework's core widget libraries. It does not depend on Material UI or
Cupertino UI.

The repository contains:

- `rudi_ui`: the dependency-free design system core;
- `example`: a minimal widgets-only package example;
- `preview`: the Flutter 3.47 web component and device lab.

The packages currently target Flutter 3.44 or newer and Dart 3.12 or newer.
Rudi UI deliberately ships no font files and names no font family. Consuming
applications own their typography assets and licensing. The packages are under
active development toward a stable 1.0 API.

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
dart format --output=none --set-exit-if-changed packages example
dart analyze --fatal-infos
flutter test packages/rudi_ui/test
dart run tool/check_import_boundaries.dart
```

See [packages/rudi_ui/README.md](packages/rudi_ui/README.md) for usage.
