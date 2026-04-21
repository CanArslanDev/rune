# rune_riverpod

[Riverpod 2.x](https://pub.dev/packages/flutter_riverpod) bridge for the [`rune`](../..) package. Registers `ProviderScope` and `RiverpodConsumer` widgets on a `RuneConfig` so Rune source can consume Riverpod-managed state.

## Install

```yaml
dependencies:
  rune: ^1.19.0
  rune_riverpod: ^0.1.0
```

## Apply

```dart
final config = RuneConfig.defaults().withBridges(const [RiverpodBridge()]);
```

## Use from source

Pass the provider through `data:` (Riverpod providers are opaque Dart objects; Rune cannot conjure them from strings):

```dart
final counter = StateProvider<int>((ref) => 0);

ProviderScope(
  child: MaterialApp(
    home: RuneView(
      config: config,
      data: {'counterProvider': counter},
      source: r'''
        RiverpodConsumer(
          provider: counterProvider,
          builder: (ctx, count, child) => Text('Count: $count'),
        )
      ''',
    ),
  ),
)
```

The host app mounts `ProviderScope` above `RuneView` the usual way, OR the source itself can wrap a subtree via the registered `ProviderScope` widget.

## Typed state: implement `RuneReactiveValue`

For providers that emit typed state objects (freezed unions, data classes), implement the `RuneReactiveValue` interface so Rune source can reach individual fields via dot-access:

```dart
class CounterState implements RuneReactiveValue {
  const CounterState(this.count);
  final int count;

  @override
  Map<String, Object?> toRuneMap() => {'count': count};
}

final stateProvider = StateProvider<CounterState>(
  (ref) => const CounterState(0),
);
```

```
RiverpodConsumer(
  provider: stateProvider,
  builder: (ctx, state, child) => Text('${state.count}'),
)
```

Without `RuneReactiveValue`, the builder receives the raw typed value; source can still display it via `.toString()` or via `config.members.registerProperty<CounterState>(...)`.

## Registered widgets

| Type name          | Backed by                                | Notes                                                                                               |
| ------------------ | ---------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `ProviderScope`    | `flutter_riverpod`'s `ProviderScope`     | Required only if the host app does not already mount one above `RuneView`. `child:` is required.    |
| `RiverpodConsumer` | `flutter_riverpod`'s `Consumer`          | `provider:` (required), `builder: (ctx, value, child)` (required). Rebuilds on provider emission.   |

## Comparison

`rune_provider`, `rune_bloc`, and `rune_riverpod` solve the same shape (reactive state -> Rune source) with different state-management frameworks. `RuneReactiveNotifier` / `RuneReactiveState` / `RuneReactiveValue` play the same role across the three.

## License

MIT. See [`LICENSE`](LICENSE).
