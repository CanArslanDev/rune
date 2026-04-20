# rune_example

A runnable Flutter demo of the [`rune`](../) package and its sibling bridges.

The app hosts **four `RuneView`s** inside a Material `DefaultTabController` + `TabBar`. Each tab is a self-contained widget tree rendered from a single Dart source string. Parsed, resolved, and built into real Flutter widgets at runtime. Taps and keystrokes route through `RuneView.onEvent` back to the Flutter side, where the host updates state and re-renders; the `data` map is the feedback channel that the source strings read.

Three of the four tabs run on `RuneConfig.defaults()`. The **Reactive** tab applies `ProviderBridge` from [`rune_provider`](../packages/rune_provider); the **Responsive** tab applies `ResponsiveSizerBridge` from [`rune_responsive_sizer`](../packages/rune_responsive_sizer). Both illustrate the bridge pattern in action.

## What it demonstrates

### Tab 1: Shopping cart

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

### Tab 2: Profile form

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

### Tab 3: Reactive counter (rune_provider)

| Feature                                                         | Where in the source                                                               |
| --------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| `ChangeNotifierProvider.value` scoping a host-owned notifier    | `ChangeNotifierProvider(value: counter, child: Column(...))`                      |
| `Consumer` with `(ctx, state, child)` builder                   | `Consumer(builder: (ctx, state, child) => Text('Count: ${state.count}'))`         |
| `Selector` that rebuilds only when the derived value flips      | `Selector(selector: (ctx, state) => state.parity, builder: ...)`                  |
| `RuneReactiveNotifier.state` exposed to Rune source as a `Map`  | `class _CounterNotifier extends ChangeNotifier implements RuneReactiveNotifier`   |
| Named events dispatched to the host notifier                    | `ElevatedButton(onPressed: 'increment', child: Text('+1'))`                       |

### Tab 4: Responsive layout (rune_responsive_sizer)

| Feature                                                         | Where in the source                                                              |
| --------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `.w` and `.h` percent-of-screen sizing                          | `Container(width: 80.w, height: 8.h, ...)`                                       |
| `.sp` text-scale-aware font sizes                               | `Text('...', style: TextStyle(fontSize: 20.sp))`                                 |
| Stacked containers at varying percentages                       | Three `Container`s at `80%` / `50%` / `30%` widths                              |

Each tab's `RuneView` receives only the data slice it needs. Cart mutations do not touch the form, the counter, or the responsive tab; tabs are fully isolated.

## Requirements

- Flutter >= 3.22
- Dart >= 3.4

## Run

From the repository root:

```bash
cd example
flutter pub get
flutter run -d macos      # or: -d chrome / your attached device
```

The demo window opens with a Material `AppBar` titled "Rune Demo" and a 4-tab scrollable `TabBar`:

- **Cart**. Shows 4 items. Tapping "Remove" on any row pops the first item; when the list shrinks below 3 the "Free shipping unlocked!" footer disappears. Tapping "Checkout" empties the cart and surfaces a SnackBar, at which point the `if (cart.items.isEmpty)` branch renders the empty-state message.
- **Profile**. Type into the Username field; the "Username is required." warning disappears. Type a short Bio; the "Bio should be at least 10 characters." warning disappears once you cross 10 characters. Flip the Switch and Checkbox freely. The Save button's event is `'noop'` until a username exists. Dispatching `noop` does nothing on the host side, so the button appears enabled but is functionally disabled until the form is valid.
- **Reactive**. Tap `+1` / `-1` / `Reset` to mutate the host-owned `ChangeNotifier`. The `Consumer` re-renders on every count change; the `Selector` re-renders only when the parity (`even` / `odd`) flips, demonstrating the rebuild-suppression behavior of `Selector`.
- **Responsive**. Resize the window or rotate the device. The three colored `Container`s track the viewport: the widest stays at 80% of screen width, the middle at 50%, the narrow at 30%. Font sizes scale via `.sp`.

## Where to look

