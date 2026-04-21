# Source syntax reference

Complete list of Dart expressions Rune understands. Anything outside this surface raises a `RuneException` subtype (see [troubleshooting.md](troubleshooting.md) for the hierarchy).

## Literals

| Kind | Example | Notes |
|------|---------|-------|
| int | `42`, `-7` | |
| double | `3.14`, `1e-3` | |
| bool | `true`, `false` | |
| null | `null` | |
| String (single / double-quoted) | `'hello'`, `"hi"` | |
| Adjacent strings | `'a' 'b' 'c'` -> `'abc'` | |
| String interpolation | `'Hi, $name'`, `'Count: ${n + 1}'` | Expressions resolve against data + constants + operators |
| List | `[1, 2, 3]` | Nested lists supported |
| Set | `{1, 2, 3}` | Empty `{}` defaults to `Set` per Dart rules |
| Map | `{'a': 1, 'b': 2}` | Mixed keys supported |

## Widgets and value constructors

Bare-call syntax is idiomatic:

```
Text('hello')
Column(children: [...])
Padding(padding: EdgeInsets.all(16), child: Card(...))
```

Named constructors work too:

```
EdgeInsets.all(16)
Color.fromARGB(255, 10, 20, 30)
ListView.builder(itemCount: 10, itemBuilder: (ctx, i) => Text('$i'))
```

Explicit `new` works but is never required:

```
new Text('hi')            // equivalent to Text('hi')
new EdgeInsets.all(16)    // equivalent to EdgeInsets.all(16)
```

**Default registry**: `RuneConfig.defaults()` ships 80+ widget builders and 24+ value constructors. See the `README.md` "Supported source syntax" table for the full catalog, or register your own via `config.widgets.registerBuilder(...)` / `config.values.registerBuilder(...)`.

## Constants

`Type.member` form for registered enum values and static constants:

```
Colors.red, Colors.blue.shade200
MainAxisAlignment.center
CrossAxisAlignment.stretch
FontWeight.bold, FontWeight.w500
Icons.shopping_cart, Icons.add
BoxFit.cover
```

Default registry ships:

- Material colors: `Colors.*` with `.shade100`..`.shade900` indexing
- Layout enums: `MainAxisAlignment`, `CrossAxisAlignment`, `MainAxisSize`, `TextAlign`, `TextOverflow`, `Alignment`, `BoxFit`, `StackFit`, `Axis`, `FlexFit`, etc.
- Typography: `FontWeight`, `TextDecoration`
- Shape: `BoxShape`, `Clip`, `DecorationPosition`
- ~60 Material Icons
- Cupertino, NavigationBar, Bottom sheet, Date/time, and ~15 more

Extend with `config.constants.registerAll('MyEnum', {'a': MyEnum.a, ...})`.

## Identifiers and data access

| Form | Resolution |
|------|-----------|
| `userName` (bare) | Looks up `data['userName']`; `BindingException` on miss |
| `user.name` | `data['user']['name']` (nested map) OR if `user` is not a map, built-in property whitelist (`String.length`, etc.), then `MemberRegistry` entries |
| `user.profile.tier` | Arbitrary depth, each level a map |
| `items[0]` | List indexing |
| `items[0].title` | Chained |
| `prices['apple']` | Map indexing (string keys) |

Missing keys on `data['user'][...]` yield `null` at the leaf, matching Dart's map semantics.

## Control flow in collections

Inside a list literal (typical use: `Column.children`, `Row.children`, `ListView.children`):

```
Column(children: [
  Text('header'),
  if (cart.items.isEmpty) Text('Your cart is empty'),
  for (final item in cart.items)
    ListTile(title: Text(item.name)),
  if (cart.items.isNotEmpty)
    ElevatedButton(onPressed: 'checkout', child: Text('Go')),
])
```

- `if (cond) Widget` or `if (cond) A else B`: short-circuits the untaken branch.
- `for (final x in iterable) Widget`: standard for-element, nested supported.
- `...spread`: supported inside list literals.

## Operators

| Category | Operators |
|----------|-----------|
| Comparison | `==`, `!=`, `<`, `<=`, `>`, `>=` |
| Arithmetic | `+`, `-`, `*`, `/`, `%` (num + num only) |
| Logical | `!`, `&&`, `||` (short-circuit) |
| Unary | `-` (num negation), `!` (bool negation) |
| Ternary | `cond ? a : b` |

## Runtime properties and methods (whitelisted)

Rune ships a closed whitelist. Trying `foo.notInWhitelist` raises `ResolveException` with a did-you-mean suggestion.

**Properties**

| Target type | Whitelisted |
|-------------|-------------|
| `String` | `length`, `isEmpty`, `isNotEmpty` |
| `List` | `length`, `isEmpty`, `isNotEmpty`, `first`, `last` |
| `Map` | `length`, `isEmpty`, `isNotEmpty`, `keys`, `values` |
| `AsyncSnapshot` | `hasData`, `data`, `hasError`, `error`, `connectionState` |
| `BoxConstraints` | `maxWidth`, `minWidth`, `maxHeight`, `minHeight`, `biggest`, `smallest` |
| `ThemeData`, `ColorScheme`, `TextTheme`, `MediaQueryData`, `Size`, `EdgeInsets`, `Route`, `RouteSettings` | Common ergonomic getters (see `lib/src/resolver/builtin_members.dart`) |

