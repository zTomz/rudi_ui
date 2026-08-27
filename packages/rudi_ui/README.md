# rudi_ui

Rudi UI is a cohesive Flutter design system implemented on top of
`package:flutter/widgets.dart` and other core framework libraries. It has no
Material UI, Cupertino UI, router, state-management, or animation-package
dependency.

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

Rudi UI does not bundle or name any font family. It uses the platform font by
default. Applications can provide licensed font assets themselves and map them
onto the immutable `RudiTextTheme` roles with `copyWith`.

Explore the components in the
[interactive device lab](https://ztomz.github.io/rudi_ui/).

```dart
final base = RudiThemeData.light();
final branded = base.copyWith(
  text: base.text.copyWith(
    display: base.text.display.copyWith(fontFamily: 'MyDisplayFont'),
    body: base.text.body.copyWith(fontFamily: 'MyBodyFont'),
  ),
);
```
