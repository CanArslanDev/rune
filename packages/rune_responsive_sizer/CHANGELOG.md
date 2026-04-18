# Changelog

All notable changes to `rune_responsive_sizer` are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] — 2026-04-18

### Added
- Initial release. `ResponsiveSizerBridge` implements `RuneBridge` and
  registers four property extensions on `RuneConfig.extensions`:
  - `.w` — percentage of screen width (via `MediaQuery.sizeOf`)
  - `.h` — percentage of screen height
  - `.sp` — text-scaled pixels (via `MediaQuery.textScalerOf`)
  - `.dm` — percentage of `min(width, height)`
- Handlers throw `ArgumentError` on non-numeric targets and `StateError`
  when `ctx.flutterContext` is null.
- Seven tests cover registration, per-property math under fixed screen
  sizes, `textScaler` propagation, and both error paths.
- Analyzer-clean under `very_good_analysis ^5.1.0`.
