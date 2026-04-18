# Changelog

All notable changes to this project are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.9] — 2026-04-18 — Phase 3b

### Added
- Deep dot-path data access — `user.profile.name` and arbitrary-depth
  traversal now work through `PropertyResolver`'s new map-first
  branch. Each `PropertyAccess` segment walks one map level; missing
  keys return `null`.
- Index access — `items[0]`, `map['key']`, `items[0].title` via a new
  `IndexExpression` dispatch arm. List out-of-range throws
  `ResolveException`; non-list/map targets throw with a type-mismatch
  message.
- `for`-element in list literals — `[for (final item in items)
  Text(item.title)]`. Loop variable binds into a scoped
  `RuneDataContext` via `extend`, so `item.title` resolves against
  the merged data. Static elements around the for-element are
  preserved in source order; nested for-elements compose. Only
  `for`-each with declaration is supported (C-style `for` and
  `IfElement` throw `ResolveException`).

### Changed
- `PropertyResolver.resolve` — when the target is a
  `Map<String, Object?>`, the map value wins over any same-named
  extension. Data beats extensions on conflict (matches the
  data-first rule established by `IdentifierResolver.resolvePrefixed`
  in Phase 3a).

## [0.0.8] — 2026-04-18 — Phase 3a

### Added
- `ExtensionRegistry` — property-name-keyed registry of
  `(target, ctx) => Object?` handlers. Used by the new
  `PropertyResolver` to evaluate receiver-style property access like
  `10.px`, `(5).doubled`.
- `RuneBridge` — single-method contract (`void registerInto(RuneConfig)`)
  that third-party packages implement to bundle widget/value/constant/
  extension contributions. Applied via `RuneConfig.withBridges([...])`.
- `PropertyResolver` — dispatcher arm for `PropertyAccess` AST nodes;
  resolves target via the expression resolver then delegates to
  `ctx.extensions`.
- `RuneContext.extensions` field (required); `RuneConfig.extensions`
  field + `withBridges(List<RuneBridge>)` fluent method.
- Architecture-test rule gating the new `src/bridges/` layer.

### Changed
- `IdentifierResolver.resolvePrefixed` now checks `ctx.data` before
  `ctx.constants`. `user.name` (where `user` is a `Map` in data)
  resolves to `data['user']['name']`; `Colors.red` still falls through
  to the constants registry. Non-`Map` data values at the prefix raise
  `ResolveException` with a type-mismatch message.

## [0.0.7] — 2026-04-18

### Changed
- Linter floor raised from `flutter_lints ^4.0.0` to
  `very_good_analysis ^5.1.0`. All source and tests pass the stricter
  rule set.

### Added
- `CHANGELOG.md` (this file) documenting every phase since `0.0.1-phase1`.
- `pubspec.yaml` metadata: `homepage`, `topics` for richer `pub.dev`
  presentation.

## [0.0.6] — 2026-04-18 — Phase 2e

### Added
- `RuneDefaults` abstract-final helper class with four static entry
  points: `registerAll`, `registerWidgets`, `registerValues`,
  `registerConstants`. Enables cherry-picking defaults into custom
  `RuneConfig`s.
- Architecture test (`test/architecture/import_flow_test.dart`) that
  walks `lib/src/**/*.dart` and guards the unidirectional layer import
  hierarchy (binding is self-contained, parser only reads core,
  nothing imports `dynamic_view.dart`, etc.).

### Changed
- `RuneConfig.defaults()` now delegates to `RuneDefaults.registerAll`
  (public behavior unchanged; twenty-plus builder imports moved out of
  `config.dart`).
- `pubspec.yaml` version bumped to `0.0.6`.

## [0.0.5] — 2026-04-18 — Phase 2d

### Added
- Three button widget builders: `ElevatedButton`, `TextButton`,
  `IconButton`. Each translates a `String` `onPressed` source argument
  into a `VoidCallback` that invokes `ctx.events.dispatch(eventName)`.
- `RuneEventDispatcher.setCatchAllHandler`: catch-all bridge invoked
  on every dispatch in addition to any named handler.
- `RuneView._buildContext` now installs `widget.onEvent` as the
  dispatcher's catch-all when non-null, closing the gap that left
  source-declared events unobservable.

## [0.0.4] — 2026-04-18 — Phase 2c

### Added
- Ten widget builders: `Padding`, `Center`, `Stack`, `Expanded`,
  `Flexible`, `Card`, `Icon`, `ListView`, `AppBar`, `Scaffold`.
- Two `Image` value builders (`Image.network`, `Image.asset`) —
  registered via `ValueRegistry` so they can coexist under the shared
  `typeName == 'Image'` and disambiguate on constructor name.
