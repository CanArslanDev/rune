# Changelog

All notable changes to this project are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.0] — 2026-04-19 — wrappers, slivers, transforms

### Added
- **Wrapper and utility widgets** — seven everyday builders for
  composition, visibility, and masking: `Drawer` (side menu
  content for `Scaffold.drawer`; optional `backgroundColor`,
  `elevation`, `width`), `SafeArea` (system-inset avoidance;
  per-edge toggles + `minimum`/`maintainBottomViewPadding`),
  `Visibility` (conditional render with replacement + optional
  maintainState/Animation/Size), `Opacity` (static non-animated
  complement to `AnimatedOpacity`), `ClipRRect` (rounded-corner
  clip with `borderRadius` + `clipBehavior`), `ClipOval` (circular
  clip), `Tooltip` (message + preferBelow/wait/show durations +
  padding; `richMessage` deferred). `Clip.none/hardEdge/antiAlias/
  antiAliasWithSaveLayer` join the constants table for the two
  clip builders.
- **Slivers and CustomScrollView** — compose advanced scrollable
  layouts that plain `ListView` / `GridView` can't express.
  `CustomScrollView` drives the `slivers` list; sliver primitives
  include `SliverList` (children-based, closure variant deferred),
  `SliverGrid.count` and `SliverGrid.extent` (value-builder named
  ctors), `SliverToBoxAdapter` (wrap any non-sliver widget),
  `SliverAppBar` (collapsing app bar with `pinned`/`floating`/
  `snap` + `expandedHeight` + `flexibleSpace`), `SliverPadding`
  (edge padding around a sliver), `SliverFillRemaining` (fills the
  rest of the viewport). Closure-param sliver variants
  (`SliverList.builder`, `SliverGrid.builder`, etc.) stay deferred
  pending function-literal support in source.
- **Display wrappers and programmatic transforms** — five
  display-layer widget builders and two Transform value ctors.
  `FittedBox` (scale child to fit; `fit: BoxFit`, `alignment`),
  `ColoredBox` (efficient leaf for solid color fills),
  `DecoratedBox` (Container without padding/margin overhead;
  required `decoration`, optional `position`), `Offstage`
  (renders invisible but state preserved), `Semantics`
  (accessibility label/value/hint/button/link/header/image flags).
  `Transform.scale` (uniform via `scale` or axis-specific via
  `scaleX`/`scaleY`) and `Transform.rotate` (required
  `angle` in radians). `DecorationPosition.background` and
  `.foreground` join the constants table for DecoratedBox.
  `Transform.translate` is deferred until the Offset value
  builder lands alongside.

## [0.6.0] — 2026-04-19 — widget breadth (Material, animations, grids)

### Added
- **Material widget breadth** — five more everyday builders.
  `FloatingActionButton` (onPressed event, optional child/tooltip/
  colors/mini), `Chip` (required label, optional avatar, onDeleted
  event, colors/style), `Badge` (wraps a child with an optional
  label overlay; supports backgroundColor/textColor/smallSize/
  largeSize/isLabelVisible), `CircularProgressIndicator` and
  `LinearProgressIndicator` (both indeterminate by default, set
  `value: 0.0-1.0` for determinate).
- **Animation expansions** — four more animated widget builders
  complementing the AnimatedContainer/Opacity/Positioned trio from
  v0.5.0: `Hero` (cross-route shared-element transitions; required
  non-null `tag` + `child`, optional `transitionOnUserGestures`),
  `AnimatedSwitcher` (fade between children when the child's key
  changes; required `duration`, optional `reverseDuration`/
  `switchInCurve`/`switchOutCurve`), `AnimatedCrossFade` (fade
  between two declared children driven by a `CrossFadeState` enum;
  required `firstChild`/`secondChild`/`crossFadeState`/`duration`
  plus optional first/second/size curves and alignment), and
  `AnimatedSize` (animate own size to match child; required
  `duration` + optional curve/alignment/reverseDuration).
  `CrossFadeState.showFirst` / `.showSecond` join the constants
  table. Closure-shaped args (`createRectTween`,
  `flightShuttleBuilder`, etc.) remain out of scope pending
  function-literal support in source.
- **Grid views** — `GridView.count` (fixed column count) and
  `GridView.extent` (max cell extent) join the default value-builder
  registry. Both require their primary sizing arg
  (`crossAxisCount: int` / `maxCrossAxisExtent: num`); optional
  `children`, `mainAxisSpacing`, `crossAxisSpacing`,
  `childAspectRatio`, `scrollDirection` (Axis), `padding`,
  `shrinkWrap`, `reverse`. `GridView.builder` is deferred pending
  function-literal support in source.

