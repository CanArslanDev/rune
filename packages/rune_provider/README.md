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
- `rune` (sibling package in the same monorepo; current dep: `path: ../..`)
- `provider` ^6.1.2

## Install

```yaml
dependencies:
  rune: ^1.12.0
  rune_provider: ^0.1.0
```

## Usage

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
  runApp(
    MaterialApp(
      home: Scaffold(
        body: RuneView(
          config: RuneConfig.defaults()
              .withBridges(const [ProviderBridge()]),
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

## License

MIT. See [LICENSE](LICENSE).
