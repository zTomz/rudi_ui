# Changelog

## 0.2.0 (unreleased)

### Breaking changes

- `showRudiBottomSheet` now creates the route only. Compose its `builder` with
  `RudiBottomSheet` to provide the title, content, actions and optional
  `RudiBottomSheetCloseButton`. The route options are now named
  `isDismissible` and `enableDrag`, and `useRootNavigator` defaults to `false`.
- `RudiFloatingNavigationBar` now derives its colors from `RudiThemeData`.
  Remove `backgroundColor`, `indicatorColor`, `selectedColor` and
  `unselectedColor` arguments. Contextual actions move to
  `RudiNavigationDestination.action`.
- `RudiButton` expands responsively by default. Set `expand: false` to retain
  compact inline sizing.
- `RudiSwipeAction.hapticsEnabled` was removed. Configure haptics once through
  `RudiThemeData.feedback` instead.
- The minimum supported versions are now Flutter 3.47 and Dart 3.13.

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

### Added and changed

- Establishes Rudi UI as the shared app foundation for page surfaces, dialogs, bottom sheets, navigation, controls and interaction feedback.
- Aligns dialogs, bottom sheets, buttons, text fields and floating navigation with Loop's production component geometry and behavior.
- Adds responsive dialog headers/actions and contextual floating-navigation actions.
- Replaces the former bottom-sheet convenience API with a reusable `RudiBottomSheet` shell and fully configurable spring route.
- Routes swipe-action feedback through the theme policy, removing its duplicate component-level haptic switch.
- Makes buttons phone-wide and tablet-capped by default, with optional compact width, minimum height and maximum width overrides.
- Adds reusable scale feedback to `RudiPressable` and aligns transient messages with Loop's pill presentation.
- Moves Loop's icon settings rows, switch treatment, hold/swipe confirmation and duration ruler into the shared component API.
- Adds a read-only preview offset to `RudiDurationRuler` for animated product demonstrations.
- Refines the official dark palette and floating-navigation color roles, keeping the bar distinct from dark page backgrounds without a muddy shadow.
- Adds opt-in, clipped press ripples to RudiPressable, enabled for settings rows; honors reduced motion and gesture cancellation.
- Tightens settings/navigation spacing, exposes selected navigation color, and allows a null bottom-sheet closeIcon to hide the button.
- Requires Flutter 3.47 / Dart 3.13; new components use primary constructors.
- Adds floating navigation with interruptible movement and RTL support.
- Floats `RudiPage.navigation` above page content and the bottom safe area automatically.
- Adds grouped settings rows and animated switch tiles.
- Allows app-owned icon sets through the optional bottom-sheet closeIcon widget.
- Refines bottom sheets with header dragging, spring return, optional title/close control, safe keyboard insets and an internally scrollable body.
- Makes system-bar icon brightness follow the app theme.
- Adds a localized, swipeable RudiCalendar with accessible day states and full-cell touch targets.
- Adds regression coverage for rapid navigation, drag cancellation, reduced motion and keyboard insets.
- Keeps long-press-only pressables enabled without exposing an invalid keyboard activation action.
- Preserves custom palettes in high-contrast mode and accepts explicit high-contrast themes in `RudiApp`.
- Adds value equality to theme data, tokens and feedback policies for reliable inherited-theme updates.
- Enforces and tests the package import boundary with an explicit dependency allowlist.
- Verifies the minimum supported Flutter release and the latest stable release in CI.
- Installs stretch overscroll through `RudiApp` on Android and Fuchsia instead
  of Flutter's legacy glow, with `scrollBehavior` available for overrides.
- Ensures `RudiPressable.enabled` consistently blocks pointer and keyboard
  activation and treats callback-free pressables as disabled.

## 0.1.0

- Introduces the widgets-only Rudi UI foundation and reusable components.
- Adds a font-independent component showcase and device lab.
- Refines hold, swipe, and duration-ruler interactions for consistent direct manipulation.
- Adds a bottom-sheet demonstration and preview-only Google typography.
- Resets hold and swipe actions after every successful confirmation.
- Moves the publishable package to the repository root.
