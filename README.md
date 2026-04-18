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
- **Data binding.** Free identifiers in the source (`userName`, `itemCount`) resolve against a `Map<String, Object?>` you supply.
- **String interpolation.** `'Hello, $name!'` and `'Count: ${n}'` substitute data-context values into literal strings.
- **Typed error surface.** Every failure raises a `RuneException` subtype carrying both the offending source substring and a human-readable message.

## Install

```yaml
dependencies:
  rune: ^0.0.2
```

The package is pre-publication; use a `git:` or `path:` dependency until a tagged `pub.dev` release lands.

## Quickstart

```dart
import 'package:flutter/material.dart';
import 'package:rune/rune.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Rune Demo')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: RuneView(
            source: r"""
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hello, $userName!'),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    child: Text('You have ${itemCount} items in your cart.'),
                  ),
                ],
              )
            """,
            config: RuneConfig.defaults(),
            data: const {'userName': 'Ali', 'itemCount': 7},
            fallback: const Text('Failed to render.'),
            onError: (error, stack) => debugPrint('Rune error: $error'),
          ),
        ),
      ),
    ),
  );
}
```

A runnable version lives in [`example/`](example/).

## Supported source syntax

Current release (Phase 2a) supports:

| Category      | Elements                                                                                                                                                    |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Widgets       | `Text`, `SizedBox`, `Container`, `Column`, `Row`                                                                                                            |
| Values        | `EdgeInsets.all(n)`, `EdgeInsets.zero`                                                                                                                      |
| Constants     | `Colors.*`, `MainAxisAlignment.*`, `CrossAxisAlignment.*`, `MainAxisSize.*`, `TextAlign.*`, `TextOverflow.*`, `Alignment.*`, `BoxFit.*`, `StackFit.*`, `Axis.*`, `FontWeight.*` |
| Literals      | int, double, bool, null, string, list `[...]`, set/map `{...}`, adjacent string concat                                                                      |
| Interpolation | `'Hello $name'`, `'Count: ${n}'` — expressions resolve against `data` and the constants registry                                                            |
| Identifiers   | Bare `name` → `data['name']`; `TypeName.member` → constants registry                                                                                        |

Anything outside this surface raises a `RuneException` (parse, resolve, or unregistered-builder variant). The roadmap in `docs/superpowers/plans/` enumerates the phases that expand this set.

## Architecture

A unidirectional pipeline:

```
RuneView (StatefulWidget)
  │
  ▼
RuneConfig
  ├─ WidgetRegistry
  ├─ ValueRegistry
  └─ ConstantRegistry
  │
  ▼
RuneContext  (carries data, events, registries, optional Flutter BuildContext)
  │
  ▼
DartParser ─────────▶ AstCache (LRU)
  │
  ▼
ExpressionResolver (dispatcher)
  ├─ LiteralResolver      — literals
  ├─ IdentifierResolver   — data + constants
  └─ InvocationResolver   — MethodInvocation / InstanceCreationExpression
                              │
                              ▼
                        Registered builder (widget or value)
                              │
                              ▼
                        Real Flutter Widget
```

Every resolver returns already-resolved Dart values. Builders receive `ResolvedArguments` (type-safe positional + named accessors) and produce exactly one widget or value.

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

## Error handling

- `RuneException` is a `sealed class` with five variants:
  - `ParseException` — `analyzer` could not produce an AST.
  - `ResolveException` — a resolver encountered an unsupported shape.
  - `UnregisteredBuilderException` — a type name has no matching builder (exposes `typeName`).
  - `ArgumentException` — a required builder argument was missing or of the wrong type.
  - `BindingException` — an identifier referenced a key that is not present in `RuneDataContext`.
- Every exception carries the offending `source` substring plus a human-readable `message`.
- `RuneView` catches all exceptions, calls the optional `onError` callback, then renders `fallback`. In debug builds with no `fallback`, Flutter's red-screen `ErrorWidget` is shown; in release builds the view silently collapses to an empty `SizedBox`.

## Testing

```bash
flutter test
flutter analyze
```

The repo's test suite covers every resolver, every builder, every registry, and end-to-end `RuneView` renders. Main is kept green at all times; every commit passes both gates.

## Roadmap

- [x] **Phase 1** — parse → resolve → build pipeline with five MVP widgets and `EdgeInsets.all`. Tagged `v0.0.1-phase1`.
- [x] **Phase 2a** — named constants, data binding, string interpolation, compound literals. Tagged `v0.0.2-phase2a`.
- [ ] **Phase 2b** — remaining value builders (`EdgeInsets.symmetric/only/fromLTRB`, `TextStyle`, `Color(hex)`, `BorderRadius`, `BoxDecoration`).
- [ ] **Phase 2c** — remaining widget builders (`Padding`, `Stack`, `Card`, `Image`, buttons, `Scaffold`, `ListView`, `AppBar`, ...).
- [ ] **Phase 2d** — button events wired through `RuneView.onEvent`.
- [ ] **Phase 2e** — `RuneDefaults` helper, architecture test, `pub.dev` publish.
- [ ] **Phase 3** — `PropertyResolver` + `ExtensionRegistry`, `RuneBridge` contract, dot-path data access.
- [ ] **Phase 4** — performance benchmarks, dev overlay, hot-reload cache invalidation, `0.1.0` release.

## Example

See [`example/`](example/) for a runnable demo that exercises the full Phase 2a feature set.

## License

MIT — see [`LICENSE`](LICENSE).
