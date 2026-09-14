# Rudi UI code-quality guide

Read this guide for substantial screens, stateful interactions,
persistence-backed UI, and code review. The consuming repository remains the
source of truth for architecture and naming.

## Design the responsibility first

- State the user intent of each action before choosing a component. Prefer
  names such as `onPresetSelected`, `saveDuration`, or `retryLoading` over
  generic action handlers.
- Keep page composition in presentation code, application state in the target
  app's existing state-management layer, persistence behind its existing data
  boundary, and platform work behind a service boundary.
- Do not introduce a repository, service, provider, controller, or base class
  unless the change has a real boundary to isolate. Do not bypass an existing
  boundary to save a few lines.
- Preserve value invariants at the owning boundary. Validate decoded or stored
  data before it reaches widgets, retain backward-compatible persistence, and
  migrate schemas explicitly when required.

## Write deliberate Dart and Flutter

- Keep build methods declarative. Derive theme, localization, and watched state
  once near their use, then compose widgets from those values.
- Prefer records, patterns, switch expressions, collection `if`/`for`, and
  destructuring when they make valid states and transformations clearer. Do not
  use newer syntax merely for novelty.
- Represent state immutably and replace collections instead of mutating values
  that callers may retain. Make collection ownership explicit.
- Await work whose result or failure affects the current operation. Mark
  intentionally detached futures with `unawaited`, report failures through the
  application's established path, and guard widget work after disposal.
- Serialize rapid writes or discard stale asynchronous results when ordering
  affects persisted or visible state. Test the race, not just the happy path.
- Prefer early returns for invalid or no-op cases. Keep the successful path
  readable and avoid deeply nested callback pyramids.

## Compose Rudi UI intentionally

- Use `context.rudiTheme` semantic roles. A hard-coded value is appropriate
  only when it is a feature-owned measurement or brand value with a clear
  reason, not a substitute for an existing token.
- Prefer a complete Rudi component before composing from `RudiPressable`. When
  using `RudiPressable`, provide the correct semantic label and model enabled,
  focused, hovered, pressed, and disabled visuals coherently.
- Do not place two independent tap targets inside one semantic toggle or row.
  Use supported secondary slots such as `RudiSwitchTile.supporting`, and follow
  the component's documented ripple behavior.
- Keep controllers and focus nodes synchronized with externally owned values
  without overwriting in-progress user input. Dispose listeners or let hooks
  own their lifecycle when the target project already uses Flutter Hooks.
- Respect safe areas at exactly one ownership level. A
  `RudiFloatingNavigationBar` owns its bottom inset; a custom navigation widget
  passed to `RudiPage.navigation` must provide its own.

## Make copy and states production-ready

- Use the application's localization API for every visible or semantic string,
  including barriers, tooltips, progress values, validation, and errors.
- Prefer short, specific copy that tells the user what happened and what they
  can do next. Avoid filler headings, generic marketing language, and invented
  product claims.
- Give errors an injected recovery action when recovery is possible. Do not
  catch failures only to display nothing, and do not expose raw exception text
  as user-facing copy.
- Disable impossible actions at the component boundary and preserve the same
  rule in application logic. Visual affordance alone is not validation.

## Test through public behavior

A minimal widget-test scope can use the package directly:

```dart
import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

Widget rudiTestScope(Widget child) {
  return RudiTheme(
    data: RudiThemeData.light(feedback: RudiFeedbackPolicy.silent),
    child: RudiMessenger(child: child),
  );
}
```

- Assert what the user sees, announces, enters, selects, dismisses, and retries.
- Exercise minimum and maximum values, malformed persisted input, empty data,
  disabled callbacks, cancellation, and rapid repeated input when applicable.
- Test both light and dark themes when semantic colors change, and use reduced
  motion in tests for custom animation branches.
- Avoid tests that lock in private widget structure, incidental animation
  frames, or duplicated implementation constants without protecting behavior.

## Final review

Before finishing, ask whether every new symbol, abstraction, comment, and line
of copy earns its place. A smaller implementation that follows the existing
architecture and covers real states is preferable to a generalized framework
created for hypothetical future use.
