# rune_example

A runnable Flutter demo of the [`rune`](../) package.

This app embeds a Dart widget-construction source string in its `build` method, feeds it to a `RuneView`, and renders the result as native Flutter widgets at runtime. No code generation, no reflection — just `analyzer` walking the AST and Rune building widgets through registered builders.

## What it demonstrates

- **Parse → resolve → build pipeline** for the Phase 2a widget/value set: `Column`, `Row`, `Container`, `SizedBox`, `Text`, and `EdgeInsets.all` / `EdgeInsets.zero`.
- **Named constants.** `MainAxisAlignment.center`, `CrossAxisAlignment.start`, and `EdgeInsets.zero` resolve through the default `ConstantRegistry` seeded by `RuneConfig.defaults()`.
- **Data binding.** Free identifiers in the source (`userName`, `itemCount`) read from the `Map<String, Object?>` passed to `RuneView.data`.
- **String interpolation.** `'Hello, $userName!'` and `'You have ${itemCount} items'` substitute data-context values into literal strings.
- **Error boundary.** Parse or resolve failures bubble through the optional `onError` callback and fall back to the supplied `fallback` widget.

## Requirements

- Flutter ≥ 3.22
- Dart ≥ 3.4

## Run

From the repository root:

```bash
cd example
flutter pub get
flutter run -d macos      # or: -d chrome / your attached device
```

The demo window opens with a vertical stack — a greeting, a padded container with cart-count text, and a two-column aligned row — all reconstituted from the `_source` string in [`lib/main.dart`](lib/main.dart).

## Where to look

| Path | Purpose |
| ---- | ------- |
| [`lib/main.dart`](lib/main.dart) | The entire demo. The widget-source string lives in `RuneExampleApp._source`. |
| [`../lib/rune.dart`](../lib/rune.dart) | Public API re-exported by the parent `rune` package (`RuneView`, `RuneConfig`, `RuneException`, builder contracts, …). |
| [`../README.md`](../README.md) | Package overview, feature set, architecture diagram, and roadmap. |

## Customising the demo

Edit `_source` in `lib/main.dart` to any expression that uses the default Phase 2a set:

- **Widgets** — `Column`, `Row`, `Container`, `SizedBox`, `Text`
- **Values** — `EdgeInsets.all(n)`, `EdgeInsets.zero`
- **Constants** — every `Colors.*`, `MainAxisAlignment.*`, `CrossAxisAlignment.*`, `MainAxisSize.*`, `TextAlign.*`, `TextOverflow.*`, `Alignment.*`, `BoxFit.*`, `StackFit.*`, `Axis.*`, `FontWeight.*`
- **Literals** — int, double, bool, null, string, list, set, map, adjacent string concat, string interpolation
- **Identifiers** — bare identifiers resolve against the `data:` map; `TypeName.member` resolves against the constants registry

Anything outside the current feature surface raises a `RuneException` and the `fallback` renders instead. Watch the console for the captured exception when experimenting.

## License

Same MIT license as the parent package — see [`../LICENSE`](../LICENSE).
