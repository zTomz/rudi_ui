# Changelog

All notable changes to Rudi UI are documented in this file.

Rudi UI follows Semantic Versioning. Until 1.0, breaking API changes increment
the minor version.

## 0.5.0 - 2026-09-17

### Added

- Adds `RudiAppBar` and `RudiBackButton`, including automatic back navigation
  and optional custom cleanup callbacks.
- Adds `RudiTooltip` for passive hover, focus, and long-press explanations.

### Changed

- Renames `RudiPageHeader` to `RudiAppBar`.
- Aligns `RudiIconButton` with plain Material icon-button geometry, colors and
  subtle interaction overlays without adding a Material dependency.
- Makes Rudi switch indicators draggable in both directions as well as tappable.
- Refines snackbars with a dark gradient surface, customizable accent border,
  direction-aware dotted pattern and slightly larger leading icon.
- Adds `RudiSnack.info`, `RudiSnack.error` and `RudiSnack.debug` constructors
  with semantic theme colors and appropriate default icons.
- Presents up to four concurrent snackbars as a compact layered deck while
  retaining unexpired overflow for later reveal, with independent durations,
  animated insertion and downward swipe dismissal.

### Fixed

- Keeps passive tooltips centered over their trigger whenever viewport margins
  allow it.
- Keeps the snackbar deck anchored and smoothly promotes the next card while
  its front card is swiped away.

## 0.4.1 - 2026-09-15

### Added

- Adds text alignment, custom text style, surface color and content padding to
  `RudiTextField` and `RudiTextFormField` for compact and numeric inputs.

## 0.4.0 - 2026-09-14

### Added

- Ships an installable `rudi-ui-building` agent skill with package-specific
  composition, accessibility, code-quality and testing guidance, generated API
  discovery and CI-enforced synchronization.

## 0.3.1 - 2026-09-13

### Fixed

- Fixes README images not appearing on pub.dev by using absolute image URLs.

### Changed

- Adds a prominent pub.dev package link and dynamic version badge to the
  README.

## 0.3.0 - 2026-09-13

### Added

- Adds `RudiInfoTooltip`, an anchored, accessible explanation bubble with
  automatic and tap-outside dismissal, reduced-motion support and RTL-aware
  positioning.
- Adds `RudiSwitchTile.supporting` for a secondary action such as
  `RudiInfoTooltip` beside the switch indicator.
- Adds `RudiSettingsTile.ink` to let compound rows disable the row-wide press
  ripple when they contain an independent supporting action.
- Adds `RudiSystemUi` so applications that do not use `RudiApp` can install the
  same system-bar styling explicitly.
- Adds `RudiPage.safeAreaTop` and `RudiPage.safeAreaBottom` for app-owned
  headers and edge-to-edge scrolling content. Both default to `true`.

### Changed

- Makes the status bar, system navigation bar and navigation-bar divider
  transparent, keeps icon brightness aligned with the active Rudi theme and
  disables Android's navigation contrast scrim.
- Positions `RudiPage.navigation` in a full-width bottom overlay. Navigation
  widgets now own their safe-area handling and outer spacing;
  `RudiFloatingNavigationBar` already provides both.
- Demonstrates supporting tooltips in the interactive preview and expands
  regression coverage for tooltips, system UI, safe areas and navigation
  placement.

### Migration notes

- Custom widgets passed to `RudiPage.navigation` should wrap themselves in
  `SafeArea(top: false)` and provide their own outer padding. No change is
  required when using `RudiFloatingNavigationBar`.
- For a page with an app-owned status-bar header and content scrolling behind
  floating navigation, set both `safeAreaTop: false` and
  `safeAreaBottom: false`. The header and navigation remain responsible for
  their respective insets.

## 0.2.0 - 2026-09-12

### Breaking changes

- `showRudiBottomSheet` now creates the route only. Compose its `builder` with
  `RudiBottomSheet` to provide the title, content, actions and optional
  `RudiBottomSheetCloseButton`. Route options are now named `isDismissible`
  and `enableDrag`, and `useRootNavigator` defaults to `false`.
- `RudiFloatingNavigationBar` now derives its colors from `RudiThemeData`.
  Remove `backgroundColor`, `indicatorColor`, `selectedColor` and
  `unselectedColor` arguments. Contextual actions move to
  `RudiNavigationDestination.action`.
- `RudiButton` expands responsively by default. Set `expand: false` to retain
  compact inline sizing.
- `RudiSwipeAction.hapticsEnabled` was removed. Configure haptics once through
  `RudiThemeData.feedback` instead.
- Raises the minimum supported versions to Flutter 3.47 and Dart 3.13.

### Migration example

```dart
showRudiBottomSheet<void>(
  context: context,
  barrierLabel: 'Close',
  builder: (sheetContext) => RudiBottomSheet(
    title: const Text('Settings'),
    trailing: const RudiBottomSheetCloseButton(semanticLabel: 'Close'),
    children: const [Text('Sheet content')],
  ),
);
```

### Added

- Adds `RudiApp` and `RudiPage` as the shared application and page foundation,
  including theme selection, high-contrast themes, localization scopes,
  app-wide messaging and stretch overscroll on Android and Fuchsia.
- Adds floating navigation with contextual actions, interruptible selection
  movement, RTL support and semantic theme colors.
- Adds responsive dialogs, a reusable bottom-sheet shell and configurable
  spring routes with drag handling, keyboard insets and scrollable content.
- Adds grouped settings, icon and option rows, animated switches and expandable
  controls.
- Adds responsive buttons, icon buttons, pressables, hold/swipe confirmation,
  text fields, number input and a duration ruler with preview offsets.
- Adds empty, error and loading states, transient pill messages and theme-level
  haptic and sound feedback policies.
- Adds a localized, swipeable `RudiCalendar` with accessible day states and
  full-cell touch targets.
- Adds a font-independent component showcase and responsive device lab.

### Changed

- Aligns dialogs, bottom sheets, buttons, fields, settings and navigation with
  the component geometry and interaction patterns proven in Loop.
- Makes buttons phone-wide and tablet-capped by default, with optional compact
  width, minimum height and maximum width overrides.
- Floats `RudiPage.navigation` above page content and the bottom safe area.
- Refines the official light and dark palettes, selected-control colors and
  floating-navigation color roles.
- Keeps typography application-owned: the package ships no fonts and declares
  no font family.
- Adds value equality to theme data, tokens and feedback policies.
- Aligns system-bar icon brightness with the active theme.

### Fixed

- Keeps long-press-only pressables enabled without exposing an invalid keyboard
  activation action.
- Ensures disabled and callback-free pressables consistently block pointer and
  keyboard activation.
- Preserves custom palettes in high-contrast mode and honors explicitly
  supplied high-contrast themes.
- Makes press ripples respect clipping, gesture cancellation and reduced-motion
  preferences.

### Quality

- Adds regression coverage for rapid navigation, drag cancellation, reduced
  motion, keyboard insets and accessible interaction states.
- Enforces the package import boundary with an explicit dependency allowlist.
- Verifies both the minimum supported Flutter version and current stable Flutter
  in CI.

## 0.1.0 - 2026-08-27

- Introduces the widgets-only Rudi UI foundation and reusable components.
- Adds a font-independent component showcase and device lab.
- Adds Loop-derived press, hold, swipe and duration-ruler interactions.
- Adds bottom-sheet demonstrations and preview-only Google typography.
- Keeps the production package dependency-free except for the Flutter SDK.
