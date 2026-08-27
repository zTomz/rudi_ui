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

Use `rudi_ui_fonts` when the complete branded Google Sans and Unbounded
typography is desired. Without it, Rudi UI uses the platform system font.

