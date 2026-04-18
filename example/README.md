# rune_example

A runnable Flutter demo of the [`rune`](../) package at its current feature level (Phase 3b, `v0.0.9`).

The app renders a single source string through `RuneView` — parsing, resolving, and building real Flutter widgets at runtime. Taps on the demo buttons route through `RuneView.onEvent` back to the Flutter side, where they update a small event log that the source string reads through data binding.

## What it demonstrates

| Feature                              | Where in the demo                                                                      |
| ------------------------------------ | -------------------------------------------------------------------------------------- |
| Phase 1 widgets                      | `Column`, `Row`, `Container`, `SizedBox`, `Text` throughout.                           |
| Phase 2a constants + interpolation   | `MainAxisAlignment.spaceBetween`, `CrossAxisAlignment.stretch`, `'Hello, ${user.name}!'`. |
| Phase 2a shallow data binding        | `user.name` where `user` is a data map.                                                |
| Phase 2b value builders              | `TextStyle(...)`, `Color(0xFF3F51B5)`, `EdgeInsets.symmetric/all`, `BoxDecoration(color: ..., borderRadius: BorderRadius.circular(8))`. |
| Phase 2c layout + chrome             | `Scaffold` + `AppBar`, `Card` with elevation, `Padding`.                               |
| Phase 2d buttons + events            | `TextButton(onPressed: 'clear', ...)` and `ElevatedButton(onPressed: 'checkout', ...)` — taps update the event log. |
| Phase 3b deep dot-path               | `user.profile.tier` walks nested maps.                                                 |
| Phase 3b list `for`-element          | `for (final item in cart.items) Card(...)` renders one card per cart item.             |
| Phase 3b dot-path on loop variable   | Each card reads `item.title` and `item.price`.                                         |
| Typed error boundary                 | `onError` callback + `fallback` widget if parse/resolve fails.                         |

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

The demo window opens with:

- An `AppBar` titled "Rune Phase 3b Demo" with a custom background color (resolved from `Color(0xFF3F51B5)`).
- A greeting using deep dot-path: `'Hello, ${user.name}!'` and `'Membership tier: ${user.profile.tier}'`.
- A list of `Card`s — one per entry in `cart.items` — rendered via the `for`-element list-literal syntax, each showing the item's title and formatted price (`'\$${item.price}'`).
- Two buttons (`Clear` / `Checkout`) that dispatch `'clear'` and `'checkout'` events. The Flutter-side `onEvent` handler records every tap in a log list that the source string displays in a footer `Container` with rounded corners — round-tripping Dart → source → Dart.

## Where to look

| Path                                                     | Purpose                                                                              |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| [`lib/main.dart`](lib/main.dart)                         | The entire demo. The widget-source string lives in `_RuneExampleAppState._source`.   |
| [`../lib/rune.dart`](../lib/rune.dart)                   | Public API surface re-exported by the parent `rune` package.                          |
| [`../README.md`](../README.md)                           | Full feature catalog, architecture diagram, extension / bridge examples, roadmap.    |
| [`../CHANGELOG.md`](../CHANGELOG.md)                     | Phase-by-phase release notes, `v0.0.1` through `v0.0.9`.                              |

## Customising the demo

Edit `_source` in [`lib/main.dart`](lib/main.dart) to any expression that uses the default (Phase 1–3b) set:

- **Widgets** — Phase 1 (`Text`, `Column`, `Row`, `Container`, `SizedBox`), Phase 2c (`Padding`, `Center`, `Stack`, `Expanded`, `Flexible`, `Card`, `Icon`, `ListView`, `AppBar`, `Scaffold`), Phase 2d (`ElevatedButton`, `TextButton`, `IconButton`).
- **Values** — `EdgeInsets.all/symmetric/only/fromLTRB/zero`, `Color(hex)`, `TextStyle(...)`, `BorderRadius.circular(n)`, `BoxDecoration(...)`, `Image.network(url)`, `Image.asset(path)`.
- **Constants** — `Colors.*`, `MainAxisAlignment.*`, `CrossAxisAlignment.*`, `MainAxisSize.*`, `TextAlign.*`, `TextOverflow.*`, `Alignment.*`, `BoxFit.*`, `StackFit.*`, `Axis.*`, `FontWeight.*`, `BoxShape.*`, `FlexFit.*`, ~60 common `Icons.*`.
- **Literals** — int, double, bool, null, string, list `[...]`, set/map `{...}`, adjacent string concat, string interpolation.
- **Data access** — bare `name` for a top-level key; `user.profile.tier` for nested maps; `items[0].title` for list indexing; `prices['apple']` for map keys; `[for (final x in items) Text(x)]` for data-driven children.
- **Events** — `ElevatedButton(onPressed: 'someEvent', child: Text('Go'))`; handle in Flutter via `RuneView.onEvent`.

Anything outside the current feature surface raises a `RuneException` and the `fallback` renders instead. Watch the console for the captured exception when experimenting.

Want to add your own widget? See the **Extending** section in the root [`README.md`](../README.md#extending). Pack multiple contributions into a reusable `RuneBridge` and wire with `RuneConfig.defaults().withBridges([...])`.

## License

Same MIT license as the parent package — see [`../LICENSE`](../LICENSE).
