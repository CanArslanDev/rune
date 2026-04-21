# rune_bloc

BLoC bridge for the [`rune`](../..) package. Registers `BlocProvider`, `BlocBuilder`, and `BlocListener` on a `RuneConfig` so Rune source can express BLoC-pattern state.

## Install

```yaml
dependencies:
  rune: ^1.18.0
  rune_bloc: ^0.1.0
```

## Apply the bridge

```dart
final config = RuneConfig.defaults().withBridges(const [BlocBridge()]);
```

## Write a reactive state class

BLoC state is idiomatically a typed Dart class. Rune source cannot reach typed Dart getters without explicit registration, so state classes implement the `RuneReactiveState` interface:

```dart
class CounterState implements RuneReactiveState {
  const CounterState({required this.count});
  final int count;

  @override
  Map<String, Object?> toRuneMap() => {'count': count};
}

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(const CounterState(count: 0));
  void increment() => emit(CounterState(count: state.count + 1));
}
```

## Use from source

```dart
RuneView(
  config: config,
  data: {'counter': counter},
  source: r'''
    BlocProvider(
      value: counter,
      child: Column(children: [
        BlocBuilder(
          builder: (ctx, state, child) => Text('Count: ${state.count}'),
        ),
        ElevatedButton(
          onPressed: 'increment',
          child: Text('+1'),
        ),
      ]),
    )
  ''',
  onEvent: (name, [args]) {
    if (name == 'increment') counter.increment();
  },
)
```

## Registered widgets

| Type name      | Backed by                              | Notes                                                                                                                      |
| -------------- | -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `BlocProvider` | `BlocProvider<BlocBase<Object?>>`      | Exactly one of `create: (ctx) => MyCubit()` or `value: existingCubit`. `create`-provided blocs are auto-closed on unmount. |
| `BlocBuilder`  | `BlocBuilder<BlocBase<Object?>, Object?>` | Rebuilds on each `emit`. `builder: (ctx, state, child)` where `state` is the `toRuneMap()` projection (empty for non-reactive states). |
| `BlocListener` | `BlocListener<BlocBase<Object?>, Object?>` | Side-effect-only. Requires `child:`. `listener: (ctx, state)` fires on state change; the child does not rebuild.          |

## Paired with rune_provider

`rune_bloc` and `rune_provider` solve the same shape (reactive state -> Rune source) with different state-management backends. Use `rune_provider` if your team already uses ChangeNotifier + Provider; use `rune_bloc` if you use Cubit / Bloc. They can coexist in one config, but each consumer usually picks one.

`RuneReactiveState` (this package) and `RuneReactiveNotifier` (`rune_provider`) play the exact same role: `Map`-shaped state projection for Rune's property resolver. If you migrate from one to the other, most source strings keep rendering unchanged.

## License

MIT. See [`LICENSE`](LICENSE).
