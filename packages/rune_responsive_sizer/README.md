# rune_responsive_sizer

Responsive-sizer bridge for the [`rune`](../..) package. Registers four property extensions on a `RuneConfig` so source strings can size widgets relative to the screen and scale fonts with `MediaQuery.textScaler`:

| Property | Meaning                                         | Example             |
| -------- | ----------------------------------------------- | ------------------- |
| `.w`     | Percentage of screen width                      | `50.w` → half W     |
| `.h`     | Percentage of screen height                     | `25.h` → quarter H  |
| `.sp`    | Text-scaled pixels (respects `textScaler`)      | `16.sp`             |
| `.dm`    | Percentage of `min(width, height)`              | `10.dm`             |

No new widget builders. No new value builders. No new constants. Just four entries on the extension registry.

## Requirements

- Flutter ≥ 3.22
- Dart ≥ 3.4
- `rune` (sibling package in the same monorepo — current dep: `path: ../..`)

## Install

Until published on `pub.dev`, add as a sibling dep alongside `rune`:

```yaml
dependencies:
  rune:
    path: ../rune
  rune_responsive_sizer:
    path: ../rune/packages/rune_responsive_sizer
```

When this package is published independently, the entry becomes a normal `pub.dev` reference.

## Usage

Construct a `RuneConfig`, apply the bridge via `withBridges`, pass to `RuneView`:

```dart
import 'package:flutter/material.dart';
import 'package:rune/rune.dart';
import 'package:rune_responsive_sizer/rune_responsive_sizer.dart';

final config = RuneConfig.defaults()
    .withBridges(const [ResponsiveSizerBridge()]);

// then inside a widget tree:
RuneView(
  source: r"""
    Column(children: [
      SizedBox(width: 50.w, height: 10.h, child: Text('half-W, tenth-H')),
      Text('scaled', style: TextStyle(fontSize: 16.sp)),
      Container(
        width: 20.dm,
        height: 20.dm,
        color: Color(0xFF2196F3),
      ),
    ])
  """,
  config: config,
)
```

## Contract notes

- **`ctx.flutterContext` must be non-null.** All four handlers call `MediaQuery.sizeOf(ctx.flutterContext!)` / `textScalerOf`. `RuneView` provides a live `BuildContext`; unit-testing a handler in isolation requires a widget pump or the handler will throw `StateError`.
- **Target must be `num`.** `'hi'.w` throws `ArgumentError`. Handlers don't coerce strings to numbers.
- **Percentage semantics.** `100.w` = full width; `50.w` = half; values outside 0–100 are allowed and may produce overflow widgets (intentional — the bridge doesn't clamp).
- **Handlers return `double`.** Flutter's sizing APIs accept `double`; the returned value is always `double` even when the target is an `int`.

## Extending

Want more properties (`.vw`, `.vh`, `.em`, `.rem`, `.dp`)? Either fork this bridge into your app or contribute upstream via PR. The bridge itself is 70 lines of Dart — easy to copy and extend.

## Tests

```bash
flutter test
```

Seven tests cover registration, each of the four properties under fixed `MediaQuery` sizes, `textScaler` propagation, and both error paths (non-num target, null flutterContext).

## License

MIT — see [`LICENSE`](LICENSE).