Custom types: register via `config.members.registerProperty<MyType>('propName', (target, ctx) => target.propName)` (v1.17.0+).

**Methods**

| Target type | Whitelisted |
|-------------|-------------|
| `String` | `toString`, `toUpperCase`, `toLowerCase`, `trim`, `contains`, `startsWith`, `endsWith`, `split`, `substring`, `replaceAll` |
| `List` | `contains`, `indexOf`, `join`, `map`, `where`, `any`, `every`, `firstWhere`, `forEach`, `fold`, `reduce`, `toString` |
| `Map` | `containsKey`, `containsValue`, `toString` |
| `num` | `abs`, `round`, `floor`, `ceil`, `toInt`, `toDouble`, `toString` |
| Controllers (`TextEditingController`, `ScrollController`, `FocusNode`, `PageController`, `TabController`, `AnimationController`) | Type-specific (`.clear()`, `.jumpTo()`, `.requestFocus()`, `.forward()`, etc.) |
| `Animatable` | `animate`, `chain` |

Custom types: register via `config.members.registerMethod<MyType>('methodName', (target, args, ctx) => ...)`.

## Named events and closures

`onPressed:`, `onChanged:`, and similar event-shaped callbacks accept **either** a string name or a closure:

```
// Dispatched as a named event
ElevatedButton(onPressed: 'save', child: Text('Save'))

// Inline closure
ElevatedButton(
  onPressed: () => counter.increment(),
  child: Text('+1'),
)
```

Closures have the usual Dart shape: `(param1, param2) => body` or `(param1, param2) { stmt1; stmt2; }`. Block bodies support statement sequences, variable declarations, and the `setState(() { ... })` wrapper used by `StatefulBuilder`.

## Imperative bridges

Top-level calls that route to Flutter's imperative APIs rather than to a widget builder:

| Source call | What it does |
|-------------|--------------|
| `showDialog(context: ctx, builder: ...)` | Flutter's `showDialog` |
| `showModalBottomSheet(...)` | Flutter's `showModalBottomSheet` |
| `showSnackBar(snackBar)` | `ScaffoldMessenger.of(ctx).showSnackBar` |
| `showDatePicker(...)`, `showTimePicker(...)` | Date / time picker |
| `showMenu(position, items, ...)` | Popup menu |
| `Navigator.push(route)` / `Navigator.pop(result)` / `Navigator.pushNamed(name)` / `Navigator.pushReplacement(route)` / `Navigator.canPop()` / `Navigator.popUntil(predicate)` | Navigation imperatives |
| `Theme.of(ctx)` / `MediaQuery.of(ctx)` | Context accessors returning the theme / media query |

Register your own imperatives via `config.imperatives.registerBare('myCall', handler)` or `config.imperatives.registerPrefixed('MyTarget', 'method', handler)` (v1.16.0+).

## Stateful source

Source-level state via `StatefulBuilder`:

```
StatefulBuilder(
  initial: {'count': 0},
  builder: (state) => Column(children: [
    Text('Count: ${state.count}'),
    ElevatedButton(
      onPressed: () => setState(() { state.count = state.count + 1; }),
      child: Text('+1'),
    ),
  ]),
)
```

`state` is a mutable bag. Read with dot-access (`state.count`); write with `state.key = value` or `setState(() { state.key = newValue; })`. `setState` re-renders the subtree.

`StatefulBuilder` also supports lifecycle hooks (`initState`, `dispose`, `didUpdateWidget`) and an `autoDisposeListenables: true` option that cleans up any `ChangeNotifier` entries on unmount.

## Components

Reusable source fragments declared inline:

```
RuneCompose(
  components: [
    RuneComponent(
      name: 'Header',
      params: ['title'],
      body: (title) => Text(title, style: TextStyle(fontSize: 24)),
    ),
  ],
  root: Column(children: [
    Header(title: 'Hello'),
    Header(title: 'World'),
  ]),
)
```

Components shadow widget/value registries, so `Header` inside `root` resolves to the component before any default builder named `Header`.

## What is NOT supported

Deliberately excluded to preserve the store-review-compliance posture:

- Arbitrary function calls on non-whitelisted receivers (`foo.doSomething()` where `foo` is a custom type the host did not register).
- Class declarations (`class Foo { ... }`).
- Top-level function declarations.
- Private identifiers (`_privateField`).
- `dynamic`, `late`, `final`, `var` declarations at the top level.
- `async` / `await` (use `FutureBuilder` or named events that the host handles asynchronously).
- `throw` / `try` / `catch` (errors flow through the host's `onError` callback).
- Cascade `..` notation.
- String-to-type reflection, any form of `mirrors`.

See [troubleshooting.md](troubleshooting.md) for the exception taxonomy that surfaces when you hit one of these.