## [0.5.0] — 2026-04-19 — animations + navigation + dropdown

### Added
- **Animated widgets and Duration support** — `AnimatedContainer`,
  `AnimatedOpacity`, `AnimatedPositioned`. Each takes a required
  `duration: Duration(...)` and optional `curve` (defaulting to
  `Curves.linear`). When the host rebuilds `RuneView` with new
  values for any tweenable slot (dimensions, colour, opacity,
  position), Flutter animates between old and new automatically.
  `Duration(milliseconds: n)` is a new default value builder; nine
  canonical `Curves.*` instances (`linear`, `easeIn/Out/InOut`,
  `bounceIn/Out`, `elasticIn/Out`, `fastOutSlowIn`) join the
  constants table.
- **Navigation widgets** — `BottomNavigationBar` (required `items`
  + `currentIndex`, optional `onTap` dispatching `(name, [newIndex])`,
  theming via `type/selectedItemColor/unselectedItemColor/
  backgroundColor`), `TabBar` + `Tab` (assume a host-side
  `DefaultTabController` ancestor), plus `BottomNavigationBarItem`
  as a value builder. `BottomNavigationBarType.fixed` /
  `.shifting` join the constants table.
- **Dropdown select** — `DropdownButton` with `DropdownMenuItem`.
  Both parametric on `Object?` so item values can be any runtime
  type. Required `items: List<DropdownMenuItem<Object?>>`; optional
  `value` (absent or explicit null renders the hint),
  `onChanged: String` event name, `hint`, `disabledHint`,
  `isExpanded`. A null `onChanged` disables the dropdown, matching
  the Switch / Checkbox / Slider / Radio pattern.

### Changed
- **Event-callback helpers** extracted. Fourteen call sites across
  ten builders duplicated the same
  `eventName == null ? null : () => ctx.events.dispatch(...)`
  pattern (and the value-carrying variant). Consolidated into two
  shared helpers in `lib/src/builders/event_callback.dart`:
  `voidEventCallback(name, events)` and
  `valueEventCallback<T>(name, events)`. Every existing builder
  test continues to pass unchanged — pure refactor.

## [0.4.0] — 2026-04-19 — interactive + layout polish

### Added
- **Gesture handlers** — `GestureDetector` and `InkWell` widget
  builders, each wrapping a child with `onTap`, `onDoubleTap`, and
  `onLongPress` named-event dispatch. `InkWell` adds Material
  ink-splash feedback plus an optional `borderRadius` arg to shape
  the splash to a rounded container. Any widget now becomes
  tappable in Rune source without having to be a `*Button`.
- **Layout and scroll helpers** — `SingleChildScrollView` (wraps
  overflowing content in a scroll region along a chosen `Axis`),
  `Wrap` (Row-like layout that flows to the next line when out of
  space; supports `direction`/`spacing`/`runSpacing`/`alignment`/
  `runAlignment`/`crossAxisAlignment`), `AspectRatio` (forces a
  child to a fixed width-to-height ratio), and `Positioned` (absolute
  placement inside a `Stack`). `WrapAlignment` and `WrapCrossAlignment`
  enums join the default constants table so source code can reference
  `WrapAlignment.center` and friends.
- **Form input widgets: `Slider` and `Radio`.** Slider dispatches
  the new `double` value on each drag step; required `value` +
  optional `min`/`max`/`divisions`/`label`/`onChanged`. Radio
  dispatches the selected button's own `value` (any runtime type)
  so the host can update `groupValue`; supports `toggleable` for
  tap-to-deselect semantics. Both follow the two-way data-binding
  contract established by TextField/Switch/Checkbox — the host
  owns state, interactions fire named events with the new value
  as the single argument.

