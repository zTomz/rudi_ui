# Rudi UI

Rudi UI is an independent, opinionated Flutter design system built on the
framework's core widget libraries. It does not depend on Material UI or
Cupertino UI.

The repository contains:

- `rudi_ui`: the dependency-free design system core;
- `rudi_ui_fonts`: optional Google Sans and Unbounded typography assets;
- `example`: a widgets-only component showcase.

The packages currently target Flutter 3.44 or newer and Dart 3.12 or newer.
They are under active development toward a stable 1.0 API.

## Development

```shell
flutter pub get
dart format --output=none --set-exit-if-changed packages example
dart analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart
```

See [packages/rudi_ui/README.md](packages/rudi_ui/README.md) for usage.

