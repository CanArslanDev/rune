# Changelog

All notable changes to this package are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-21

### Added

- First release of `rune_test`. Two things in one package:
  - **Test helpers.** `pumpRuneView(tester, source, {config,
    data, onEvent, onError, fallback, wrap, settle})` wraps a
    `MaterialApp` + `Scaffold` + `RuneView` and settles.
    `expectRuneRenders(tester, source, finder, matcher, ...)`
    fuses the pump + assertion. Both accept the full `RuneView`
    surface. Custom `wrap:` lets tests swap in
    `CupertinoApp`, `Localizations`, a `ProviderScope` root, etc.
  - **`rune_format` CLI.** Wraps `formatRuneSource` from the main
    `rune` package. `dart run rune_test:rune_format <file>`
    prints the formatted output; `--write` rewrites in place;
    `--check` exits 1 if the file is out of date (for CI).
    Supports stdin (`-`) and `--line-length` overrides.
- 6 widget tests cover the helper surface.