### Fixed
- Radio builder's test file used `hide RadioBuilder` to avoid a
  naming collision with a Flutter internal symbol on newer Flutter
  versions, which broke compilation on the Flutter 3.24.0 pinned
  in CI (where that symbol isn't exported). Switched to a
  `show`-import of just the needed names so the test compiles on
  any Flutter >= 3.22.

## [0.3.0] — 2026-04-19 — runtime-value members + layout helpers

### Added
- **Built-in properties on runtime values.** `.length`, `.isEmpty`,
  `.isNotEmpty`, `.first`, `.last`, `.keys`, `.values` on the Dart
  primitives they apply to (String, List, Map). `PropertyResolver`
  consults the new table after the Map-key fast-path and before the
  extension registry, so bridge-registered extensions still win on
  custom names.
- **Whitelisted built-in method invocation on runtime values.**
  `toString()` on anything; `toUpperCase/toLowerCase/trim/contains/
  startsWith/endsWith/split/substring/replaceAll` on strings;
  `contains/indexOf/join` on lists; `containsKey/containsValue` on
  maps; `abs/round/floor/ceil/toInt/toDouble` on num. Any other
  (type, method) pair raises `ResolveException`. Arbitrary method
  invocation stays forbidden — whitelist only, matching the
  store-compliance posture.
- **Three new widget builders** — `ListTile`, `Divider`, `Spacer`.
  `ListTile` covers the common slots (`title`, `subtitle`, `leading`,
  `trailing`) plus `onTap` as a named event and `dense`/`enabled`/
  `selected` flags. `Divider` accepts `height`, `thickness`, `indent`,
  `endIndent`, `color`. `Spacer` accepts `flex` (default 1). With
  these registered, the Quickstart snippet in the README now runs
  verbatim against `RuneConfig.defaults()`.

### Changed
- `PropertyResolver` precedence is now: Map key (if present) →
  built-in property (if the pair is recognised) → extension
  registry. Previously a Map with an absent key returned `null`
  silently; now if the absent key happens to match a built-in
  property name (e.g. `cart.length` on a Map with no `length` key),
  the Map's own size is returned. Callers relying on the old
  null-for-absent behaviour for keys that collide with built-in
  property names should use explicit `[…]` indexing instead.
- `IdentifierResolver.resolvePrefixed` gained the same built-in
  awareness so `items.length` (a `PrefixedIdentifier`) behaves
  identically to `cart.items.length` (a `PropertyAccess`) — both
  consult the built-in table when the data value is a non-Map
  type or when a Map lacks the requested key.
- `InvocationResolver` now dispatches runtime method calls on
  resolved values. When a `MethodInvocation`'s target is a
  `SimpleIdentifier` that doesn't match a registered builder type,
  or any non-identifier target, the resolver resolves the target,
  then looks up `(runtimeType, methodName)` in the whitelist.
  Builder dispatch still wins for `TypeName.ctor(...)` shapes when
  `TypeName` is in the widget or value registry.

## [0.2.0] — 2026-04-19 — diagnostics + richer source language

### Added
- **Binary and prefix expression operators.** Equality (`==`, `!=`),
  comparison (`<`, `<=`, `>`, `>=` on num+num or String+String),
  short-circuit logicals (`&&`, `||`), arithmetic (`+`, `-`, `*`,
  `/`, `%` on num), logical not (`!` on bool), and unary negation
  (`-` on num). Out-of-domain operands surface as `ResolveException`
  with a source-location pointer.
- **Conditional rendering.** Ternary (`cond ? a : b`) as an
  expression arm, and `if`-elements in list literals
  (`[if (cond) widget]`, `[if (cond) a else b]`). Both short-circuit
  the un-taken branch, so data keys that are only present in one
  branch don't need to be defensively populated in the other.
- **Form input widget builders with two-way data binding** —
  `TextField`, `Switch`, `Checkbox`. Each accepts a `value` (from
  the host's `data` map) and an `onChanged` event name; user
  interactions dispatch the new value as a single-element args list
  through `RuneView.onEvent`, leaving the host responsible for
  updating state. `TextField` uses a persistent
  `TextEditingController` under the hood so external value updates
  stay cursor-safe.
- **Source-location diagnostics.** Every `RuneException` now carries
  an optional `SourceSpan location` (new public value class)
  pointing to where the error originates in the Rune source.
  `toString()` renders a caret-pointer block beneath the excerpt
  when a location is set. Populated by parser diagnostics, every
  resolver throw site, and bubbled builder argument failures; `null`
  on defensive invariant checks.
- **`SourceSpan.fromAstOffset(source, astOffset, astLength)`
  factory** — the single source of truth for
  AST-offset-to-source-location conversion, rebasing
  analyzer-wrapper offsets and clamping EOF-shaped diagnostics into
  usable spans.
- **GitHub Actions CI workflow** running `flutter analyze` +
  `flutter test` on push to `main` and on all PRs, across both the
  root and sibling packages.
- **`CONTRIBUTING.md` + GitHub issue/PR templates** establishing
  contributor flow now that the repo is public.

### Changed
- **`RuneContext` gained a required `String source` field** so
  resolvers can compute `SourceSpan`s on demand. Production path
  (`RuneView` → `_buildContext`) threads `widget.source` through;
  the test helper defaults it to an empty string. See "Breaking
  changes" below.
- `Registry.require`, `ConstantRegistry.require`, and
  `ExtensionRegistry.require` each gained an optional
  `SourceSpan? location` named parameter, threaded through to the
  thrown exception. Backwards-compatible — existing callers without
  location keep working.

### Fixed
- Internal code in `lib/src/builders/values/` no longer imports
  `package:rune/rune.dart` — barrel imports are reserved for
  external consumers, matching the unidirectional layering guarded
  by `test/architecture/import_flow_test.dart`.
- Root `flutter analyze` no longer crawls `packages/**` — the
  sibling package owns its own analyze step with its own
  `analysis_options.yaml`. Previously, CI failed on root analyze
  because the sibling's `pub get` hadn't run before root analyze.

### Breaking changes
- **`RuneContext` constructor** now requires a `source` named
  parameter (`String`, non-nullable). External code constructing
  `RuneContext` directly (e.g. custom test harnesses, alternative
  views) must supply the source string that the AST originates
  from, or `''` if the context is used in a path where diagnostics
  aren't needed. Callers going through `RuneView` / `RuneConfig`
  are unaffected — the production path threads `widget.source`
  automatically.

## [0.1.0] — 2026-04-18 — Phase 4

### Added
- `benchmark/parse_resolve_bench.dart` — runnable Dart script that
  measures parse + resolve time on a canonical ~30-node widget tree
  over 500 iterations. Reports cold (cache-miss) and warm (cache-hit)
  stats; soft-checks cold p95 against a 16ms / 60fps budget.
- `RuneDevOverlay` — opt-in `StatelessWidget` wrapper that, on
  long-press in debug/profile builds, opens a bottom sheet with the
  source string and a descendant count. Pass-through in release
  builds. Exported from `package:rune/rune.dart`.

### Changed
- `RuneView` now overrides `State.reassemble()` to clear its per-
  instance `AstCache`. Hot-reload picks up source edits in the host
  app immediately; previously the cached parsed AST would continue
  to serve.

### Released
- First minor release. API stable enough for early adopters. Future
  0.x minors focus on widget / value / extension additions without
  breaking existing consumers.

## [0.0.10] — 2026-04-18 — Phase 3c

### Added
- Sibling package `rune_responsive_sizer` at `packages/rune_responsive_sizer/`
  — a `RuneBridge` implementation that registers four responsive-sizing
  property extensions: `.w` (percent of screen width), `.h` (percent of
  screen height), `.sp` (text-scaled pixels), `.dm` (percent of
  `min(width, height)`). Applied via
  `RuneConfig.defaults().withBridges([const ResponsiveSizerBridge()])`.
  Independent version track; ships at `0.0.1` alongside this root bump.

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

[Unreleased]: https://github.com/CanArslanDev/rune/compare/v0.7.0...HEAD
[0.7.0]: https://github.com/CanArslanDev/rune/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/CanArslanDev/rune/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/CanArslanDev/rune/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/CanArslanDev/rune/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/CanArslanDev/rune/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/CanArslanDev/rune/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/CanArslanDev/rune/compare/v0.0.10-phase3c...v0.1.0
[0.0.10]: https://github.com/CanArslanDev/rune/compare/v0.0.9-phase3b...v0.0.10-phase3c
[0.0.9]: https://github.com/CanArslanDev/rune/compare/v0.0.8-phase3a...v0.0.9-phase3b
[0.0.8]: https://github.com/CanArslanDev/rune/compare/v0.0.7-polish...v0.0.8-phase3a
[0.0.7]: https://github.com/CanArslanDev/rune/compare/v0.0.6-phase2e...v0.0.7-polish
[0.0.6]: https://github.com/CanArslanDev/rune/compare/v0.0.5-phase2d...v0.0.6-phase2e
[0.0.5]: https://github.com/CanArslanDev/rune/compare/v0.0.4-phase2c...v0.0.5-phase2d
[0.0.4]: https://github.com/CanArslanDev/rune/compare/v0.0.3-phase2b...v0.0.4-phase2c
[0.0.3]: https://github.com/CanArslanDev/rune/compare/v0.0.2-phase2a...v0.0.3-phase2b
[0.0.2]: https://github.com/CanArslanDev/rune/compare/v0.0.1-phase1...v0.0.2-phase2a
[0.0.1]: https://github.com/CanArslanDev/rune/releases/tag/v0.0.1-phase1
