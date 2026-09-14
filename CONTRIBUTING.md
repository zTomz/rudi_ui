# Contributing

Run formatting, static analysis, the complete test suite, the import-boundary
check, and the package publish dry-run before opening a pull request.

After changing package source, documentation, examples, or the package version,
review the agent skill and regenerate its API catalog with
`dart run tool/generate_skill_reference.dart`. The generated source fingerprint
makes CI reject a stale skill reference even when an implementation change does
not add or remove a public declaration.

Public APIs follow semantic versioning. A public member is deprecated for at
least one minor release before removal in a major release.