| Path                                                     | Purpose                                                                              |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| [`lib/main.dart`](lib/main.dart)                         | Host. Four Rune source strings live in `_RuneExampleAppState._cartSource`, `_formSource`, `_reactiveSource`, `_responsiveSource`. |
| [`../lib/rune.dart`](../lib/rune.dart)                   | Public API surface re-exported by the parent `rune` package.                         |
| [`../packages/rune_provider`](../packages/rune_provider) | Provider bridge: `ChangeNotifierProvider`, `Consumer`, `Selector`, `RuneReactiveNotifier`. |
| [`../packages/rune_responsive_sizer`](../packages/rune_responsive_sizer) | Percent-of-screen extensions: `.w`, `.h`, `.sp`, `.dm`.                |
| [`../README.md`](../README.md)                           | Full feature catalog, architecture diagram, extension / bridge examples, roadmap.    |
| [`../CHANGELOG.md`](../CHANGELOG.md)                     | Release notes.                                                                       |

## Customising the demo

Edit any of the four source strings in [`lib/main.dart`](lib/main.dart) to use the default feature surface:

- **Widgets.** `Text`, `Column`, `Row`, `Container`, `SizedBox`, `Padding`, `Center`, `Stack`, `Expanded`, `Flexible`, `Card`, `Icon`, `ListView`, `ListTile`, `Divider`, `Spacer`, `Scaffold`, `AppBar`, `ElevatedButton`, `TextButton`, `IconButton`, `TextField`, `Switch`, `Checkbox`, `Image.network`, `Image.asset`, `ListenableBuilder`, and the full v1.x widget catalog (see the main README).
- **Values.** `EdgeInsets.all/symmetric/only/fromLTRB/zero`, `Color(hex)`, `TextStyle(...)`, `BorderRadius.circular(n)`, `BoxDecoration(...)`, `PageRouteBuilder(...)`, plus v1.x value additions.
- **Constants.** `Colors.*`, `MainAxisAlignment.*`, `CrossAxisAlignment.*`, `MainAxisSize.*`, `TextAlign.*`, `TextOverflow.*`, `Alignment.*`, `BoxFit.*`, `StackFit.*`, `Axis.*`, `FontWeight.*`, `BoxShape.*`, `FlexFit.*`, ~60 common `Icons.*`.
- **Literals.** int, double, bool, null, string, list `[...]`, set/map `{...}`, adjacent string concat, string interpolation.
- **Data access.** Bare `name` for a top-level key; `user.profile.tier` for nested maps; `items[0].title` for list indexing; `prices['apple']` for map keys.
- **Control flow in collections.** `if (cond) Widget`, `for (final x in items) Widget`.
- **Expressions.** Ternaries (`a ? b : c`), logical `!` / `&&` / `||`, comparison `==` / `!=` / `<` / `<=` / `>` / `>=`, arithmetic `+` / `-` / `*` / `/` / `%`.
- **Runtime members (whitelisted).** `String.length/isEmpty/isNotEmpty/toUpperCase/toLowerCase/trim/contains/startsWith/endsWith/split/substring/replaceAll`, `List.length/isEmpty/isNotEmpty/first/last/contains/indexOf/join`, `Map.length/isEmpty/isNotEmpty/keys/values/containsKey/containsValue`, `num.abs/round/floor/ceil/toInt/toDouble`, universal `toString()`.
- **Events.** `ElevatedButton(onPressed: 'someEvent', child: Text('Go'))`; handle in Flutter via `RuneView.onEvent`.
- **Input events.** `TextField(..., onChanged: 'usernameChanged')`, `Switch(..., onChanged: 'flagChanged')`, `Checkbox(..., onChanged: 'subscribedChanged')`. The dispatched event carries the new value as its sole argument.
- **Closures.** `(ctx, state, child) => Widget` in `Consumer`, `StatefulBuilder`, `ListenableBuilder`, `FutureBuilder`, `StreamBuilder`, and friends.

Anything outside the current feature surface raises a `RuneException` and the `fallback` renders instead. Watch the console for the captured exception when experimenting.

Want to add your own widget? See the **Extending** section in the root [`README.md`](../README.md#extending). Pack multiple contributions into a reusable `RuneBridge` and wire with `RuneConfig.defaults().withBridges([...])`.

## License

Same MIT license as the parent package. See [`../LICENSE`](../LICENSE).
