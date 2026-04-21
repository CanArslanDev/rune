# rune_provider

Provider ([`provider`](https://pub.dev/packages/provider)) bridge for the [`rune`](../..) package. Registers `ChangeNotifierProvider`, `Consumer`, and `Selector` on a `RuneConfig` so Rune source can express reactive state without escaping into the host app.

## What the bridge adds

### Widgets (3)

| Type name                 | Backed by                           | Notes                                                                                              |
| ------------------------- | ----------------------------------- | -------------------------------------------------------------------------------------------------- |
| `ChangeNotifierProvider`  | `ChangeNotifierProvider<ChangeNotifier>` | Accepts exactly one of `create: (ctx) => notifier` or `value: existingNotifier`, plus required `child:`. Optional `lazy:` (defaults to `true`). `create`-provided notifiers are auto-disposed; `value`-provided ones are not. |
| `Consumer`                | `Consumer<ChangeNotifier>`          | Requires `builder: (ctx, notifier, child) => Widget`. Optional `child:` is forwarded as the third closure arg so subtrees can opt out of rebuild. |
| `Selector`                | `Selector<ChangeNotifier, Object?>` | Requires `selector: (ctx, notifier) => value` and `builder: (ctx, value, child) => Widget`. Only rebuilds when the selector's output changes under `==`. |

## Type constraint

All three widgets are fixed to a single `ChangeNotifier` type under the hood. Since Rune source cannot specify generic type arguments, the bridge binds `T = ChangeNotifier` so consumers can stay untyped at the source level. If a subtree needs multiple notifiers, nest additional `ChangeNotifierProvider`s at different levels of the tree.

## Requirements

- Flutter >= 3.22
- Dart >= 3.4
- `rune` ^1.19.0
- `provider` ^6.1.2

## Install

```yaml
dependencies:
  rune: ^1.19.0
  rune_provider: ^0.2.0
```

## Exposing notifier state to source

The `Consumer(builder:)` and `Selector(selector:)` closures receive a value you can read in source. There are two supported patterns for what that value looks like, and they coexist:

1. **MemberRegistry (recommended, v0.2.0+).** Define your notifier normally. Register property/method accessors on your notifier type and the source reads them by dot-access. No base class or mixin required.
2. **`RuneReactiveNotifier`.** Implement the mixin so your notifier projects a `Map<String, Object?> get state`. Source reads fields as map keys (`state.count`). Useful when your fields are private and you want a flat map-shaped projection.

Pick whichever fits your notifier's shape. If you do nothing, the closure argument is the raw notifier; register members to make its fields reachable.

## Usage (MemberRegistry pattern)

```dart
import 'package:flutter/material.dart';
import 'package:rune/rune.dart';
import 'package:rune_provider/rune_provider.dart';

class CounterNotifier extends ChangeNotifier {
  int _count = 0;
  int get count => _count;
  void increment() {
    _count++;
    notifyListeners();
  }
}

void main() {
  final counter = CounterNotifier();
  final config = RuneConfig.defaults()
      .withBridges(const [ProviderBridge()]);
  config.members
    ..registerProperty<CounterNotifier>('count', (c, _) => c.count)
    ..registerMethod<CounterNotifier>('increment', (c, args, _) {
      c.increment();
      return null;
    });

  runApp(
    MaterialApp(
      home: Scaffold(
        body: RuneView(
          config: config,
          data: {'counter': counter},
          source: r'''
            ChangeNotifierProvider(
              value: counter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Consumer(
                    builder: (ctx, c, child) =>
                        Text('Count: ${c.count}'),
                  ),
                  ElevatedButton(
                    onPressed: 'increment',
                    child: Text('+1'),
                  ),
                ],
              ),
            )
          ''',
          onEvent: (name, [args]) {
            if (name == 'increment') counter.increment();
          },
        ),
      ),
    ),
  );
}
```

## Usage (RuneReactiveNotifier pattern)

```dart
class CounterNotifier extends ChangeNotifier with RuneReactiveNotifier {
  int _count = 0;
  int get count => _count;

  @override
  Map<String, Object?> get state => {'count': _count};

  void increment() { _count++; notifyListeners(); }
}

// Source reads fields as map keys:
//   Consumer(builder: (ctx, state, child) => Text('${state.count}'))
```

## License

MIT. See [LICENSE](LICENSE).
