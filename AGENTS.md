# Rudi UI contributor instructions

## Project boundaries

- Inspect the public barrel, comparable components, tests, examples, and theme
  primitives before changing code.
- Keep production code independent of Material and Cupertino libraries. Use
  Flutter's widgets, rendering, services, physics, and semantics APIs directly.
- Keep Flutter as the only production dependency unless a requested feature
  cannot reasonably be implemented with the existing stack. Explain the need
  and tradeoff before adding a production dependency.
- Follow the existing widgets-only, immutable, null-safe style. Reuse current
  components, semantic theme roles, tokens, feedback policy, and interaction
  primitives instead of introducing parallel abstractions.
- Keep code deliberate and domain-named. Do not add vague helpers, forwarding
  abstractions, narrated comments, placeholder behavior, or speculative TODOs.
  Extract only when the result has a clearer responsibility or genuine reuse.
- Preserve unrelated changes and avoid broad restructuring for focused work.

## Public API and behavior

- Export supported APIs through `lib/rudi_ui.dart`; never ask consumers to
  import from `lib/src`.
- Treat accessibility, keyboard operation, focus, text scaling, RTL, high
  contrast, reduced motion, safe areas, and adaptive layouts as part of public
  component behavior.
- Keep user-facing copy and formatting application-owned so consumers can
  localize them. Keep fonts and font licensing application-owned.
- Add or update focused tests whenever public behavior changes. Include loading,
  empty, error, disabled, cancellation, and rapid-interaction states when they
  are relevant.
- Follow semantic versioning. Before 1.0, increment the minor version for
  breaking changes and document migrations in `CHANGELOG.md`.

## Agent skill maintenance

- Treat `skills/rudi-ui-building/` as a public, versioned part of the package,
  not as repository-only documentation.
- After changing package source, public documentation, the compact example, or
  the package version, review the skill instructions for affected guidance and
  examples.
- Run `dart run tool/generate_skill_reference.dart` after that review. It
  regenerates the public API catalog and its source fingerprint.
- Never edit
  `skills/rudi-ui-building/references/public-api.md` manually.
- Keep the skill aligned with the resolved package API. Prefer concise routing
  and package-specific decisions over duplicating complete API documentation.
- Verify installation behavior when changing the skill's name, directory
  structure, frontmatter, or supporting resources. The directory and
  frontmatter name must retain the `rudi-ui-` package prefix required by
  `package:skills`.

## Required verification

Run the applicable checks before finishing:

```shell
dart format --output=none --set-exit-if-changed lib test example tool
dart analyze --fatal-infos
flutter test
dart run tool/check_import_boundaries.dart
dart run tool/generate_skill_reference.dart --check
dart pub publish --dry-run
```

Run `flutter test` and `dart analyze --fatal-infos` from `example/` when the
compact example or package-facing integration changes. Run the corresponding
format, analysis, test, and build checks from `preview/` when the interactive
catalog changes. State exactly which applicable checks could not be run.
