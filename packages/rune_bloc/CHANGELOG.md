# Changelog

All notable changes to this package are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-21

### Added

- First release of `rune_bloc`. Registers three widget builders
  on a `RuneConfig` via `BlocBridge`:
  - `BlocProvider` (with `create:` auto-close or `value:`
    variants).
  - `BlocBuilder` (3-arity `(ctx, state, child)` builder closure,
    rebuilds on every emit).
  - `BlocListener` (2-arity `(ctx, state)` listener closure,
    side-effect-only, requires `child:`).
- `RuneReactiveState` interface. State classes implement
  `Map<String, Object?> toRuneMap()` so Rune source can dot-
  access individual fields (`state.count`). Dual of
  `rune_provider`'s `RuneReactiveNotifier` pattern.
- Depends on `flutter_bloc ^8.1.0`. `bloc_test` is deliberately
  NOT a dev dependency because its analyzer requirement
  (`analyzer >= 8.0.0`) conflicts with the main rune package
  pin (`analyzer ^6.4.1`); standard `flutter_test` covers the
  widget flows and cubit state-change verification here.