- `FlexFit` enum seeded into the Phase 2a constants module.
- Phase 2c icons seed (`phase_2c_icons.dart`): ~60 common `Icons.*`
  constants.

## [0.0.3] — 2026-04-18 — Phase 2b

### Added
- Seven value builders: `EdgeInsets.symmetric`, `EdgeInsets.only`,
  `EdgeInsets.fromLTRB`, `Color(hex)`, `TextStyle`,
  `BorderRadius.circular`, `BoxDecoration`.
- `BoxShape` enum seeded into constants registry.

### Fixed
- `ContainerBuilder` was silently dropping the `decoration` named
  argument — discovered via Phase 2b integration tests and fixed as
  part of the same phase.

## [0.0.2] — 2026-04-18 — Phase 2a

### Added
- `ConstantRegistry` — two-level `typeName.memberName` keyed store
  (independent of the generic `Registry<T>` base because the
  two-level shape lets error messages cite both halves).
- `IdentifierResolver` — handles `SimpleIdentifier` (data lookup in
  `RuneDataContext`) and `PrefixedIdentifier` (constants lookup).
- `ExpressionResolver` dispatcher extensions for `SetOrMapLiteral`,
  `StringInterpolation`, and `AdjacentStrings`.
- Phase 2a constants seed: all of `Colors.*`, `MainAxisAlignment`,
  `CrossAxisAlignment`, `MainAxisSize`, `TextAlign`, `TextOverflow`,
  `Alignment` singletons, `BoxFit`, `StackFit`, `Axis`, `FontWeight`,
  `EdgeInsets.zero`.
- `RuneContext` grew a required `constants` field.
- `RuneConfig.defaults()` now seeds the Phase 2a constants.

### Changed
- `RuneDataContext` and `RuneEventDispatcher` renamed from their
  unprefixed forms (`DataContext` / `EventDispatcher`) to avoid a
  collision with `flutter_test`'s own `EventDispatcher` and align with
  the `Rune*` public-surface convention.
- `RuneEventDispatcher.dispatch` now catches handler exceptions and
  logs via `debugPrint`, so arity mismatches or handler throws do not
  escape into the render pipeline.

## [0.0.1] — 2026-04-18 — Phase 1 MVP

### Added
- Core: `sealed class RuneException` with five variants
  (`ParseException`, `ResolveException`, `UnregisteredBuilderException`,
  `ArgumentException`, `BindingException`).
- Registry: generic `Registry<T>`, `WidgetRegistry`, `ValueRegistry`.
- Parser: `DartParser` (wraps `analyzer.parseString` with the
  `dynamic __rune__ = $source;` trick to parse bare expressions) and
  LRU `AstCache`.
- Builder contracts: `RuneBuilder`, `RuneWidgetBuilder`,
  `RuneValueBuilder`; `ResolvedArguments` with type-safe accessors.
- Resolver: `LiteralResolver`, `ExpressionResolver` (pattern-match
  dispatcher with late-bound invocation resolver), `InvocationResolver`
  handling both `MethodInvocation` (bare call syntax, the primary
  user-facing shape) and `InstanceCreationExpression` (with `new`).
- Five widget builders: `Text`, `SizedBox`, `Container`, `Column`,
  `Row`.
- One value builder: `EdgeInsets.all`.
- `RuneConfig.defaults()` factory wiring Phase 1 builders.
- `RuneView` public `StatefulWidget` — parses, caches (LRU), resolves,
  renders; `onError` callback + `fallback` widget for failures.
- Example app at `example/lib/main.dart` demonstrating the full Phase 1
  feature set.

[Unreleased]: https://github.com/CanArslanDev/rune/compare/v0.0.9...HEAD
[0.0.9]: https://github.com/CanArslanDev/rune/compare/v0.0.8-phase3a...v0.0.9-phase3b
[0.0.8]: https://github.com/CanArslanDev/rune/compare/v0.0.7-polish...v0.0.8-phase3a
[0.0.7]: https://github.com/CanArslanDev/rune/compare/v0.0.6-phase2e...v0.0.7-polish
[0.0.6]: https://github.com/CanArslanDev/rune/compare/v0.0.5-phase2d...v0.0.6-phase2e
[0.0.5]: https://github.com/CanArslanDev/rune/compare/v0.0.4-phase2c...v0.0.5-phase2d
[0.0.4]: https://github.com/CanArslanDev/rune/compare/v0.0.3-phase2b...v0.0.4-phase2c
[0.0.3]: https://github.com/CanArslanDev/rune/compare/v0.0.2-phase2a...v0.0.3-phase2b
[0.0.2]: https://github.com/CanArslanDev/rune/compare/v0.0.1-phase1...v0.0.2-phase2a
[0.0.1]: https://github.com/CanArslanDev/rune/releases/tag/v0.0.1-phase1
