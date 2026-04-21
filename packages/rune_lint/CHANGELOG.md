# Changelog

All notable changes to this package are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-21

### Added

- First release of `rune_lint`. Validation helpers for Rune
  source strings, built for test-time use:
  - `validateRuneSource(tester, source, config, {data})` pumps a
    `RuneView` into the supplied `WidgetTester` and returns a
    `List<RuneLintIssue>` describing every `RuneException` that
    surfaced during the first render.
  - `expectValidRuneSource(tester, source, config, {data,
    ignoreKinds})` is a thin wrapper that `fail`s with a readable
    listing when issues are present.
- `RuneLintIssueKind` enum: `parseError`, `unregistered`,
  `invalidArgument`, `missingBinding`, `resolveError`. Lets
  consumer tests filter or whitelist specific categories.
- 9 widget tests cover the five exception types end-to-end plus
  the `expectValidRuneSource` happy-path, failure-formatting,
  and `ignoreKinds` filtering behaviors.

### Notes

- Depends on `flutter_test` at runtime because the validator
  takes a `WidgetTester` and the matcher calls `fail()`.
  Consumers already have this available inside a test; pulling
  it into the main dep graph is harmless.
- Depends on `rune ^1.19.0`.
