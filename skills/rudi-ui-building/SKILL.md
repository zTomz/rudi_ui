---
name: rudi-ui-building
description: Build or modify Flutter interfaces that use package:rudi_ui, including app shells, themes, pages, navigation, controls, forms, feedback, dialogs, sheets, settings, calendars, and progress components.
---

# Build with Rudi UI

Create interfaces that feel like one intentional product, not a collection of
plausible-looking widgets. Use the APIs shipped by the consumer's resolved
`rudi_ui` version and preserve the consuming application's architecture. Rudi
UI is a widgets-only, accessible design system; never invent Material- or
Cupertino-shaped Rudi APIs.

## Establish the available version

Before editing code:

1. Inspect the target feature, a comparable screen, its tests, the application
   shell, localization, and state-management conventions before editing.
2. Confirm that the target package depends on `rudi_ui` and note its resolved
   version from `pubspec.lock` or `.dart_tool/package_config.json`.
3. Import the public barrel only:
   `import 'package:rudi_ui/rudi_ui.dart';`.
4. Read [references/public-api.md](references/public-api.md) to select likely
   components. For exact constructors and behavior, inspect the declaration in
   the resolved package source. Source wins over examples and model memory.
5. For a substantial screen, stateful interaction, persistence-backed UI, or
   review, also read
   [references/code-quality.md](references/code-quality.md).
6. In the Rudi UI repository, use `example/lib/main.dart` for compact working
   composition and `preview/lib/main.dart` for the complete catalog. Published
   packages include the compact example but not the preview application.

Before writing widgets, identify the screen's primary task and its loading,
empty, error, disabled, success, and cancellation states. Implement only states
that are relevant, but do not leave reachable states as blank or placeholder
content.

## Compose the application

- Prefer `RudiApp` or `RudiApp.router` as the root. They install the active
  theme, localization scopes, scroll behavior, system-bar styling, and the
  app-wide `RudiMessenger`.
- If an existing application must keep another root shell, wrap its themed
  content in `RudiTheme`, `RudiSystemUi`, and `RudiMessenger` only as needed.
  Install these once near the root; do not nest a second application widget or
  repeat the scopes per screen.
- Use `RudiPage` for page background, padding, safe areas, readable-width
  constraints, and optional floating navigation.
- When content owns the status-bar header or scrolls behind floating
  navigation, set the corresponding `RudiPage.safeAreaTop` or
  `safeAreaBottom` to `false`. A custom `RudiPage.navigation` widget must
  provide its own bottom safe area and outer spacing;
  `RudiFloatingNavigationBar` already does both.

## Follow the design system

- Read colors, text styles, spacing, radii, and motion from
  `context.rudiTheme`. Prefer semantic theme roles over hard-coded visual
  values.
- Customize with `RudiThemeData.light`, `RudiThemeData.dark`, and `copyWith`.
  Keep typography and font assets application-owned; Rudi UI deliberately
  ships no font.
- Prefer the matching Rudi component over rebuilding the same interaction from
  lower-level widgets. Use `RudiPressable` when the design system has no
  higher-level control for the interaction.
- Do not create wrapper widgets, token aliases, services, or abstractions merely
  to make generated code look structured. Extract a widget when it owns a real
  responsibility, lifecycle, semantic unit, or reuse boundary.
- Keep one-off composition close to its screen. Use small named widgets instead
  of long builder methods when a subtree has its own state or behavior.
- Prefer immutable values, `final` locals, and `const` constructors and widgets
  when their inputs are compile-time constants. Do not force `const` through
  awkward APIs or cache trivial widget trees.
- Give symbols domain-specific names. Avoid vague names such as `data`,
  `manager`, `helper`, `handleAction`, or `CustomWidget` when the code can state
  the actual role or user intent.
- Keep application state and business logic in the consuming app's existing
  architecture. UI callbacks should express user intent and delegate work;
  they should not accumulate persistence, networking, or workflow logic.
- Comment constraints and surprising decisions, not syntax. Do not add banner
  comments, narrated implementation steps, placeholder copy, fake callbacks,
  speculative TODOs, or abstractions with only one forwarding implementation.

## Preserve accessibility and adaptive behavior

- Supply visible labels or semantic labels for icon-only actions, destructive
  confirmations, duration controls, calendar days, and modal barriers.
- Keep localization in the consuming application. Pass localized strings and
  label builders to Rudi components. Do not hard-code user-facing English in
  reusable UI or concatenate fragments that translators need to reorder.
- Preserve keyboard operation, focus behavior, large targets, text scaling,
  RTL directionality, high contrast, and `MediaQuery.disableAnimations`.
  Prefer Rudi components because they already implement these behaviors.
- Model loading, empty, error, disabled, and retry states with the appropriate
  Rudi feedback components instead of leaving blank content.
- Treat semantics as behavior. An icon-only control needs a localized semantic
  label; a disabled control must be both visually and semantically disabled;
  destructive actions need deliberate confirmation proportional to their risk.

## Common patterns

Create a basic app shell:

```dart
import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

void main() => runApp(
  RudiApp(
    title: 'My app',
    home: RudiPage(
      child: Center(
        child: RudiButton(label: 'Continue', onPressed: () {}),
      ),
    ),
  ),
);
```

Open a modal by composing the route helper with its surface. Always provide a
localized barrier label and pop with the builder's context:

```dart
showRudiDialog<void>(
  context: context,
  barrierLabel: closeDialogLabel,
  builder: (dialogContext) => RudiDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      RudiButton(
        label: doneLabel,
        onPressed: () => Navigator.of(dialogContext).pop(),
      ),
    ],
  ),
);
```

For a bottom sheet, `showRudiBottomSheet` creates the route only. Its builder
must return `RudiBottomSheet`; add `RudiBottomSheetCloseButton` when a visible
close action is needed.

Show transient feedback through the nearest app-wide messenger. Use the named
constructors for semantic color and icon defaults, and keep the message and
action label localized by the application:

```dart
RudiMessenger.of(context).show(
  RudiSnack.error(
    message: saveFailedLabel,
    actionLabel: retryLabel,
    onAction: retrySave,
  ),
);
```

Use `RudiSnack.info` for informational feedback, `RudiSnack.error` for failures,
and `RudiSnack.debug` for muted diagnostics. Use the base `RudiSnack`
constructor for standard feedback and `accentColor` only for a deliberate
application-specific override. A `RudiMessenger` renders at most four messages
by default. Additional messages remain queued while their individual durations
continue; dismissing the newest message with a downward swipe reveals the next
unexpired message. Change `maxVisibleSnacks` only when the surrounding layout
requires a smaller or larger visible deck.

## Verify changes

Review the resulting diff before relying on tools. Remove duplicated styling,
unreachable branches, accidental public APIs, placeholder behavior, and
comments that merely restate the code. Then format and analyze the consuming
application and run focused tests for the changed behavior.

Test observable outcomes rather than implementation details. Cover semantics,
disabled behavior, boundary values, navigation or modal results, rapid repeated
interaction, and reduced motion when relevant. Use a real `RudiTheme` and
`RudiMessenger` in widget-test scopes; configure `RudiFeedbackPolicy.silent` to
avoid platform feedback side effects.

When maintaining Rudi UI itself, run
`dart run tool/generate_skill_reference.dart` after public API changes. CI runs
the same generator with `--check`, so a stale public API reference cannot be
merged or published.
