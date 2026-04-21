# Changelog

All notable changes to this package are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-21

### Added

- First release of `rune_riverpod`. Registers two widget builders
  on a `RuneConfig` via `RiverpodBridge`:
  - `ProviderScope`: thin wrapper over `flutter_riverpod`'s own
    `ProviderScope`. Optional in source when the host already
    mounts one above the `RuneView`.
  - `RiverpodConsumer`: `provider: someProvider` (passed in via
    data) + `builder: (ctx, value, child) -> Widget`. Watches the
    provider and rebuilds the subtree on every emission.
- `RuneReactiveValue` interface. Typed state classes implement
  `Map<String, Object?> toRuneMap()` so the builder receives the
  projected Map instead of the raw typed value. Values that
  don't implement the interface are passed through untouched.
  Matches the `rune_provider.RuneReactiveNotifier` and
  `rune_bloc.RuneReactiveState` patterns.
- Depends on `flutter_riverpod ^2.5.0` and `rune ^1.19.0`.
