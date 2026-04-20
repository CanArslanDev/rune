# Rune

> Turn Dart widget-construction source strings into live Flutter widgets at runtime.

[![Flutter](https://img.shields.io/badge/flutter-%E2%89%A5%203.22-blue)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%E2%89%A5%203.4-blue)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![API docs](https://img.shields.io/badge/api-docs-blue)](https://canarslandev.github.io/rune/)



Rune parses a string of Dart widget syntax (e.g. `Column(children: [Text('Hello')])`), walks the resulting AST via the official [`analyzer`](https://pub.dev/packages/analyzer) package, and constructs real Flutter widgets through pre-registered builders.

No `dart:mirrors`. No `eval`. No runtime code execution. The widgets that come out are ordinary Flutter widgets: they compose, animate, and perform like hand-written code.


<img width="1200" alt="Banner (1)" src="https://github.com/user-attachments/assets/8bd42ffa-e9ce-41ba-a0af-a85552c7d332" />

## Why

Deliver UI from a server, a CMS, or a designer tool without shipping a new app binary. The `source` you pass to a `RuneView` can be edited, A/B-tested, or user-authored. Because Rune only interprets a constrained subset of Dart expression syntax (never executing arbitrary code), it's compatible with Apple App Store and Google Play store-review policies.

## Features

- **Runtime interpretation, not compilation.** `analyzer` produces the AST; Rune walks it.
- **Store-compliant.** No `dart:mirrors`, no eval, no on-device code generation.
- **Layered and open/closed.** Adding a new widget is one builder file, one registration, one test, with no core change.
- **Strict typing.** Dart 3 sealed exceptions, pattern matching, `final class`, `@immutable`. `dynamic` is banned outside the parser boundary.
- **Single runtime dependency** besides Flutter: `analyzer`. All other integrations (responsive scaling, state management, routing, ...) live in separate bridge packages.
- **Rich data binding.** Free identifiers (`userName`), deep dot-path (`user.profile.name`), list/map indexing (`items[0].title`), and data-driven widget lists (`for (final item in items) ...`), all resolved against a `Map<String, Object?>` you supply.
- **String interpolation.** `'Hello, $name!'` and `'Count: ${n}'` substitute data-context values into literal strings.
- **Named events.** `ElevatedButton(onPressed: "submit")` routes taps through `RuneView.onEvent(name, args)` to the host app.
- **Extensible.** A `RuneBridge` package registers widget/value/constant/extension handlers with one `registerInto(config)` call. `10.w`, `size.half`, and similar receiver-style property access go through `PropertyResolver` → `ExtensionRegistry`.
- **Typed error surface.** Every failure raises a `RuneException` subtype carrying the offending source substring plus a human-readable message. `RuneView.fallback` + `onError` make failures non-fatal.
- **`very_good_analysis`-strict.** The whole package passes the strict lint floor with zero ignores beyond two documented exceptions.

## Install

```yaml
dependencies:
  rune: ^1.16.0
```

The package is pre-publication; use a `git:` or `path:` dependency until a tagged `pub.dev` release lands. `dart pub publish --dry-run` currently reports 0 errors / 0 warnings.

Upgrading from an earlier release? See [`MIGRATION.md`](MIGRATION.md) for version-to-version notes. API reference documentation is generated on every tag push and hosted at [canarslandev.github.io/rune/](https://canarslandev.github.io/rune/).

## Quickstart

```dart
import 'package:flutter/material.dart';
import 'package:rune/rune.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Rune Demo')),
        body: RuneView(
          source: r"""
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Hello, $userName!'),
                SizedBox(height: 8),
                Text('You have ${cart.itemCount} items.'),
                SizedBox(height: 16),
                for (final item in cart.items)
                  Card(
                    child: ListTile(
                      title: Text(item.title),
                      subtitle: Text(item.subtitle),
                    ),
                  ),
                ElevatedButton(
                  onPressed: 'checkout',
                  child: Text('Checkout'),
                ),
              ],
            )
          """,
          config: RuneConfig.defaults(),
          data: const {
            'userName': 'Ali',
            'cart': {
              'itemCount': 3,
              'items': [
                {'title': 'Mouse', 'subtitle': '\$19'},
                {'title': 'Keyboard', 'subtitle': '\$79'},
                {'title': 'Monitor', 'subtitle': '\$299'},
              ],
            },
          },
          onEvent: (name, [args]) => debugPrint('event: $name'),
          fallback: const Text('Failed to render.'),
          onError: (error, stack) => debugPrint('Rune error: $error'),
        ),
      ),
    ),
  );
}
```

A runnable version lives in [`example/`](example/).

## Supported source syntax

Current release: **v1.16.0**. Pluggable imperative registry. `RuneConfig.imperatives` lets hosts and sibling bridges register source-level imperatives (`Router.go('/path')`, `showToast('hi')`, `Analytics.track(...)`) without needing a main-package update. The resolver consults the registry before the hardcoded v1.3+ built-ins, so registered handlers can also shadow defaults. Unblocks `rune_router` v0.2.0's source-level navigation.

| Category              | Elements                                                                                                                                                                                                     |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Widgets               | `Text`, `SizedBox`, `Container`, `Column`, `Row`, `Padding`, `Center`, `Stack`, `Expanded`, `Flexible`, `Card`, `Icon`, `ListView`, `AppBar`, `Scaffold`, `ElevatedButton`, `TextButton`, `IconButton`, `TextField`, `Switch`, `Checkbox`, `ListTile`, `Divider`, `Spacer`, `GestureDetector`, `InkWell`, `SingleChildScrollView`, `Wrap`, `AspectRatio`, `Positioned`, `Slider`, `Radio`, `CheckboxListTile`, `SwitchListTile`, `RadioListTile`, `AnimatedContainer`, `AnimatedOpacity`, `AnimatedPositioned`, `BottomNavigationBar`, `TabBar`, `Tab`, `DropdownButton`, `DropdownMenuItem`, `FloatingActionButton`, `Chip`, `ChoiceChip`, `FilterChip`, `Badge`, `CircularProgressIndicator`, `LinearProgressIndicator`, `Hero`, `AnimatedSwitcher`, `AnimatedCrossFade`, `AnimatedSize`, `GridView.count`, `GridView.extent`, `Drawer`, `SafeArea`, `Visibility`, `Opacity`, `ClipRRect`, `ClipOval`, `Tooltip`, `CustomScrollView`, `SliverList`, `SliverToBoxAdapter`, `SliverAppBar`, `SliverPadding`, `SliverFillRemaining`, `SliverGrid.count`, `SliverGrid.extent`, `FittedBox`, `ColoredBox`, `DecoratedBox`, `Offstage`, `Semantics`, `ConstrainedBox`, `LimitedBox`, `UnconstrainedBox`, `FractionallySizedBox`, `NavigationBar`, `NavigationRail`, `StatefulBuilder`, `RuneCompose`, `FutureBuilder`, `StreamBuilder`, `LayoutBuilder`, `OrientationBuilder`, `AlertDialog`, `SimpleDialog`, `SimpleDialogOption`, `Dialog`, `PopupMenuButton`, `PopupMenuItem`, `PopupMenuDivider`, `FilledButton`, `OutlinedButton`, `SegmentedButton`, `SearchBar`, `SearchAnchor`, `Form`, `TextFormField`, `Focus`, `FocusScope`, `Draggable`, `LongPressDraggable`, `DragTarget`, `Dismissible`, `InteractiveViewer`, `ReorderableListView`, `DataTable`, `ExpansionTile`, `ExpansionPanelList`, `Stepper`, `FadeTransition`, `SlideTransition`, `ScaleTransition`, `RotationTransition`, `SizeTransition`, `AnimatedBuilder`, `ListenableBuilder`, `CheckedPopupMenuItem`, `BottomSheet`, `PaginatedDataTable` |
| Value ctors           | `EdgeInsets.all/symmetric/only/fromLTRB/zero`, `Color(hex)`, `TextStyle(...)`, `BorderRadius.circular(n)`, `BoxDecoration(...)`, `Image.network(url)`, `Image.asset(path)`, `Duration(...)`, `BottomNavigationBarItem(...)`, `Transform.scale/.rotate`, `Transform.translate`, `Transform.flip`, `Offset(dx, dy)`, `BoxConstraints(...)`, `NavigationDestination(...)`, `NavigationRailDestination(...)`, `RuneComponent(...)`, `TextEditingController(...)`, `ScrollController(...)`, `FocusNode(...)`, `PageController(...)`, `ListView.builder`, `GridView.countBuilder`, `GridView.extentBuilder`, `SliverList.builder`, `SliverGrid.countBuilder`, `SliverGrid.extentBuilder`, `SnackBar(...)`, `ColorScheme.fromSeed(...)`, `ThemeData(...)`, `ButtonSegment(...)`, `DateTime(...)`, `TimeOfDay(...)`, `MaterialPageRoute(...)`, `CupertinoPageRoute(...)`, `RouteSettings(...)`, `ValueKey(value)`, `DataColumn(...)`, `DataRow(...)`, `DataCell(...)`, `ExpansionPanel(...)`, `Step(...)`, `AnimationController(...)`, `Tween(...)`, `ColorTween(...)`, `CurvedAnimation(...)`, `PageRouteBuilder(...)`, `SnackBarAction(...)`, `RelativeRect.fromLTRB(...)`, `FilledButton.tonal(...)`, `RuneDataTableSource(...)`                 |
| Constants             | `Colors.*`, `MainAxisAlignment.*`, `CrossAxisAlignment.*`, `MainAxisSize.*`, `TextAlign.*`, `TextOverflow.*`, `Alignment.*`, `BoxFit.*`, `StackFit.*`, `Axis.*`, `FontWeight.*`, `BoxShape.*`, `FlexFit.*`, `BottomNavigationBarType.*`, `CrossFadeState.*`, `Clip.*`, `DecorationPosition.*`, `ListTileControlAffinity.*`, `NavigationRailLabelType.*`, `Curves.linear/easeIn/easeOut/easeInOut/bounce*/elastic*/fastOutSlowIn`, ~60 common `Icons.*`, `ConnectionState.*`, `Orientation.*`, `SnackBarBehavior.*`, `ThemeMode.*`, `Brightness.*`, `MaterialTapTargetSize.*`, `AutovalidateMode.*`, `DismissDirection.*`, `StepperType.*`, `StepState.*`, `AnimationStatus.*` |
| Literals              | int, double, bool, null, string, list `[...]`, set/map `{...}`, adjacent string concat                                                                                                                       |
| Interpolation         | `'Hello $name'`, `'Count: ${n}'` (expressions resolve against data + constants)                                                                                                                              |
| Identifiers           | Bare `name` → `data['name']`; `Type.member` → data `Map` traversal OR constants registry                                                                                                                     |
| Deep data paths       | `user.profile.name`, `items[0].title`, `Colors.grey[200]` (any depth of nested maps plus list/map/MaterialColor indexing)                                                                                    |
| Collections           | `[for (final item in items) Text(item.title)]` (data-driven widget lists, nested for-elements, static + for elements interleaved)                                                                            |
| Built-in properties   | `.length`, `.isEmpty`, `.isNotEmpty`, `.first`, `.last` on lists; `.length`, `.isEmpty`, `.isNotEmpty` on strings; `.length`, `.isEmpty`, `.isNotEmpty`, `.keys`, `.values` on maps; `.hasData`/`.data`/`.hasError`/`.error`/`.connectionState` on `AsyncSnapshot`; `.maxWidth`/`.minWidth`/`.maxHeight`/`.minHeight`/`.biggest`/`.smallest` on `BoxConstraints`; ThemeData, ColorScheme, TextTheme, MediaQueryData, Size, EdgeInsets property access (see CHANGELOG)                                 |
| Built-in methods      | `toString()` (any); `toUpperCase/toLowerCase/trim/contains/startsWith/endsWith/split/substring/replaceAll` on strings; `contains/indexOf/join` on lists plus closure-accepting `map/where/any/every/firstWhere/forEach/fold/reduce`; `containsKey/containsValue` on maps; `abs/round/floor/ceil/toInt/toDouble` on num  |
| Events                | `ElevatedButton(onPressed: 'submit', ...)` → `RuneView.onEvent('submit', [])`                                                                                                                                |
| Property extensions   | `10.w`, `size.half` (via `RuneBridge` packages registering handlers)                                                                                                                                         |
| Operators             | `==` `!=` `<` `<=` `>` `>=` on num+num or String+String; `&&` `\|\|` (short-circuit); `+` `-` `*` `/` `%` on num; `!` on bool; unary `-` on num                                                              |
| Conditionals          | Ternary `cond ? a : b`; list-literal `[if (cond) widget]` / `[if (cond) a else b]` (both short-circuit the un-taken branch)                                                                                  |
| Stateful source       | `StatefulBuilder(initial: {...}, builder: (state) => ...)` produces source-level state; `state.key` reads, `state.key = value` assigns, `setState(() { ... })` wraps a batch of mutations. Optional `initState` / `dispose` / `didUpdateWidget` closures own the full mount / unmount / rebuild lifecycle; `autoDisposeListenables: true` disposes any `ChangeNotifier` entries automatically on unmount. |
| Components            | `RuneComponent(name: 'X', params: [...], body: (...) => ...)` declares a reusable component; `RuneCompose(components: [...], root: ...)` groups declarations and the widget tree; components dispatch before widget/value registries. |
| Imperative bridges    | `showDialog(builder: ...)`, `showModalBottomSheet(builder: ...)`, `showSnackBar(snackBar)`, `Navigator.pop(result?)`, `showDatePicker(initialDate, firstDate, lastDate)`, `showTimePicker(initialTime)`, `Navigator.push(route)`, `Navigator.pushReplacement(route)`, `Navigator.pushNamed(name, arguments?)`, `Navigator.canPop()`, `Navigator.popUntil(predicate)`, `showMenu(position, items, ...)`. All route through `RuneContext.flutterContext`. |
| Context accessors     | `Theme.of(context)`, `MediaQuery.of(context)`. Return raw Flutter values with whitelisted property access. |
| Developer utilities | `formatRuneSource(source)` canonical formatter; `SourceSpan.toContextualPointer(source, contextLines)` widened error pointer; "did you mean X?" suggestions on missing builder / method / identifier diagnostics. |
| Sibling bridges | Cupertino widgets via `rune_cupertino`; `ChangeNotifierProvider` / `Consumer` / `Selector` via `rune_provider`; `GoRoute` / `GoRouter` / `GoRouterApp` via `rune_router`; `.w` / `.h` / `.sp` / `.dm` responsive extensions via `rune_responsive_sizer` (see Bridge packages section below). |

Anything outside this surface raises a `RuneException` (parse, resolve, or unregistered-builder variant). The plans in `docs/superpowers/plans/` enumerate the phases that built this set.

## Architecture

A unidirectional pipeline:

```
RuneView (StatefulWidget)
  │
  ▼
RuneConfig
  ├─ WidgetRegistry        : Phase 1-2d widget builders
  ├─ ValueRegistry         : Phase 1-2c value ctors
  ├─ ConstantRegistry      : Colors, enums, Icons
  └─ ExtensionRegistry     : Phase 3a .w/.px/.half handlers
  (+ withBridges([...])    : RuneBridge-packaged third-party contributions)
  │
  ▼
RuneContext  (carries data, events, all four registries, optional Flutter BuildContext)
  │
  ▼
DartParser ─────────▶ AstCache (LRU)
  │
  ▼
ExpressionResolver (dispatcher on Expression AST subtype)
  ├─ LiteralResolver       : literals + adjacent-string concat
  ├─ IdentifierResolver    : SimpleIdentifier / PrefixedIdentifier (data-first, constants fallback)
  ├─ PropertyResolver      : PropertyAccess (Map-first for deep paths, extensions for scalars)
  ├─ InvocationResolver    : MethodInvocation / InstanceCreationExpression
  └─ (inline)              : ListLiteral + ForElement, SetOrMapLiteral, IndexExpression, StringInterpolation
                              │
                              ▼
                        Registered widget/value builder
                              │
                              ▼
                        Real Flutter Widget
```

Architecture invariants (imports flow only downward) are enforced by `test/architecture/import_flow_test.dart`.

## Extending

### Register a new widget

```dart
final class FooBarBuilder implements RuneWidgetBuilder {
  const FooBarBuilder();

  @override
  String get typeName => 'FooBar';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return FooBar(
      label: args.requirePositional<String>(0, source: 'FooBar'),
      isActive: args.getOr<bool>('isActive', false),
    );
  }
}

final config = RuneConfig.defaults()
  ..widgets.registerBuilder(const FooBarBuilder());
```

### Register a new constant group

```dart
config.constants
  ..register('BrandTheme', 'primary', const Color(0xFF0088FF))
  ..register('BrandTheme', 'accent', const Color(0xFFFF6B35));
```

Source strings can then use `Container(color: BrandTheme.primary, ...)`.

### Register a property extension

```dart
config.extensions.register('pct', (target, ctx) {
  if (target is num) return target / 100;
  throw ArgumentError('Expected num for .pct');
});
```

Source strings can then use `SizedBox(width: (50).pct * MediaQuery.of(...))`, or, more realistically, a bridge that uses `ctx.flutterContext` to do proper responsive math.

### Ship a reusable bundle as a bridge

```dart
final class BrandBridge implements RuneBridge {
  const BrandBridge();

  @override
  void registerInto(RuneConfig config) {
    config.widgets.registerBuilder(const BrandButtonBuilder());
    config.constants
      ..register('BrandTheme', 'primary', const Color(0xFF0088FF))
      ..register('BrandTheme', 'accent', const Color(0xFFFF6B35));
    config.extensions.register('spacing', (t, c) {
      if (t is num) return t * 8.0; // 8-pt grid
      throw ArgumentError('spacing expects num');
    });
  }
}

final config = RuneConfig.defaults()
    .withBridges(const [BrandBridge(), OtherBridge()]);
```

The `RuneDefaults` helper exposes the same surface internally: `RuneDefaults.registerWidgets(registry)` / `registerValues` / `registerConstants` / `registerAll(config)`. Handy for custom configs that want only a subset of defaults.

A live working bridge ships at [`packages/rune_responsive_sizer`](packages/rune_responsive_sizer): a ~70-line implementation that adds `.w` / `.h` / `.sp` / `.dm` responsive-sizing extensions. Use it as both a consumer (pair it with `rune` via path dep) and a reference for writing your own bridges.

## Error handling

- `RuneException` is a `sealed class` with five variants:
  - `ParseException`: `analyzer` could not produce an AST.
  - `ResolveException`: a resolver encountered an unsupported shape or missing extension.
  - `UnregisteredBuilderException`: a type name has no matching builder (exposes `typeName`).
  - `ArgumentException`: a required builder argument was missing or of the wrong type.
  - `BindingException`: an identifier referenced a key that is not present in `RuneDataContext`.
- Every exception carries the offending `source` substring plus a human-readable `message`.
- `RuneView` catches all exceptions, calls the optional `onError` callback, then renders `fallback`. In debug builds with no `fallback`, Flutter's red-screen `ErrorWidget` is shown; in release builds the view silently collapses to an empty `SizedBox`.
- `RuneEventDispatcher.dispatch` is crash-safe: handler throws (including arity mismatches) are caught and `debugPrint`-logged; they never escape into the render pipeline.

### Source-location diagnostics

Every `RuneException` carries an optional `location` field: a `SourceSpan` pointing into the `RuneView.source` where the error originates. When present, `toString()` renders a caret pointer beneath the one-line summary:

```
ResolveException: Unknown identifier "userNmae" (not present in RuneDataContext) (source: "userNmae")
  at line 2, column 9:
    Text(userNmae)
         ^^^^^^^^
```

Access the structured data programmatically for custom diagnostics UI:

```dart
RuneView(
  source: mySource,
  onError: (error, _) {
    if (error is RuneException) {
      final loc = error.location;
      if (loc != null) {
        debugPrint('Rune error at L${loc.line}:C${loc.column}: ${error.message}');
        debugPrint(loc.toPointerString());
      }
    }
  },
);
```

Locations are populated for parse errors (analyzer diagnostics with offsets), every resolver throw site (via the AST node's offset/length), and bubbled builder `ArgumentException`s (rewrapped at the invocation). They are `null` for defensive throw sites that have no user-visible offset (e.g., the wrapped-variable-had-no-initializer invariant check inside `DartParser`), so consumers should treat the field as optional.

## Testing

```bash
flutter test
flutter analyze
```

1701 root tests plus 146 sibling-package tests (7 in `rune_responsive_sizer`, 117 in `rune_cupertino`, 19 in `rune_provider`, 20 in `rune_router`) cover every resolver, every builder, every registry, the architecture invariants, and end-to-end `RuneView` renders. Main is kept green at all times; every commit passes both gates under `very_good_analysis ^5.1.0`, and CI runs the full matrix on every push.

## Example

See [`example/`](example/) for a runnable 4-tab demo that exercises the full current feature set including `rune_provider` and `rune_responsive_sizer`.

## Cookbook

Common recipes for shaping Rune source to solve real problems. Copy, paste, adapt.

### Two-way binding on a TextField

```dart
RuneView(
  data: {'username': username},
  source: r"""
    TextField(
      value: username,
      onChanged: 'usernameChanged',
      labelText: 'Username',
    )
  """,
  onEvent: (name, [args]) {
    if (name == 'usernameChanged') {
      setState(() => username = args!.first as String);
    }
  },
)
```

The `value:` arg is read on every rebuild; the `onChanged:` event dispatches the new text. Same pattern works for `Switch(value:, onChanged:)`, `Checkbox(value:, onChanged:)`, and `Slider(value:, onChanged:)`.

### Conditional rendering without a ternary

```
Column(children: [
  if (cart.items.isEmpty) Text('Your cart is empty.'),
  if (cart.items.isNotEmpty)
    for (final item in cart.items) ListTile(title: Text(item.name)),
  if (cart.items.length >= 3) Text('Free shipping unlocked!'),
])
```

`if`-elements short-circuit cleanly inside `Column.children` / `Row.children`. Use `if (a) X else Y` for either-or branches.

### Dispatching a disabled button via event selection

```
ElevatedButton(
  onPressed: username.isEmpty ? 'noop' : 'save',
  child: Text('Save'),
)
```

Route the same button to a no-op event until a predicate is satisfied. The button stays visually enabled; the host simply ignores `'noop'`.

### Reactive counter with `rune_provider`

Host defines a `ChangeNotifier` that also implements `RuneReactiveNotifier`:

```dart
class CounterNotifier extends ChangeNotifier
    implements RuneReactiveNotifier {
  int _count = 0;
  int get count => _count;
  void increment() {
    _count += 1;
    notifyListeners();
  }

  @override
  Map<String, Object?> get state => {'count': _count};
}
```

Source consumes it through the `ProviderBridge`:

```
ChangeNotifierProvider(
  value: counter,
  child: Consumer(
    builder: (ctx, state, child) => Text('Count: ${state.count}'),
  ),
)
```

The `Map`-shaped `state` getter lets Rune's property resolver reach individual fields via ordinary dot-access.

### Percent-of-screen sizing with `rune_responsive_sizer`

```dart
final config = RuneConfig.defaults()
    .withBridges(const [ResponsiveSizerBridge()]);
```

Source uses `.w` / `.h` / `.sp` extensions on num literals:

```
Container(
  width: 80.w,
  height: 8.h,
  child: Text('Hi', style: TextStyle(fontSize: 16.sp)),
)
```

### Named + anonymous navigation with `rune_router`

Declare routes inline; mount through `GoRouterApp`:

```
GoRouterApp(
  router: GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (ctx, state) => Scaffold(
          body: Center(child: Text('Home')),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (ctx, state) => Scaffold(
          body: Center(child: Text('Settings')),
        ),
      ),
    ],
  ),
)
```

Navigate host-side by holding a reference to the `GoRouter`: `router.go('/settings')`.

## Writing a bridge

A `RuneBridge` is one class with one method. Everything else is ordinary Flutter.

### 1. Scaffold a package

```
packages/my_bridge/
  pubspec.yaml       # depends on rune: path: ../..
  analysis_options.yaml
  lib/
    my_bridge.dart   # barrel: export 'src/my_bridge_impl.dart' show MyBridge;
    src/
      my_bridge_impl.dart
      widgets/
        my_widget_builder.dart
  test/
    my_bridge_test.dart
```

### 2. Implement the bridge

```dart
import 'package:rune/rune.dart';

final class MyBridge implements RuneBridge {
  const MyBridge();

  @override
  void registerInto(RuneConfig config) {
    config.widgets.registerBuilder(const MyWidgetBuilder());
    config.values.registerBuilder(const MyValueBuilder());
    config.constants.registerAll('MyConstants', {
      'green': MyColors.green,
      'red': MyColors.red,
    });
    config.extensions.register('percent', (target, ctx) {
      if (target is num) return '$target%';
      throw ArgumentError('.percent expects num');
    });
  }
}
```

### 3. Author a widget builder

```dart
final class MyWidgetBuilder implements RuneWidgetBuilder {
  const MyWidgetBuilder();

  @override
  String get typeName => 'MyWidget';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return MyWidget(
      title: args.require<String>('title', source: 'MyWidget'),
      color: args.get<Color>('color'),
    );
  }
}
```

For closure-accepting slots (`builder:`, `onPressed:` with a closure body, etc.), see `packages/rune_cupertino/lib/src/widgets/cupertino_tab_scaffold_builder.dart` for the canonical pattern that imports `RuneClosure` through a narrowly-suppressed `implementation_imports`.

### 4. Consume it

```dart
final config = RuneConfig.defaults()
    .withBridges(const [MyBridge()]);

RuneView(config: config, source: "MyWidget(title: 'Hi')");
```

The four sibling bridges in [`packages/`](packages/) are live reference implementations. Start from `rune_responsive_sizer` (smallest, extension-only), then `rune_cupertino` (widget-heavy), then `rune_provider` (closure-heavy), then `rune_router` (value-builder-heavy).

## Bridge packages

Third-party and first-party integrations ship as separate bridge
packages that register widgets, values, constants, and extensions
into a shared `RuneConfig`. Each package has its own version track
and README.

| Package | Description |
|---------|-------------|
| [`rune_responsive_sizer`](packages/rune_responsive_sizer) | Percent-of-screen extensions: `.w`, `.h`, `.sp`, `.dm`. |
| [`rune_cupertino`](packages/rune_cupertino) | Cupertino widget family (CupertinoApp through CupertinoAlertDialog), CupertinoThemeData, CupertinoIcons constants. |
| [`rune_provider`](packages/rune_provider) | Reactive state from [`package:provider`](https://pub.dev/packages/provider): `ChangeNotifierProvider`, `Consumer`, `Selector`. Notifiers expose `Map`-shaped state via a `RuneReactiveNotifier.state` getter. |
| [`rune_router`](packages/rune_router) | Inline routing via [`package:go_router`](https://pub.dev/packages/go_router): `GoRoute`, `GoRouter`, `GoRouterApp` (wraps `MaterialApp.router`). |

Apply any bridge with `RuneConfig.defaults().withBridges([...])`.
The RuneBridge contract is one method: `void registerInto(RuneConfig config)`.

## License

MIT. See [`LICENSE`](LICENSE).
