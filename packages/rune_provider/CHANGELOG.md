# Changelog

All notable changes to this package are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-20

### Added

- First release of `rune_provider`. Registers three widget builders
  on a `RuneConfig` via `ProviderBridge`:
  - `ChangeNotifierProvider` (with `create:` + auto-dispose or
    `value:` variants).
  - `Consumer` (3-arity `(ctx, notifier, child)` builder closure).
  - `Selector` (2-arity selector closure + 3-arity builder closure,
    rebuilds only when the derived value changes).
- Type parameter is bound to `ChangeNotifier`; consumers that need
  multiple notifiers nest additional providers.
