# rune_cupertino

Cupertino (iOS-style) bridge for the [`rune`](../..) package. Registers a curated subset of Flutter's Cupertino widget set, a `CupertinoThemeData` value builder, and 30 `CupertinoIcons.*` constants on a `RuneConfig`.

## What the bridge adds

### Widgets (10)

| Type name                   | Backed by                    | Notes                                    |
| --------------------------- | ---------------------------- | ---------------------------------------- |
| `CupertinoApp`              | `CupertinoApp`               | `home`, `theme`, `title`, debug banner.  |
| `CupertinoPageScaffold`     | `CupertinoPageScaffold`      | Requires `child`; filters `navigationBar` to the expected shape. |
| `CupertinoNavigationBar`    | `CupertinoNavigationBar`     | `middle`, `leading`, `trailing`, colors. |
| `CupertinoButton`           | `CupertinoButton`            | Requires `child`; `onPressed` as event name or closure. |
| `CupertinoSwitch`           | `CupertinoSwitch`            | Two-way value binding; `onChanged` bool. |
| `CupertinoSlider`           | `CupertinoSlider`            | Requires `value`; `onChanged` double.    |
| `CupertinoTextField`        | `CupertinoTextField`         | Owns an internal `TextEditingController` when none is supplied; external controller wins. |
| `CupertinoActivityIndicator`| `CupertinoActivityIndicator` | `animating`, `radius`, `color`.          |
| `CupertinoAlertDialog`      | `CupertinoAlertDialog`       | `title`, `content`, `actions` (filtered). |
| `CupertinoDialogAction`     | `CupertinoDialogAction`      | Requires `child`; `onPressed`, default / destructive flags. |

### Values (1)

| Type name             | Backed by            | Notes                                               |
| --------------------- | -------------------- | --------------------------------------------------- |
| `CupertinoThemeData`  | `CupertinoThemeData` | `brightness`, primary/scaffold/bar background colors. |

### Constants (30)

`CupertinoIcons.*` names covering navigation (`left_chevron`, `back`, `forward`, `chevron_up`, `chevron_down`), common actions (`add`, `minus`, `plus`, `xmark`, `check_mark`, `search`, `trash`, `delete`, `pencil`, `share`, `refresh`), content surfaces (`home`, `house`, `person`, `settings`, `gear`, `heart`, `star`, `star_fill`, `info`, `bell`), and communications (`phone`, `mail`, `calendar`, `clock`).

## Requirements

- Flutter >= 3.22
- Dart >= 3.4
- `rune` (sibling package in the same monorepo; current dep: `path: ../..`)

## Install

Until published on `pub.dev`, add as a sibling dep alongside `rune`:

```yaml
dependencies:
  rune:
    path: ../rune
  rune_cupertino:
    path: ../rune/packages/rune_cupertino
```

When this package is published independently, the entry becomes a normal `pub.dev` reference.

## Usage

Construct a `RuneConfig`, apply the bridge via `withBridges`, and pass the config to `RuneView`:

```dart
import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/rune_cupertino.dart';

final config = RuneConfig.defaults()
    .withBridges(const [CupertinoBridge()]);

// then inside a widget tree:
RuneView(
  config: config,
  source: r"""
    CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Home')),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.heart, color: Color(0xFFE53935)),
            CupertinoButton(
              child: Text('Tap'),
              onPressed: 'tapped',
            ),
          ],
        ),
      ),
    )
  """,
  onEvent: (name, [args]) {
    // handle the dispatched event
  },
)
```

## Contract notes

- **Name-prefix discipline.** Every widget, value, and constant registered here is `Cupertino`-prefixed, so the bridge stacks on top of `RuneConfig.defaults()` (Material widget set) without collisions.
- **`CupertinoAlertDialog` is a widget, not an imperative.** Showing the dialog still requires an imperative bridge (e.g. rune's `showDialog(...)` helper) to push it onto the navigator. This bridge exposes the widget itself.
- **`CupertinoTextField` owns a `TextEditingController`** when the source does not supply one, disposing it automatically. Supply a source-level `controller:` to take ownership.
- **Missing callbacks = disabled widget.** When `onPressed` / `onChanged` is absent, the underlying Cupertino widget receives `null`, which Flutter interprets as disabled for buttons, switches, and sliders.
- **Stacking on defaults.** Typical setup is `RuneConfig.defaults().withBridges([const CupertinoBridge()])`. The bridge never replaces Material widgets; it only adds `Cupertino*` type names.

## Tests

```bash
flutter test
```

Seventy-two tests cover bridge registration (widget/value/constants counts), per-widget arg forwarding (required args, default args, event dispatch, disabled paths), the `CupertinoThemeData` value builder, the `CupertinoIcons` constant seed, and end-to-end `RuneView` smokes that mount the Cupertino tree inside a `CupertinoApp` host.

## License

MIT - see [`LICENSE`](LICENSE).
