# Rune

> Turn Dart widget-construction source strings into live Flutter widgets at runtime.

[![Flutter](https://img.shields.io/badge/flutter-%E2%89%A5%203.22-blue)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%E2%89%A5%203.4-blue)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

Rune parses a string of Dart widget syntax (e.g. `Column(children: [Text('Hello')])`), walks the resulting AST via the official [`analyzer`](https://pub.dev/packages/analyzer) package, and constructs real Flutter widgets through pre-registered builders.

No `dart:mirrors`. No `eval`. No runtime code execution. The widgets that come out are ordinary Flutter widgets — they compose, animate, and perform like hand-written code.

## Why

Deliver UI from a server, a CMS, or a designer tool without shipping a new app binary. The `source` you pass to a `RuneView` can be edited, A/B-tested, or user-authored. Because Rune only interprets a constrained subset of Dart expression syntax — never executing arbitrary code — it's compatible with Apple App Store and Google Play store-review policies.

## Features

- **Runtime interpretation, not compilation.** `analyzer` produces the AST; Rune walks it.
- **Store-compliant.** No `dart:mirrors`, no eval, no on-device code generation.
- **Layered and open/closed.** Adding a new widget is one builder file, one registration, one test — no core change.
- **Strict typing.** Dart 3 sealed exceptions, pattern matching, `final class`, `@immutable`. `dynamic` is banned outside the parser boundary.
- **Single runtime dependency** besides Flutter: `analyzer`. All other integrations (responsive scaling, state management, routing, ...) live in separate bridge packages.
- **Rich data binding.** Free identifiers (`userName`), deep dot-path (`user.profile.name`), list/map indexing (`items[0].title`), and data-driven widget lists (`for (final item in items) ...`) — all resolved against a `Map<String, Object?>` you supply.
- **String interpolation.** `'Hello, $name!'` and `'Count: ${n}'` substitute data-context values into literal strings.
- **Named events.** `ElevatedButton(onPressed: "submit")` routes taps through `RuneView.onEvent(name, args)` to the host app.
- **Extensible.** A `RuneBridge` package registers widget/value/constant/extension handlers with one `registerInto(config)` call. `10.w`, `size.half`, and similar receiver-style property access go through `PropertyResolver` → `ExtensionRegistry`.
- **Typed error surface.** Every failure raises a `RuneException` subtype carrying the offending source substring plus a human-readable message. `RuneView.fallback` + `onError` make failures non-fatal.
- **`very_good_analysis`-strict.** The whole package passes the strict lint floor with zero ignores beyond two documented exceptions.

## Install

```yaml
dependencies:
  rune: ^0.5.0
```

The package is pre-publication; use a `git:` or `path:` dependency until a tagged `pub.dev` release lands. `dart pub publish --dry-run` currently reports 0 errors / 0 warnings.

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

Current release: **`v0.5.0`** — animated widgets (`AnimatedContainer`/`AnimatedOpacity`/`AnimatedPositioned`), navigation (`BottomNavigationBar`/`TabBar`/`Tab`), dropdown select (`DropdownButton`/`DropdownMenuItem`), plus a shared event-callback helper deduplicating ten existing builders.

| Category              | Elements                                                                                                                                                                                                     |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Widgets               | `Text`, `SizedBox`, `Container`, `Column`, `Row`, `Padding`, `Center`, `Stack`, `Expanded`, `Flexible`, `Card`, `Icon`, `ListView`, `AppBar`, `Scaffold`, `ElevatedButton`, `TextButton`, `IconButton`, `TextField`, `Switch`, `Checkbox`, `ListTile`, `Divider`, `Spacer`, `GestureDetector`, `InkWell`, `SingleChildScrollView`, `Wrap`, `AspectRatio`, `Positioned`, `Slider`, `Radio`, `AnimatedContainer`, `AnimatedOpacity`, `AnimatedPositioned`, `BottomNavigationBar`, `TabBar`, `Tab`, `DropdownButton`, `DropdownMenuItem` |
| Value ctors           | `EdgeInsets.all/symmetric/only/fromLTRB/zero`, `Color(hex)`, `TextStyle(...)`, `BorderRadius.circular(n)`, `BoxDecoration(...)`, `Image.network(url)`, `Image.asset(path)`, `Duration(...)`, `BottomNavigationBarItem(...)`                 |
| Constants             | `Colors.*`, `MainAxisAlignment.*`, `CrossAxisAlignment.*`, `MainAxisSize.*`, `TextAlign.*`, `TextOverflow.*`, `Alignment.*`, `BoxFit.*`, `StackFit.*`, `Axis.*`, `FontWeight.*`, `BoxShape.*`, `FlexFit.*`, `BottomNavigationBarType.*`, `Curves.linear/easeIn/easeOut/easeInOut/bounce*/elastic*/fastOutSlowIn`, ~60 common `Icons.*` |
| Literals              | int, double, bool, null, string, list `[...]`, set/map `{...}`, adjacent string concat                                                                                                                       |
| Interpolation         | `'Hello $name'`, `'Count: ${n}'` — expressions resolve against data + constants                                                                                                                              |
| Identifiers           | Bare `name` → `data['name']`; `Type.member` → data `Map` traversal OR constants registry                                                                                                                     |
| Deep data paths       | `user.profile.name`, `items[0].title` — any depth of nested maps + list/map indexing                                                                                                                         |
| Collections           | `[for (final item in items) Text(item.title)]` — data-driven widget lists, nested for-elements, static + for elements interleaved                                                                            |
| Built-in properties   | `.length`, `.isEmpty`, `.isNotEmpty`, `.first`, `.last` on lists; `.length`, `.isEmpty`, `.isNotEmpty` on strings; `.length`, `.isEmpty`, `.isNotEmpty`, `.keys`, `.values` on maps                                 |
| Built-in methods      | `toString()` (any); `toUpperCase/toLowerCase/trim/contains/startsWith/endsWith/split/substring/replaceAll` on strings; `contains/indexOf/join` on lists; `containsKey/containsValue` on maps; `abs/round/floor/ceil/toInt/toDouble` on num  |
| Events                | `ElevatedButton(onPressed: 'submit', ...)` → `RuneView.onEvent('submit', [])`                                                                                                                                |
| Property extensions   | `10.w`, `size.half` — via `RuneBridge` packages registering handlers                                                                                                                                         |
| Operators             | `==` `!=` `<` `<=` `>` `>=` on num+num or String+String; `&&` `\|\|` (short-circuit); `+` `-` `*` `/` `%` on num; `!` on bool; unary `-` on num                                                              |
| Conditionals          | Ternary `cond ? a : b`; list-literal `[if (cond) widget]` / `[if (cond) a else b]` — both short-circuit the un-taken branch                                                                                  |

Anything outside this surface raises a `RuneException` (parse, resolve, or unregistered-builder variant). The plans in `docs/superpowers/plans/` enumerate the phases that built this set.

## Architecture

A unidirectional pipeline:

```
RuneView (StatefulWidget)
  │
  ▼
RuneConfig
  ├─ WidgetRegistry        — Phase 1-2d widget builders
  ├─ ValueRegistry         — Phase 1-2c value ctors
  ├─ ConstantRegistry      — Colors, enums, Icons
  └─ ExtensionRegistry     — Phase 3a .w/.px/.half handlers
  (+ withBridges([...])    — RuneBridge-packaged third-party contributions)
  │
  ▼
RuneContext  (carries data, events, all four registries, optional Flutter BuildContext)
  │
  ▼
DartParser ─────────▶ AstCache (LRU)
  │
  ▼
ExpressionResolver (dispatcher on Expression AST subtype)
  ├─ LiteralResolver       — literals + adjacent-string concat
  ├─ IdentifierResolver    — SimpleIdentifier / PrefixedIdentifier (data-first, constants fallback)
  ├─ PropertyResolver      — PropertyAccess (Map-first for deep paths, extensions for scalars)
  ├─ InvocationResolver    — MethodInvocation / InstanceCreationExpression
  └─ (inline)              — ListLiteral + ForElement, SetOrMapLiteral, IndexExpression, StringInterpolation
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

Source strings can then use `SizedBox(width: (50).pct * MediaQuery.of(...))` — or, more realistically, a bridge that uses `ctx.flutterContext` to do proper responsive math.

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

A live working bridge ships at [`packages/rune_responsive_sizer`](packages/rune_responsive_sizer) — a ~70-line implementation that adds `.w` / `.h` / `.sp` / `.dm` responsive-sizing extensions. Use it as both a consumer (pair it with `rune` via path dep) and a reference for writing your own bridges.

## Error handling

- `RuneException` is a `sealed class` with five variants:
  - `ParseException` — `analyzer` could not produce an AST.
  - `ResolveException` — a resolver encountered an unsupported shape or missing extension.
  - `UnregisteredBuilderException` — a type name has no matching builder (exposes `typeName`).
  - `ArgumentException` — a required builder argument was missing or of the wrong type.
  - `BindingException` — an identifier referenced a key that is not present in `RuneDataContext`.
- Every exception carries the offending `source` substring plus a human-readable `message`.
- `RuneView` catches all exceptions, calls the optional `onError` callback, then renders `fallback`. In debug builds with no `fallback`, Flutter's red-screen `ErrorWidget` is shown; in release builds the view silently collapses to an empty `SizedBox`.
- `RuneEventDispatcher.dispatch` is crash-safe: handler throws (including arity mismatches) are caught and `debugPrint`-logged; they never escape into the render pipeline.

### Source-location diagnostics

Every `RuneException` carries an optional `location` field — a `SourceSpan` pointing into the `RuneView.source` where the error originates. When present, `toString()` renders a caret pointer beneath the one-line summary:

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

Three hundred and seventy-two tests cover every resolver, every builder, every registry, the architecture invariants, and end-to-end `RuneView` renders for each phase. Main is kept green at all times; every commit passes both gates under `very_good_analysis`.

## Example

See [`example/`](example/) for a runnable demo that exercises the full current feature set.

## License

MIT — see [`LICENSE`](LICENSE).
