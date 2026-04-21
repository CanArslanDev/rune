# Changelog

All notable changes to this package are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-04-21

### Changed

- **`Consumer.builder` and `Selector.selector` now pass the raw
  notifier when the notifier does NOT implement
  `RuneReactiveNotifier`.** Previously they passed an empty
  `Map<String, Object?>` in that case, which meant consumers had
  no way to reach notifier fields from source. v0.2.0 pairs with
  `rune` v1.17.0's `MemberRegistry`: register property / method
  accessors on your notifier type and Rune source can dot-access
  them directly without the `.state` Map indirection.

  ```dart
  // v0.2.0 pattern: no RuneReactiveNotifier needed.
  class CounterNotifier extends ChangeNotifier {
    int _count = 0;
    int get count => _count;
    void increment() {
      _count++;
      notifyListeners();
    }
  }

  config.members
    ..registerProperty<CounterNotifier>('count', (c, _) => c.count)
    ..registerMethod<CounterNotifier>('increment', (c, args, _) {
      c.increment();
      return null;
    });

  // Source can now read `counter.count` directly:
  //   Consumer(builder: (ctx, counter, child) =>
  //       Text('${counter.count}'))
  ```

  Notifiers that already implement `RuneReactiveNotifier` keep
  working unchanged; the `state` Map is still extracted for them.
  Pick whichever pattern fits your notifier shape.

### Notes

- Requires `rune ^1.19.0` (previously `^1.13.0`). Although the
  MemberRegistry landed in v1.17.0, bumping to the current
  minimum simplifies the support matrix.
- No existing source breaks: the `Consumer(builder: (ctx, state,
  child) => ...)` pattern with a `RuneReactiveNotifier` keeps
  behaving exactly as before.

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
