# rune_example

A runnable Flutter demo of the [`rune`](../) package at its current feature level (v0.2.0+).

The app hosts **two `RuneView`s** inside a Material `DefaultTabController` + `TabBar`. Each tab is a self-contained widget tree rendered from a single Dart source string — parsed, resolved, and built into real Flutter widgets at runtime. Taps and keystrokes route through `RuneView.onEvent` back to the Flutter side, where the host updates state and re-renders; the `data` map is the feedback channel that the source strings read.

## What it demonstrates

### Tab 1 — Shopping cart

| Feature                                      | Where in the source                                                                           |
| -------------------------------------------- | --------------------------------------------------------------------------------------------- |
| Runtime property on a `List`                 | `'Cart (${cart.items.length} items)'`                                                         |
| `if`-element in a `Column.children`          | `if (cart.items.isEmpty) Padding(... Center(Text('Your cart is empty.')))`                    |
| `for`-element over a list-of-maps            | `for (final item in cart.items) ListTile(...)`                                                |
| Runtime method on a `String`                 | `Text(item.name.toUpperCase())`                                                               |
| Deep dot-path with interpolation             | `Text('\$${item.price}')`, `Text('Subtotal: \$${cart.subtotal}')`                             |
| `ListTile` + `Icon` + trailing `TextButton`  | Each cart row is a `ListTile(leading: Icon(...), title: ..., trailing: TextButton(...))`      |
| `Divider` between sections                   | `Divider()` separator under the item list                                                     |
| Arithmetic comparison + runtime property     | `if (cart.items.length >= 3) Text('Free shipping unlocked!')`                                 |
| Named events with host mutation              | `TextButton(onPressed: 'remove', ...)` and `ElevatedButton(onPressed: 'checkout', ...)`       |

### Tab 2 — Profile form

| Feature                                          | Where in the source                                                                              |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| `TextField` with two-way value binding           | `TextField(value: username, onChanged: 'usernameChanged', labelText: 'Username')`                |
| Multiline `TextField`                            | `TextField(value: bio, onChanged: 'bioChanged', labelText: 'Bio', maxLines: 3)`                  |
| `Switch` with two-way binding                    | `Switch(value: notificationsEnabled, onChanged: 'notificationsChanged')`                         |
| `Checkbox` with two-way binding                  | `Checkbox(value: subscribed, onChanged: 'subscribedChanged')`                                    |
| `Spacer` inside a `Row`                          | `Row(children: [Switch(...), Text('Notifications'), Spacer()])`                                  |
| Conditional validation preview                   | `if (username.isEmpty) Text('Username is required.', ...)`                                       |
| Logical `&&` + runtime `String` properties       | `if (username.isNotEmpty && bio.length < 10) Text('Bio should be at least 10 characters.', ...)` |
| Ternary event selector (soft-disabled button)    | `ElevatedButton(onPressed: username.isEmpty ? 'noop' : 'save', child: Text('Save'))`             |

Both tabs share one `_RuneExampleAppState`; each `RuneView` receives a `data` map scoped to its own slice, and the tab's `onEvent` handler mutates only that slice. Cart actions never disturb the form and vice versa.

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

The demo window opens with a Material `AppBar` titled "Rune v0.2.0+ Demo" and a 2-tab `TabBar`:

- **Cart** — shows 4 items. Tapping "Remove" on any row pops the first item; when the list shrinks below 3 the "Free shipping unlocked!" footer disappears. Tapping "Checkout" empties the cart and surfaces a SnackBar, at which point the `if (cart.items.isEmpty)` branch renders the empty-state message.
- **Profile** — type into the Username field; the "Username is required." warning disappears. Type a short Bio; the "Bio should be at least 10 characters." warning disappears once you cross 10 characters. Flip the Switch and Checkbox freely. The Save button's event is `'noop'` until a username exists — dispatching `noop` does nothing on the host side, so the button appears enabled but is functionally disabled until the form is valid.

## Where to look

| Path                                                     | Purpose                                                                              |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| [`lib/main.dart`](lib/main.dart)                         | Host. Two Rune source strings live in `_RuneExampleAppState._cartSource` and `_formSource`. |
| [`../lib/rune.dart`](../lib/rune.dart)                   | Public API surface re-exported by the parent `rune` package.                          |
| [`../README.md`](../README.md)                           | Full feature catalog, architecture diagram, extension / bridge examples, roadmap.    |
| [`../CHANGELOG.md`](../CHANGELOG.md)                     | Release notes.                                                                       |

## Customising the demo

Edit `_cartSource` or `_formSource` in [`lib/main.dart`](lib/main.dart) to any expression that uses the default feature set:

- **Widgets** — `Text`, `Column`, `Row`, `Container`, `SizedBox`, `Padding`, `Center`, `Stack`, `Expanded`, `Flexible`, `Card`, `Icon`, `ListView`, `ListTile`, `Divider`, `Spacer`, `Scaffold`, `AppBar`, `ElevatedButton`, `TextButton`, `IconButton`, `TextField`, `Switch`, `Checkbox`, `Image.network`, `Image.asset`.
- **Values** — `EdgeInsets.all/symmetric/only/fromLTRB/zero`, `Color(hex)`, `TextStyle(...)`, `BorderRadius.circular(n)`, `BoxDecoration(...)`.
- **Constants** — `Colors.*`, `MainAxisAlignment.*`, `CrossAxisAlignment.*`, `MainAxisSize.*`, `TextAlign.*`, `TextOverflow.*`, `Alignment.*`, `BoxFit.*`, `StackFit.*`, `Axis.*`, `FontWeight.*`, `BoxShape.*`, `FlexFit.*`, ~60 common `Icons.*`.
- **Literals** — int, double, bool, null, string, list `[...]`, set/map `{...}`, adjacent string concat, string interpolation.
- **Data access** — bare `name` for a top-level key; `user.profile.tier` for nested maps; `items[0].title` for list indexing; `prices['apple']` for map keys.
- **Control flow in collections** — `if (cond) Widget`, `for (final x in items) Widget`.
- **Expressions** — ternaries (`a ? b : c`), logical `!` / `&&` / `||`, comparison `==` / `!=` / `<` / `<=` / `>` / `>=`, arithmetic `+` / `-` / `*` / `/` / `%`.
- **Runtime members (whitelisted)** — `String.length/isEmpty/isNotEmpty/toUpperCase/toLowerCase/trim/contains/startsWith/endsWith/split/substring/replaceAll`, `List.length/isEmpty/isNotEmpty/first/last/contains/indexOf/join`, `Map.length/isEmpty/isNotEmpty/keys/values/containsKey/containsValue`, `num.abs/round/floor/ceil/toInt/toDouble`, universal `toString()`.
- **Events** — `ElevatedButton(onPressed: 'someEvent', child: Text('Go'))`; handle in Flutter via `RuneView.onEvent`.
- **Input events** — `TextField(..., onChanged: 'usernameChanged')`, `Switch(..., onChanged: 'flagChanged')`, `Checkbox(..., onChanged: 'subscribedChanged')`. The dispatched event carries the new value as its sole argument.

Anything outside the current feature surface raises a `RuneException` and the `fallback` renders instead. Watch the console for the captured exception when experimenting.

Want to add your own widget? See the **Extending** section in the root [`README.md`](../README.md#extending). Pack multiple contributions into a reusable `RuneBridge` and wire with `RuneConfig.defaults().withBridges([...])`.

## License

Same MIT license as the parent package — see [`../LICENSE`](../LICENSE).
