# Changelog

## 0.2.0 (unreleased)

- Adds opt-in, clipped press ripples to RudiPressable, enabled for settings rows; honors reduced motion and gesture cancellation.
- Tightens settings/navigation spacing, exposes selected navigation color, and allows a null bottom-sheet closeIcon to hide the button.
- Requires Flutter 3.47 / Dart 3.13; new components use primary constructors.
- Adds floating navigation with interruptible movement and RTL support.
- Adds grouped settings rows and animated switch tiles.
- Allows app-owned icon sets through the optional bottom-sheet closeIcon widget.
- Refines bottom sheets with header dragging, spring return, optional title/close control, safe keyboard insets and an internally scrollable body.
- Makes system-bar icon brightness follow the app theme.
- Adds regression coverage for rapid navigation, drag cancellation, reduced motion and keyboard insets.

## 0.1.0

- Introduces the widgets-only Rudi UI foundation and reusable components.
- Adds a font-independent component showcase and device lab.
- Aligns hold, swipe, and duration-ruler interactions with their Loop originals.
- Adds a bottom-sheet demonstration and preview-only Google typography.
- Resets hold and swipe actions after every successful confirmation.
- Moves the publishable package to the repository root.
