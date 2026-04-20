# Changelog

All notable changes to this project are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **`rune_devtools_extension` sibling package (v0.1.0).** Phase 2
  of the DevTools plan. Ships a Flutter-web DevTools extension
  under `packages/rune_devtools_extension/` that registers a
  **rune** tab inside Flutter DevTools. Calls the
  `ext.rune.inspect` endpoint registered by v1.18.0 and renders
  one expandable card per live `RuneView` surfacing source,
  data context, cache size, and last error. 7 unit tests on the
  wire-format parser. CI workflow extended with a sixth
  `analyze + test` block covering the new package.
- Root README gains a row for `rune_devtools_extension` in the
  Bridge-packages table.
- **Pre-built Flutter web bundle under `extension/devtools/build/`
  committed to the repo.** Makes the extension usable the moment
  a consumer app adds `rune_devtools_extension` as a
  `dev_dependency` (no manual `flutter build web` step on their
  end). Flutter DevTools loads the compiled bundle directly from
  a local scheme. Bundle size ~37 MB uncompressed / ~12 MB
  compressed at publish time; CanvasKit is bundled locally because
  the DevTools local-scheme origin cannot fetch the public CDN.

### Removed

- **GitHub Pages dartdoc hosting.** The `.github/workflows/docs.yaml`
  workflow, root README API-docs badge + hosted-docs reference,
  and every package's `documentation:` pubspec field pointing at
  `https://canarslandev.github.io/rune/` are all gone. pub.dev
  already renders `dart doc` output on every published release,
  so the hand-rolled Pages deployment was redundant. Consumers
  follow the pub.dev-provided API-docs link from each package's
  landing page instead.

## [1.18.0] - 2026-04-20 - DevTools inspection (Phase 1)

### Added

- **`RuneInspector` singleton** in `lib/src/binding/rune_inspector.dart`
  that tracks live `RuneView` instances for DevTools introspection.
  Every `_RuneViewState.initState` calls
  `RuneInspector.instance.registerView(snapshotBuilder)` and stores
  the returned handle; `dispose` unregisters. Snapshot builders are
  invoked on demand so DevTools always sees the freshest state.
- **`ext.rune.inspect` VM service extension.** The inspector lazily
  registers this endpoint via `dart:developer.registerExtension` on
  the first view mount. DevTools (or any VM-service client) calls
  it and receives:

  ```json
  {
    "views": [
      {
        "id": 0,
        "source": "Text('hi')",
        "data": {"count": 7},
        "cacheSize": 1,
        "lastError": null
      }
    ]
  }
  ```

  One entry per live view; numeric `id`s match the
  `RuneInspectorHandle.id` the host received. Release builds
  short-circuit to a no-op because `dart:developer.registerExtension`
  is compiled out.

- **Robust JSON coercion.** Snapshot values pass through
  `_serialiseForWire` which recursively maps `Map` / `Iterable`
  branches and coerces non-JSON-native leaves (`RegExp`,
  `DateTime`, arbitrary objects) to their `toString()` form so the
  wire payload always round-trips through `jsonEncode`.

- **Error isolation.** A misbehaving snapshot builder that throws
  is caught and its error is surfaced on the affected view's entry
  as `snapshotError: "<exception>.toString()"`; other views in the
  same payload stay intact.

- **Barrel exports** `RuneInspector`, `RuneInspectorHandle`, and
  `RuneInspectionSnapshotBuilder` from
  `package:rune/rune.dart` so a companion DevTools extension
  package can drive the registry without reaching into `src/`.

### Notes

- Phase 1 of the `rune_devtools_extension` work per
  `docs/superpowers/plans/2026-04-20-rune-v1.16-devtools-extension-plan.md`.
  Phase 2 ships the sibling package scaffold; Phase 3 ships the
  Flutter web UI that consumes this payload.
- `_RuneViewState` gained two fields (`_inspectorHandle`,
  `_lastError`) and two lifecycle hooks (inspector registration in
  `initState`, deregistration in `dispose`; `lastError` captured
  in the render `catch` block). The runtime render path pays a
  single Map allocation per inspection call; zero cost per render.
- 13 new tests: 8 unit tests on `RuneInspector` covering
  register/unregister, duplicate-unregister tolerance, snapshot
  freshness, error isolation, JSON round-tripping, non-native-leaf
  coercion; plus 5 integration smokes wiring through a real
  `RuneView` (mount registers, unmount deregisters, two mounted
  views produce two distinct entries, `lastError` surfaces after
  a render throws, payload JSON-encodes end-to-end). Total
  main-package tests: 1751 (up from 1738).

### Changed

- Benchmark harness (`benchmark/parse_resolve_bench.dart`) gains a
  second workload. Alongside the historical 30-node canonical tree,
  a "rich" source now exercises v1.x features (`for` / `if`
  elements, string interpolation, deep dot-paths, runtime
  properties and methods, ternary expressions). Both workloads
  print COLD (cache-miss) and WARM (cache-hit) stats plus the
  multiplier of headroom against the 16ms 60fps budget.
- README gains a **Performance** section with the v1.17.1 numbers
  captured on an Apple-Silicon dev machine (COLD p95 around
  410us-450us; WARM p95 around 50us-121us; ~36x-39x headroom).

## [1.17.1] - 2026-04-20 - source formatter polish

### Changed

- **`formatRuneSource` handles map literals properly.** Previously
  the formatter fell through to analyzer's own `toSource()` for
  `SetOrMapLiteral` nodes, which emits `'a' : 1` with a space
  before the colon. A dedicated `_writeSetOrMapLiteral` helper now
  renders map entries as `'a': 1` (idiomatic style) and applies
  the same fits-vs-break logic the list-literal path already uses:
  short maps stay single-line, long maps break onto one entry per
  line with trailing commas.
- Empty `{}` still renders as `{}` (Dart's default-Set
  interpretation is preserved because the formatter does not
  synthesise a type annotation).

### Added

- 11 new formatter tests covering map literal short + long forms,
  set literals, list with if-elements, list with for-elements,
  string-interpolation preservation, ternary, arrow closure
  preservation, empty argument lists, and deeply-nested-call
  progressive indentation. Total formatter tests: 23 (up from 12).
- Total main-package tests: 1738 (up from 1728).

## [1.17.0] - 2026-04-20 - user-registered runtime members

### Added

- **`MemberRegistry` on `RuneConfig`.** Hosts and sibling bridges
  can now register property accessors and method invokers for
  arbitrary Dart types without taking a `dart:mirrors` dependency
  or forking the main package. Typical shape:

  ```dart
  final config = RuneConfig.defaults();
  config.members
    ..registerProperty<CounterNotifier>('count', (t, _) => t.count)
    ..registerMethod<CounterNotifier>('increment', (t, args, _) {
      t.increment();
      return null;
    });
  ```

  After this, Rune source can write `counter.count` and
  `counter.increment()` directly against a live
  `CounterNotifier` in the data context.

- **Registry integration across three resolver arms.**
  - `PropertyResolver` consults the registry after the built-in
    property whitelist misses, before the Map-absent-key fallback.
  - `IdentifierResolver.resolvePrefixed` consults the registry for
    `data.member` shapes where the data value is a non-Map holder
    (e.g. a bare `CounterNotifier` in data).
  - `InvocationResolver._dispatchRuntimeMethod` consults the
    registry for `receiver.method(...)` calls when the receiver is
    NOT a recognized built-in target type, falling back to the
    built-in method whitelist otherwise.

- **Type-matching semantics.** `registerProperty<T>(...)` and
  `registerMethod<T>(...)` use `is T` at resolve time, so a
  subtype of `T` also matches. Registration order is the tiebreaker
  when multiple entries could fire: first-match-wins.

- **Built-in safety.** For stock Dart types (String, List, Map,
  num, ThemeData, ColorScheme, TextTheme, MediaQueryData, controller
  types, Animation, Animatable, AsyncSnapshot, BoxConstraints,
  Size, EdgeInsets, Route, RouteSettings) the built-in whitelist
  always wins. A host cannot accidentally shadow
  `String.toUpperCase` or `List.contains`. Custom classes never
  collide because they fall outside the built-in guard.

- **Barrel exports** `MemberRegistry`, `MemberPropertyAccessor`,
  and `MemberMethodInvoker` from `package:rune/rune.dart`.

### Notes

- Unblocks cleaner bridge patterns: `rune_provider` v0.2.0
  (planned) drops the `RuneReactiveNotifier.state` `Map`-projection
  indirection once it migrates to registering direct property
  accessors.
- `RuneContext.members` is nullable so pre-v1.17 callers that
  construct a `RuneContext` directly keep working; when null the
  three resolver arms skip the custom-member lookup entirely.
- 15 new tests: 11 unit tests on `MemberRegistry` (round-trip,
  subtype matching, first-match-wins, no-match fallback, method
  invocation, ChangeNotifier end-to-end) plus 4 `RuneView`
  integration smokes (property on custom ChangeNotifier, method
  call with / without args, built-in-wins-on-stock-types).
  Total main-package tests: 1728 (up from 1713).

## [1.16.0] - 2026-04-20 - pluggable imperative registry

### Added

- **`ImperativeRegistry` on `RuneConfig`.** Hosts and sibling bridges
  can now register source-level imperatives without a main-package
  update:
  - `config.imperatives.registerBare(name, handler)` wires up
    bare-shape calls (`showToast('hi')`, `logEvent(name: 'tap')`).
  - `config.imperatives.registerPrefixed(target, method, handler)`
    wires up prefixed-shape calls (`Router.go('/path')`,
    `Analytics.track('sign-up')`). Target + method pair is the key.
  - Handler signature is `Object? Function(ResolvedArguments,
    RuneContext)`, mirroring widget/value builders so existing
    helpers (`voidEventCallback`, closure adapters) compose
    naturally.
- **Registry-first dispatch in `InvocationResolver`.** The resolver
  consults the registry before falling back to the hardcoded v1.3+
  built-ins (`showDialog`, `showModalBottomSheet`, `Navigator.*`,
  etc.). Hosts that want to shadow a built-in can do so by
  registering a same-named handler. Built-ins stay active for any
  name not registered on the instance.
- **Barrel exports** `ImperativeRegistry` and `ImperativeHandler`
  from `package:rune/rune.dart`.

### Notes

- Unblocks `rune_router` v0.2.0 (planned): `Router.go('/path')` and
  friends can finally live in source. The v1.14.0 deferred-scope
  note pointing at "pluggable imperative registry in the main
  `rune` package" is now addressed.
- `RuneContext.imperatives` is nullable so pre-v1.16 callers that
  construct a `RuneContext` directly (pure unit tests, older
  bridges) continue to work unchanged; when null the resolver
  falls back to the built-in bridges exclusively.
- 12 new tests: 8 unit tests on `ImperativeRegistry` (round-trip,
  duplicate detection, collisions) plus 4 `RuneView` integration
  smokes (bare call, prefixed call, registered-shadows-built-in,
  `Navigator.*` still-wins-when-no-override). Total main-package
  tests: 1713 (up from 1701).

## [1.15.0] - 2026-04-20 - docs + example polish

### Added

- **Example app rewritten as a 4-tab showcase.**
  `example/lib/main.dart` grows from 2 to 4 `RuneView`s:
  - **Cart** and **Profile** tabs from v0.2.0+ remain unchanged.
  - **Reactive** tab drives a `ChangeNotifier` counter through
    `rune_provider`'s `ChangeNotifierProvider`, `Consumer`, and
    `Selector`. Demonstrates `RuneReactiveNotifier.state`
    projection, rebuild suppression via `Selector`, and host-side
    event dispatch through `onEvent`.
  - **Responsive** tab uses `rune_responsive_sizer`'s `.w` / `.h`
    / `.sp` extensions to build a viewport-relative layout.
  - Each tab owns its own `RuneConfig`: default for Cart and
    Profile, `withBridges([ProviderBridge()])` for Reactive,
    `withBridges([ResponsiveSizerBridge()])` for Responsive.
- **Root README grows a Cookbook section** with copyable recipes
  covering: two-way binding, `if`-element conditional rendering,
  ternary event selection, reactive counters via `rune_provider`,
  percent-of-screen sizing via `rune_responsive_sizer`, and inline
  routing via `rune_router`.
- **Root README grows a Writing a bridge guide** that walks
  through scaffolding a new `RuneBridge` package from scratch
  (pubspec, barrel, bridge class, widget / value / constant /
  extension registration) with live references to the four
  existing bridges ordered by complexity.

### Changed

- Root README "Testing" section updated to reflect the current
  test matrix (1701 root + 146 sibling tests). `example/README.md`
  rewritten to document the 4-tab layout; `example/pubspec.yaml`
  now path-depends on `rune_provider` and `rune_responsive_sizer`
  so the demo runs out of the box from a clean `pub get`.

### Notes

- Main `rune` package (1.14.0 to 1.15.0) is a pure ecosystem /
  docs bump. No widget / value / constant / resolver changes at
  the main-package layer. Root test count unchanged at 1701.

## [1.14.0] - 2026-04-20 - routing bridge (rune_router)

### Added

- **rune_router sibling bridge package (v0.1.0).** Third
  third-party-style bridge. Registers a narrow surface of
  [`package:go_router`](https://pub.dev/packages/go_router) on a
  `RuneConfig` through `RouterBridge`:
  - `GoRoute(path, builder, name?, routes?)` value builder. The
    `builder` closure is `(BuildContext, GoRouterState) -> Widget`.
  - `GoRouter(routes, initialLocation?, debugLogDiagnostics?)` value
    builder. Filters non-GoRoute entries from `routes:` so
    conditional `[if (...)]` list constructs compose cleanly.
  - `GoRouterApp(router, title?, theme?, debugShowCheckedModeBanner?)`
    widget. Wraps `MaterialApp.router(routerConfig:)` so Rune source
    can install the router at the app root.

### Notes

- Main `rune` package (1.13.0 to 1.14.0) is a pure ecosystem bump.
  No widget / value / constant / resolver changes at the main-package
  layer. Main test count unchanged.
- Source-level imperatives (`context.go('/path')`,
  `context.push('/path')`) stay deferred. They need a pluggable
  imperative registry in the main `rune` package. Host apps
  navigate by holding a reference to the router instance and
  calling `.go(...)` / `.push(...)` from `onEvent` callbacks.
- rune_router ships at `0.1.0`, matching the cadence of
  `rune_cupertino` and `rune_provider`. 20 tests pass; analyzer
  clean under `very_good_analysis ^5.1.0`.

## [1.13.0] - 2026-04-20 - reactive state bridge (rune_provider)

### Added

- **rune_provider sibling bridge package (v0.1.0).** Second
  third-party-style bridge; registers a curated trio of `package:provider`
  widgets on a `RuneConfig` through `ProviderBridge`:
  `ChangeNotifierProvider`, `Consumer`, and `Selector`. Each widget
  works with a `ChangeNotifier` scoped to a single provider; source
  interacts with the notifier's state through a `Map`-shaped
  `RuneReactiveNotifier.state` getter so dot-access (`state.count`)
  resolves correctly through Rune's existing property resolver.
- **`RuneReactiveNotifier` interface** in the new package. Implement
  alongside `ChangeNotifier` and override `Map<String, Object?> get
  state` to expose typed fields to Rune source without touching
  Rune's built-in member whitelist.

### Notes

- Main `rune` package (1.12.0 to 1.13.0) is a pure ecosystem bump
  to match the release cadence. No widget / value / constant /
  resolver additions on the main package in this release. Feature
  substance lives entirely in `packages/rune_provider/`.
- rune_provider ships at its own version track (`0.1.0`), mirroring
  `rune_cupertino`. `rune_provider` tests: 19 passing. Package
  analyzes clean under `very_good_analysis ^5.1.0`.
- `rune_router` stays deferred; the next bridge to ship.

## [1.12.0] - 2026-04-20 - v1.x deferred cleanups

### Added

- **ListenableBuilder widget.** Rebuilds on any `Listenable` change via
  a `builder(context) => Widget` closure. Pair with `ValueNotifier`,
  `ChangeNotifier`, `AnimationController`, or any composite listenable
  to scope rebuilds narrowly.
- **PageRouteBuilder value builder.** Accepts `pageBuilder`,
  `transitionsBuilder`, and the usual `Duration` / barrier
  slots. Two new closure adapters (`toPageRouteBuilderPageBuilder`,
  `toPageRouteBuilderTransitionsBuilder`) bridge the 3- and 4-arity
  Flutter signatures into `RuneClosure`s. Works with the existing
  `Navigator.push` imperative bridge.
- **Navigator.popUntil.** Imperative bridge pops routes until a
  user-supplied predicate returns `true`. The predicate receives a
  `Route` and can reach `route.settings.name`, `route.isFirst`,
  `route.isCurrent`, `route.isActive` through the runtime's property
  whitelist. Closure adapter `toRoutePopPredicate` wraps the
  `RuneClosure` into `RoutePredicate`.
- **showMenu imperative.** Same shape as `showDialog` /
  `showModalBottomSheet`: takes a `BuildContext`, `RelativeRect`
  position, and a list of `PopupMenuEntry`s, returns the selected
  value through a future.
- **RelativeRect.fromLTRB value builder.** Positional-constructor
  wrapper used for positioning popup menus.
- **CheckedPopupMenuItem widget.** Selectable popup entry with
  leading checkmark. Complements the existing `PopupMenuItem` and
  `PopupMenuDivider` pair.
- **BottomSheet widget.** Inline bottom-sheet host (as opposed to
  the `showModalBottomSheet` imperative), wiring `onClosing`,
  `backgroundColor`, `elevation`, `shape`, `clipBehavior`, and
  `enableDrag` into Flutter's `BottomSheet`.
- **FilledButton.tonal value builder.** The Material 3 "tonal" filled
  button variant. Same slot set as `FilledButton`.
- **SnackBarAction + SnackBar.action slot.** `SnackBarAction` is a
  new value builder (label + `onPressed` event name) and the
  `SnackBar` value builder now accepts an `action:` slot. Required
  once actionable snackbars were promoted from examples to first-class.
- **PaginatedDataTable + RuneDataTableSource.** Covers the paged
  variant of `DataTable` end-to-end: the value builder adapts a
  `Map<String, Object?>` backing store into `DataTableSource` rows
  through an event-name callback.
- **AnimationController.drive, Tween.animate, Tween.chain.** Three
  dispatch arms added to the runtime method whitelist so Rune source
  can compose Animatables inline without escaping into the host app.
- **Route / RouteSettings property whitelist.** `Route.isFirst`,
  `Route.isActive`, `Route.isCurrent`, `Route.settings`,
  `RouteSettings.name`, `RouteSettings.arguments` are now readable
  from Rune source, unlocking predicates like
  `(route) => route.settings.name == '/home'` inside `popUntil`.

### Notes

- **PopupMenuDivider.thickness / indent / endIndent / color stay
  deferred.** The CI-pinned Flutter 3.24.0 `PopupMenuDivider`
  constructor exposes only `key` and `height`; those extras were
  added in later Flutter framework releases. They unlock
  automatically when the CI Flutter floor moves.
- Main-package test count climbs from 1619 to 1701 (+82 tests).
  rune_responsive_sizer stays at 7 tests, rune_cupertino stays at
  117 tests. All three analyzers clean under `very_good_analysis
  ^5.1.0`.

## [1.11.0] - 2026-04-19 - bridge ecosystem kickoff

### Added

- **rune_cupertino sibling bridge package (v0.1.0).** First
  third-party-style bridge delivered as a separate package:
  `packages/rune_cupertino/`. One class, `CupertinoBridge`,
  implements `RuneBridge.registerInto(config)` and wires the
  Cupertino widget family, a `CupertinoThemeData` value builder,
  and 30 `CupertinoIcons.*` constants into a RuneConfig with
  `config.withBridges([const CupertinoBridge()])`.
- **Ten Cupertino widget builders.** `CupertinoApp`,
  `CupertinoPageScaffold`, `CupertinoNavigationBar`,
  `CupertinoButton`, `CupertinoSwitch`, `CupertinoSlider`,
  `CupertinoTextField` (with the same stateful-controller pattern
  as the Material TextField), `CupertinoActivityIndicator`,
  `CupertinoAlertDialog`, `CupertinoDialogAction`. Registered
  through the bridge contract so consumers opt in explicitly.
- **Event-callback helpers on the public barrel.**
  `voidEventCallback` and `valueEventCallback<T>` are now exported
  from `package:rune/rune.dart`. Bridge packages previously could
  not wire event-carrying widgets without reaching into
  `package:rune/src/...` paths; exporting these helpers aligns the
  bridge pattern with the "no src/ imports from external code"
  convention.

### Notes

- Main `rune` package (1.10.0 to 1.11.0) is a pure ecosystem bump:
  no widget / value / constant additions and no resolver changes
  beyond the barrel export. The feature substance of the release
  lives in the new sibling package.
- `packages/rune_cupertino/` ships at its own version track
  starting at `0.1.0`. 72 tests across the bridge registration,
  per-widget argument forwarding, event dispatch, disabled-state
  paths, value builder, constants seed, and six end-to-end
  integration smokes that mount a `RuneView` inside a
  `CupertinoApp`.
- `rune_provider` (Provider / Riverpod integration) and
  `rune_router` (go_router / auto_route integration) stay
  deferred. Either they ship as patch releases to v1.11.x, or
  they land in a future v1.x release; the decision waits for
  real adoption feedback on pub.dev to drive the ordering.

### Deferred from the plan

- The v1.x roadmap anticipated three bridges shipping together in
  v1.11.0. The actual delivery focused on `rune_cupertino` because
  the Cupertino widget set is a self-contained, high-value
  package that demonstrates the bridge pattern end-to-end without
  bringing along additional third-party dependencies.
- `CupertinoPicker`, `CupertinoActionSheet`, `CupertinoSegmentedControl`,
  and `CupertinoContextMenu` stay deferred inside rune_cupertino
  itself; each has complex shape (closure-heavy builders, generic
  typing, imperative dispatch) that fits a follow-up patch to
  rune_cupertino rather than the first release.

## v1.x series close

v1.11.0 closes the post-v1.0.0 v1.x roadmap:

| Release | Theme |
|---------|-------|
| v1.0.0 | Stability milestone |
| v1.1.0 | Lifecycle + controllers |
| v1.2.0 | Closure-based builder widgets |
| v1.3.0 | Dialogs + overlays + imperative bridges |
| v1.4.0 | Theme + Material 3 polish |
| v1.5.0 | Forms + validation |
| v1.6.0 | Navigation + routing |
| v1.7.0 | Gestures + advanced interaction |
| v1.8.0 | Data tables + expansion + stepper |
| v1.9.0 | Explicit animations |
| v1.10.0 | Developer experience |
| v1.11.0 | Bridge ecosystem kickoff (rune_cupertino) |

Public-API stability pact from v1.0.0 held across all twelve
releases. Zero breaking changes. Main package passes 1619 root
tests plus architecture invariants plus 7 sibling tests.
rune_cupertino adds another 72 tests.

## [1.10.0] - 2026-04-19 - developer experience

### Added

- **"Did you mean" diagnostic suggestions.** All three main
  exception types gained factory constructors that compute a
  Levenshtein-distance suggestion from a candidate pool.
  `UnregisteredBuilderException.withSuggestion` reads widget,
  value, and component registry names; `ResolveException.withSuggestion`
  receives the current target type's methods / properties;
  `BindingException.withSuggestion` reads data keys plus scope
  names. When a close enough match exists (Levenshtein distance
  within a reasonable bound) the exception message appends
  `(did you mean "X"?)`. Source-level typos like `Colums(...)` or
  `.toUppercase()` now get clear diagnostics.
- **Widened source pointer.** `SourceSpan.toContextualPointer(
  fullSource, contextLines: N)` renders the carat-pointer with N
  lines of context above and below the offending line. The
  default `toPointerString` stays unchanged (single-line excerpt
  for backwards compatibility); consumers who want more context
  call the new method in their `onError` handler with
  `ctx.source` (or `RuneView.source`) as the full-source argument.
- **Source formatter.** `formatRuneSource(String source,
  {int maxLineLength = 80})` returns a canonically-formatted
  version of the input: 2-space indent per level, per-argument
  breaks inside multi-line calls, trailing commas on multi-line
  lists / arg lists, single-line collapse when the whole
  expression fits. Unparseable input returns unchanged with a
  diagnostic comment header. Useful as a programmable formatter
  for Rune sources in tooling pipelines.
- **Registry introspection.** `Registry<T>.names`,
  `ValueRegistry.typeNames`, `ComponentRegistry.typeNames`,
  `ConstantRegistry.memberNamesOf(typeName)`,
  `ExtensionRegistry.names`, `RuneDataContext.keys`, and
  `RuneScope.names` expose the registered / bound names so
  consumers (and the suggestion factories above) can enumerate
  candidates without leaking the backing maps.

### Notes

- `formatRuneSource` is exported from the public barrel
  `lib/rune.dart`.
- Levenshtein helper lives in `lib/src/core/levenshtein.dart` as
  a pure core utility (no Flutter or analyzer deps). Threshold
  tuning (max distance, minimum candidate length) is internal;
  future releases can expose the knobs if needed.
- About 46 new tests: 13 Levenshtein unit tests, 6
  `toContextualPointer` tests, 4 exception-factory tests, 13
  formatter tests, 10 resolver diagnostic-suggestion integration
  tests.
- The v1.0.0 stability commitment holds. Zero breaking changes;
  existing diagnostic messages keep their exact prefix and gain
  the suggestion suffix only when a close match exists.

### Deferred

- DevTools extension ships as a separate package
  (`packages/rune_devtools_extension/`) in a future release. Hot
  source reload, AST inspector, and state bag inspector belong
  there rather than in the main package.
- VSCode syntax highlighting extension ships as a separate repo.
- LSP autocomplete remains out of scope.

## [1.9.0] - 2026-04-19 - explicit animations

### Added

- **AnimationController.** Source declares an AnimationController
  inside a `StatefulBuilder`'s `initial` map. The value builder
  returns an `AnimationControllerSpec` (a pure data descriptor);
  `StatefulBuilder`'s private host state now mixes in
  `TickerProviderStateMixin` and swaps each spec in-place for a
  real `AnimationController(vsync: this, ...)` before any source
  code touches the state. The host tracks owned controllers and
  disposes them in its `dispose`, skipping them in the
  `autoDisposeListenables` sweep to avoid double-disposal. Source
  calls `.forward()`, `.reverse()`, `.stop()`, `.reset()`, and
  `.repeat()` via the builtin-method whitelist; property access
  covers `.value`, `.status`, `.isAnimating`, `.isCompleted`,
  `.isDismissed`.
- **Tween value builders.** `Tween(begin, end)` (generic over any
  runtime value), `ColorTween(begin?, end?)`, and
  `CurvedAnimation(parent, curve, reverseCurve?)`.
- **Transition widget builders.** `FadeTransition(opacity, child)`,
  `SlideTransition(position, child)`, `ScaleTransition(scale,
  child, alignment?)`, `RotationTransition(turns, child,
  alignment?)`, `SizeTransition(sizeFactor, child, axis?,
  axisAlignment?)`. Each takes a Flutter Animation value (typically
  from a tween driven by an AnimationController).
- **AnimatedBuilder.** `AnimatedBuilder(animation, builder:
  (BuildContext, Widget?) -> Widget, child?)`. The builder closure
  receives an optional child that Flutter rebuilds only when the
  animation ticks, matching the vanilla AnimatedBuilder contract.
- **AnimationStatus constants.** `dismissed`, `forward`, `reverse`,
  `completed` join the constants table.
- **Animation<double> property access and AnimationController
  methods.** Read `.value`, `.status`, `.isAnimating`,
  `.isCompleted`, `.isDismissed` on any Animation<double>. Call
  `.forward()`, `.reverse()`, `.stop()`, `.reset()`, `.repeat()`,
  `.dispose()` on AnimationControllers.

### Notes

- Widget count 109 to 115. Value builder count 50 to 54. Constants
  gain AnimationStatus.
- About 77 new tests across the six transition widgets, the five
  value builders (AnimationController, Tween, ColorTween,
  CurvedAnimation, AnimatedBuilder), the AnimationControllerSpec
  materialization path in StatefulBuilder, the builtin-method
  whitelist extensions, and a five-scenario integration smoke
  (rotating icon with repeat, fading text via forward, sliding
  panel with tween + curve, animated builder closure, AnimationStatus
  reach).
- `ListenableBuilder` stays deferred (AnimatedBuilder accepts any
  `Listenable` via its `animation` parameter, covering the common
  case; ListenableBuilder is a thin alias and can ship as a
  one-file follow-up).
- `PageRouteBuilder` + `Navigator.popUntil` (predicate closure)
  remain deferred from v1.6.0; their closure signatures mirror
  the now-supported `AnimatedBuilder` and could land in a future
  patch.
- `.drive(Animatable)` on AnimationController stays out of scope;
  source users construct the Animation via CurvedAnimation +
  tween.animate(...) if needed, but `.animate` itself is not yet
  whitelisted. Future patch candidate.
- The v1.0.0 stability commitment holds. Zero breaking changes.
  Existing StatefulBuilder source continues to work unchanged
  (spec materialization only touches entries that happen to be
  `AnimationControllerSpec`).

## [1.8.0] - 2026-04-19 - data tables and structured display

### Added

- **DataTable.** `DataTable(columns: List<DataColumn>, rows:
  List<DataRow>, sortColumnIndex?, sortAscending?, columnSpacing?,
  headingRowHeight?, dataRowMinHeight?, dataRowMaxHeight?,
  showBottomBorder?, dividerThickness?)`. Column sorting is driven
  by a closure on `DataColumn.onSort: (columnIndex, ascending) ->
  void`.
- **DataColumn, DataRow, DataCell value builders.**
  `DataColumn(label, numeric?, tooltip?, onSort?)`,
  `DataRow(cells, selected?, onSelectChanged?, color?)`,
  `DataCell(child, onTap?, showEditIcon?, placeholder?)`. Compose
  into typed lists passed into DataTable.
- **ExpansionTile.** `ExpansionTile(title, children?, subtitle?,
  leading?, trailing?, initiallyExpanded?, onExpansionChanged?,
  backgroundColor?, collapsedBackgroundColor?, iconColor?,
  textColor?, tilePadding?, childrenPadding?)`.
  `onExpansionChanged` is a `(bool) -> void` closure routed through
  the existing `valueEventCallback<bool>`.
- **ExpansionPanelList + ExpansionPanel.** `ExpansionPanelList(
  children: List<ExpansionPanel>, expansionCallback:
  (int, bool) -> void, animationDuration?, expandedHeaderPadding?)`
  composes a list of `ExpansionPanel(headerBuilder:
  (BuildContext, bool) -> Widget, body: Widget, isExpanded?,
  canTapOnHeader?)` value entries.
- **Stepper family.** `Stepper(steps: List<Step>, currentStep,
  type?, onStepTapped?, onStepContinue?, onStepCancel?)` plus a
  `Step(title, content, subtitle?, isActive?, state?)` value
  builder. Default controls render automatically; custom
  `controlsBuilder` stays deferred (Flutter's `ControlsDetails`
  shape is not a clean value-builder candidate).
- **Closure helpers.** `toIntBoolCallback` (`(int, bool) -> void`
  for `DataColumn.onSort` and `ExpansionPanelList.expansionCallback`),
  `toIntValueChanged` (`(int) -> void` for `Stepper.onStepTapped`),
  `toExpansionPanelHeaderBuilder` (`(BuildContext, bool) -> Widget`
  for `ExpansionPanel.headerBuilder`) join
  `lib/src/builders/closure_builder_helpers.dart`.
- **Stepper constants.** `StepperType.vertical/.horizontal` and
  `StepState.indexed/.editing/.complete/.disabled/.error` join the
  constants table.

### Notes

- Widget count 105 to 109. Value builder count 45 to 50. Constants
  gain StepperType and StepState.
- About 60 new tests across the four widget builders, the five
  value builders, the closure helper extensions, and three
  integration smokes: DataTable with columns and rows,
  ExpansionTile expand-on-tap, Stepper advance on Continue.
- `PaginatedDataTable` stays deferred; its `DataTableSource`
  contract wants lifecycle-aware mutable state that fits better
  alongside a future data-binding bridge (not v1.x scope).
- The v1.0.0 stability commitment holds. Zero breaking changes.

## [1.7.0] - 2026-04-19 - gestures and advanced interaction

### Added

- **Drag-and-drop.** `Draggable<Object>` and
  `LongPressDraggable<Object>` widget builders take `data`,
  `feedback`, `child`, optional `childWhenDragging`, and closure
  callbacks for `onDragStarted` / `onDragEnd`. `DragTarget<Object>`
  renders its builder with `(BuildContext, List<Object?>,
  List<Object?>)` and accepts `onAcceptWithDetails` /
  `onWillAcceptWithDetails` as String event names or closures.
- **Dismissible.** `Dismissible(key, child, onDismissed, direction?,
  background?)`. `onDismissed` closure receives `DismissDirection`.
  Requires a `ValueKey` (see below).
- **InteractiveViewer.** `InteractiveViewer(child, minScale?,
  maxScale?, panEnabled?, scaleEnabled?, boundaryMargin?)` for
  pan-and-zoom content.
- **ReorderableListView.** `ReorderableListView(children, onReorder:
  (oldIndex, newIndex) -> void, padding?, scrollDirection?)`.
  Children must carry stable keys; the new `ValueKey` value builder
  (and a new `key:` slot on `ListTile`) cover the common case.
- **ValueKey value builder.** `ValueKey(value)` wraps any runtime
  value into a stable widget key. The `ListTile` builder now
  accepts an optional `key` so it can serve as a keyed child of
  ReorderableListView.
- **Closure helpers.** `toDragTargetBuilder` (3-arg),
  `toDismissibleCallback`, `toReorderCallback`,
  `toDragEndCallback`, `toDragAcceptCallback`,
  `toDragWillAcceptCallback` join
  `lib/src/builders/closure_builder_helpers.dart`. Every
  closure-wrapping contract for gesture widgets lives in the same
  place per the shared-helper-first discipline.
- **DismissDirection constants.** `endToStart`, `startToEnd`, `up`,
  `down`, `horizontal`, `vertical`, `none` join the constants
  table.

### Notes

- Widget count 100 to 105 (ListTile keeps its typeName; the six
  new gesture widgets bring the total up 5). Value builder count
  44 to 45 (ValueKey). Constants gain DismissDirection.
- About 45 new tests across the six gesture widgets, the ValueKey
  value builder, the closure helper extensions, and four
  integration smokes (Draggable + DragTarget drop, Dismissible
  swipe, ReorderableListView reorder, InteractiveViewer pan).
- The v1.0.0 stability commitment holds. Zero breaking changes.
  `ListTile.key` is purely additive; existing ListTile source that
  did not supply a key continues to render identically.

## [1.6.0] - 2026-04-19 - navigation and routing

### Added

- **Navigator imperative bridges.** `Navigator.push(route)`,
  `Navigator.pushReplacement(route)`,
  `Navigator.pushNamed(name, arguments?)`, and `Navigator.canPop()`
  join the v1.3.0 `Navigator.pop` bridge. All route through
  `RuneContext.flutterContext`; `canPop` returns a bool, the push
  variants discard their `Future<T?>` return. Dispatched through a
  new `_navigatorBridges` whitelist map in `InvocationResolver`
  that replaces the previous hard-coded `pop`-only special case.
- **Route value builders.**
  `MaterialPageRoute(builder, settings?, fullscreenDialog?,
  maintainState?)`, `CupertinoPageRoute(builder, title?, settings?,
  fullscreenDialog?, maintainState?)`, and
  `RouteSettings(name?, arguments?)`. Builder closures follow the
  v1.3.0 `toContextWidgetBuilder` contract.

### Notes

- Value builder count 41 to 44. Widget count unchanged. Constants
  unchanged.
- About 30 new tests across the three route value builders, the
  four Navigator bridges, and two integration smokes: push + pop
  round-trip through MaterialPageRoute, pushNamed flow via
  MaterialApp.routes.
- `PageRouteBuilder` stays deferred. Its closure-based
  `pageBuilder` / `transitionsBuilder` args take
  `Animation<double>` parameters; property access on
  `Animation<double>` (`.value`, `.status`) lands in v1.9.0's
  explicit-animation release together with the
  `AnimationController` story.
- `Navigator.popUntil(predicate)` deferred for the same reason.
  Predicate closures take a `Route` argument; extending the
  closure-helper surface for non-BuildContext arguments fits
  naturally alongside the v1.9.0 animation closures.
- The v1.0.0 stability commitment holds. Zero breaking changes.

## [1.5.0] - 2026-04-19 - forms, validation, focus

### Added

- **Form widget.** `Form(child, onChanged?, autovalidateMode?)`.
  `onChanged` fires whenever any child FormField changes (VoidCallback
  via `voidEventCallback`). `autovalidateMode` accepts the new
  `AutovalidateMode` enum constants. `canPop` / `onPopInvoked`
  are deferred to v1.6.0's navigation work.
- **TextFormField.** A text input with validation. Required / typical
  args: `value` (initial text), `controller` (external TextEditingController),
  `validator` (a 1-arg closure `(String?) -> String?` returning a
  validation message or null), `onSaved` (1-arg closure
  `(String?) -> void`), `onFieldSubmitted` (String event name or
  1-arg closure), `onChanged` (same), plus all visual args TextField
  already had (hintText, labelText, obscureText, maxLines, etc.).
  `autovalidateMode` per field.
- **Focus and FocusScope widget builders.**
  `Focus(child, autofocus?, focusNode?, canRequestFocus?,
  onFocusChange?)` wraps a subtree in a focus node (external node
  supplied via the v1.1.0 `FocusNode` value builder).
  `FocusScope(child, autofocus?, canRequestFocus?, onFocusChange?)`
  creates a scoped focus tree node.
- **`TextField.focusNode`.** `TextField` now accepts an optional
  `focusNode: FocusNode` plumbed through the `_RuneTextField`
  internal wrapper, closing a v1.1.0 integrity gap where the
  `FocusNode` value builder existed but no widget consumed it.
- **Closure helpers.** `toValidator` (`(String?) -> String?`) and
  `toStringValueChanged` (`(String?) -> void`) join
  `lib/src/builders/closure_builder_helpers.dart`. Both reuse the
  existing arity / type validation shared with the v1.2.0 and
  v1.4.0 helpers.
- **AutovalidateMode constants.** `always`, `onUnfocus`,
  `onUserInteraction`, `disabled` join the constants table.

### Notes

- Widget count 96 to 100. Value builder count unchanged. Constants
  gain AutovalidateMode.
- About 40 new tests across the four widget builders, the closure
  helpers, and three integration smokes: Form + TextFormField
  validator surfacing the error on user interaction, Focus +
  FocusNode transferring focus across a button press, FocusScope
  with autofocus granting focus to an autofocus child.
- `onFieldSubmitted` uses `valueEventCallback<String>` (Flutter's
  ValueChanged<String> is non-nullable) while `onSaved` uses the new
  `toStringValueChanged` (Flutter's FormFieldSetter<String> is
  void Function(String?)). The split keeps each callback's real
  nullability faithful.
- A CI-portability fix on the Form-validator integration smoke
  swapped `AutovalidateMode.always` (which behaves differently
  between Flutter 3.24 and newer versions on initial render) for
  `AutovalidateMode.onUserInteraction`, then drove the test via
  two sequential `enterText` calls (short invalid, then valid).
  The original intent (Form + TextFormField + validator round-trip)
  is preserved; only the triggering pattern changed.

## [1.4.0] - 2026-04-19 - theme access, M3 widgets, date/time pickers

### Added

- **Context accessors.** `Theme.of(context)` and
  `MediaQuery.of(context)` resolve as well-known `MethodInvocation`
  shapes at the resolver level. Both return the raw Flutter value
  (`ThemeData`, `MediaQueryData`), whose property access routes
  through the built-in property whitelist. Source can now read the
  active theme's colors, text styles, and device metrics without
  leaving the string.
- **Read-only property whitelist for Flutter data types.**
  `ThemeData.colorScheme`, `.textTheme`, `.brightness`,
  `.primaryColor`, `.useMaterial3`, `.scaffoldBackgroundColor`,
  `.cardColor`, `.dividerColor`. `ColorScheme.primary`,
  `.onPrimary`, `.secondary`, `.onSecondary`, `.tertiary`, `.error`,
  `.onError`, `.surface`, `.onSurface`,
  `.surfaceContainerHighest`, `.outline`, `.shadow`, `.brightness`,
  plus tonal inverse / variant slots. `TextTheme.bodyLarge` through
  `bodySmall`, `titleLarge/Medium/Small`, `headlineLarge/Medium/Small`,
  `labelLarge/Medium/Small`. `MediaQueryData.size`, `.orientation`,
  `.padding`, `.viewInsets`, `.viewPadding`, `.devicePixelRatio`,
  `.textScaler`, `.platformBrightness`. `Size.width`, `.height`,
  `.shortestSide`, `.longestSide`, `.aspectRatio`, `.isEmpty`.
  `EdgeInsets.left`, `.top`, `.right`, `.bottom`, `.horizontal`,
  `.vertical`.
- **Material 3 widget builders.** `FilledButton`, `OutlinedButton`,
  `SegmentedButton` (generic on `Object?` values with
  `multiSelectionEnabled` and `onSelectionChanged` closure),
  `SearchBar`, and `SearchAnchor.bar` (a closure-driven
  `suggestionsBuilder`).
- **Theme-related value builders.** `ColorScheme.fromSeed(seedColor,
  brightness?)`, `ThemeData(colorScheme, useMaterial3, brightness,
  scaffoldBackgroundColor, cardColor, dividerColor)`,
  `ButtonSegment(value, label, icon, tooltip, enabled)`.
- **Date / time value builders.** `DateTime(year, month?, day?,
  hour?, minute?, second?, millisecond?, microsecond?)` positional
  constructor and `TimeOfDay(hour: int, minute: int)` named
  constructor. Source can build the bounds for the picker bridges
  without host pre-computation.
- **Date / time imperative bridges.** `showDatePicker(context?,
  initialDate, firstDate, lastDate, helpText?, cancelText?,
  confirmText?)` and `showTimePicker(context?, initialTime,
  helpText?, cancelText?, confirmText?)`. Both resolve through
  `RuneContext.flutterContext`; the returned `Future` is
  discarded in source and available to the host via custom event
  handlers.
- **Constants.** `ThemeMode.light/.dark/.system`, `Brightness.light/
  .dark`, `MaterialTapTargetSize.padded/.shrinkWrap`.

### Notes

- Widget count 91 to 96; value count 35 to 41. Constants table
  gains ThemeMode, Brightness, MaterialTapTargetSize.
- About 68 new tests across the context-accessors resolver path,
  the new widgets and value builders, the imperative bridges, and
  integration smokes driving theme-aware containers, FilledButton
  + OutlinedButton rendering, SegmentedButton multi-select
  toggling, and a date-picker launch.
- `FilledButton.tonal` stays deferred; v1.0.0's stability pact
  holds, existing `.tonal` consumers use `FilledButton` plus a
  custom style in host code.
- A mid-cycle dartdoc-reference fix narrowed two CI-blocking
  `comment_references` findings on `date_time_builder.dart` by
  rewriting the constructor-signature dartdoc to avoid bracketed
  optional-param syntax (the CI-pinned analyzer flags `[name]`
  even inside backtick-quoted code spans).

## [1.3.0] - 2026-04-19 - dialogs, overlays, imperative bridges

### Added

- **Dialog family.** `AlertDialog`, `SimpleDialog`,
  `SimpleDialogOption`, `Dialog` widget builders cover the standard
  Material dialog shapes. `AlertDialog` accepts title / content /
  actions / icon plus full theming. `SimpleDialogOption` takes
  `onPressed` as a String event name or closure.
- **Popup menus.** `PopupMenuButton`, `PopupMenuItem`,
  `PopupMenuDivider`. `PopupMenuButton.itemBuilder` is a
  `(BuildContext) -> List<PopupMenuEntry>` closure; `onSelected`
  receives the tapped item's value through the callback dispatch
  contract. `PopupMenuDivider` exposes `height` for now; newer
  Flutter-only params (thickness, indent, color) are deferred
  until the pinned-CI Flutter catches up.
- **SnackBar value builder.** `SnackBar(content, action?,
  duration?, backgroundColor?, behavior?)` constructs the
  SnackBar that the `showSnackBar` imperative bridge consumes.
  `SnackBarBehavior.fixed` / `.floating` join the constants table.
- **Imperative bridges.** `showDialog(builder, barrierDismissible?)`,
  `showModalBottomSheet(builder, isScrollControlled?,
  backgroundColor?)`, `showSnackBar(snackBar)`, and
  `Navigator.pop(result?)` are recognised at the resolver level
  as bare-identifier invocations that route through
  `RuneContext.flutterContext`. Each helper raises a clear
  ResolveException when the context is null (source invoked
  outside a live RuneView render).
- **Closure helpers.** `toContextWidgetBuilder` and
  `toPopupMenuItemBuilder` join `lib/src/builders/closure_builder_helpers.dart`
  alongside the v1.2.0 builder-callback adapters.

### Notes

- Widget count 84 to 91; value count 34 to 35. Constants table
  gains SnackBarBehavior.
- About 57 new tests across the seven widget builders, the SnackBar
  value builder, the four imperative bridges, and five integration
  smokes (showDialog with AlertDialog, PopupMenuButton selection,
  showSnackBar notification, showModalBottomSheet, Navigator.pop
  from inside a dialog).
- `BottomSheet` widget and `showMenu` imperative bridge are
  deferred: `BottomSheet` requires `onClosing` and is better
  expressed through `showModalBottomSheet`, and `showMenu` needs
  custom `RelativeRect` positioning outside v1.3.0 scope.
  `SnackBarAction` value builder deferred; `action: null` is
  fine for this release.

### Fixed

- `PopupMenuDivider` narrowed to the `height` parameter only.
  The Flutter version pinned to CI (3.24) rejects the
  `thickness` / `indent` / `endIndent` / `color` named params.
  Local dev Flutter accepted them, so `e652789` originally
  landed with a version-mismatch analyzer error; `7d764c1`
  trimmed the surface so both Flutter versions compile cleanly.

## [1.2.0] - 2026-04-19 - closure-based builder widgets

### Added

- **Lazy list and grid builders.** `ListView.builder(itemCount,
  itemBuilder)`, `GridView.countBuilder(crossAxisCount,
  itemBuilder, itemCount?)` plus a matching
  `GridView.extentBuilder(maxCrossAxisExtent, ...)`. Each takes a
  `(BuildContext, int) -> Widget` closure. Source can now render
  thousands of items without eagerly materialising them. Sliver
  counterparts (`SliverList.builder`, `SliverGrid.countBuilder`,
  `SliverGrid.extentBuilder`) compose into `CustomScrollView`
  directly.
- **Async builders.** `FutureBuilder(future, builder)` and
  `StreamBuilder(stream, builder, initialData?)`. Host supplies the
  `Future` / `Stream` through `RuneView.data`; the builder receives
  `(BuildContext, AsyncSnapshot)` and returns a Widget.
  `AsyncSnapshot.hasData`, `.data`, `.hasError`, `.error`,
  `.connectionState` work through the property-access whitelist.
  `ConnectionState.none` / `.waiting` / `.active` / `.done` join
  the constants table.
- **Layout and orientation builders.**
  `LayoutBuilder(builder)` yields the parent's `BoxConstraints` so
  source can choose a layout at build time. `BoxConstraints.maxWidth`,
  `.minWidth`, `.maxHeight`, `.minHeight`, `.biggest`, `.smallest`
  are whitelisted property accesses.
  `OrientationBuilder(builder)` yields `Orientation.portrait` or
  `.landscape` (both registered as constants).
- **Closure builder helpers.**
  `lib/src/builders/closure_builder_helpers.dart` holds the shared
  closure-to-Flutter-callback adapters:
  `toIndexedBuilder`, `toFutureSnapshotBuilder`,
  `toStreamSnapshotBuilder`, `toLayoutBuilder`,
  `toOrientationBuilder`. Arity + type validation lives in one
  place per the shared-helper-first discipline.

### Fixed

- **Dispatch precedence for named-constructor invocations.**
  `InvocationResolver` now checks the value registry first when a
  `MethodInvocation` or `InstanceCreationExpression` carries a
  `constructorName` (e.g. `ListView.builder(...)`). Previously a
  bare widget builder registered under the same `typeName`
  (`ListView`) would shadow any value-builder named-constructor
  variants (`ListView.builder`). Widget-first precedence remains
  for bare invocations (`Text('hi')`); only the named-ctor path
  changed. This fix unblocked the entire v1.2.0 .builder family
  and is covered by the new builder tests.

### Notes

- Value count 28 to 34; widget count 80 to 84.
- 82 new tests across the ten new builders, closure helper suite,
  `AsyncSnapshot` / `BoxConstraints` property access, and five
  integration smokes (lazy ListView, LayoutBuilder responsive
  split, FutureBuilder with host-provided future, OrientationBuilder,
  SliverList.builder inside CustomScrollView).
- `BuildContext` passed to closures remains opaque in v1.2.0. The
  `Theme.of(context)` / `MediaQuery.of(context)` accessors arrive
  in v1.4.0.

## [1.1.0] - 2026-04-19 - lifecycle and controllers

### Added

- **StatefulBuilder lifecycle closures.** `initState`, `dispose`,
  and `didUpdateWidget` optional closure params let source own the
  full mount / unmount / rebuild lifecycle of its state bag.
  `autoDisposeListenables: true` (default `false`) calls `dispose`
  on any `initial` entry that implements `ChangeNotifier` when the
  widget unmounts. The source-level dispose closure runs first, then
  auto-disposal, so the source can perform ordered cleanup.
- **Controller value builders.** `TextEditingController(text)`,
  `ScrollController(initialScrollOffset, keepScrollOffset,
  debugLabel)`, `FocusNode(debugLabel, skipTraversal,
  canRequestFocus, descendantsAreFocusable,
  descendantsAreTraversable)`, and `PageController(initialPage,
  keepPage, viewportFraction)` join the default value-builder set.
  `TabController` stays deferred pending v1.9.0's vsync story
  (shared with `AnimationController`).
- **Controller method whitelist.** `invokeBuiltinMethod` gains
  controller dispatch for `TextEditingController.clear` plus
  `.text` / `.value` getters; `ScrollController.jumpTo` and
  `.animateTo`; `FocusNode.requestFocus`, `.unfocus`, `.hasFocus`;
  `PageController.jumpToPage` and `.animateToPage`;
  `TabController.animateTo` and `.index` for host-provided
  instances.
- **Widget controller wiring.** `TextField`, `ListView`,
  `SingleChildScrollView`, `CustomScrollView`, and `TabBar` accept
  an optional `controller:` arg so source-constructed controllers
  reach the widgets that should own them. `TextField`'s private
  state keeps the existing internal-controller path as the default
  and switches to the external controller when supplied; disposal
  stays with whichever side constructed the controller.

### Notes

- Value count 24 to 28. No new widget count growth (the controller
  wiring extends existing builders' arg surface without adding new
  typeNames). About 43 new tests across the controller builders,
  the lifecycle hooks, the method whitelist, and two integration
  smokes (controller lifecycle with a persistent TextEditingController,
  programmatic scroll with source-owned ScrollController).
- The v1.0.0 stability commitment holds. No breaking changes;
  existing source that did not supply a controller continues to
  work unchanged.

## [1.0.0] - 2026-04-19 - stateful source end-to-end

### Added

- **Named components (Phase F of the v1.0.0 roadmap).** Source can
  declare reusable components and invoke them by name. New
  `RuneComponent` value type carries a name, parameter list, and
  body closure. New `ComponentRegistry` holds components
  per-RuneView (source-scoped, not global; a fresh registry every
  render). New `RuneComponentBuilder` (value builder) constructs
  and registers a component; new `RuneCompose` widget builder
  accepts a `components: [...]` declaration list and a `root:`
  widget tree. `InvocationResolver` dispatches against the
  component registry before the widget and value registries, so a
  component named `Text` shadows the default Text builder.
  Invocation is named-arg only; positional args or named
  constructors raise `ResolveException`; missing or extra named
  arguments raise as well. Thirty-two new unit tests plus three
  integration smokes drive single-use, multi-use, and nested
  components through a live `RuneView`.

### Notes

- Phase E of the v1.0.0 roadmap (collection method chaining with
  closures) shipped informally during Phase A.3 (v0.9.0) as
  `.map`, `.where`, `.fold`, `.reduce`, and friends. v1.0.0
  acknowledges it as complete; no additional resolver work.
- **Stability commitment.** The public API surface is stable for
  early adopters. Post-1.0.0 minor releases add new builders,
  resolver arms, and source-language capabilities; patch releases
  cover fixes and refinements. Breaking changes warrant a major
  bump or explicit deprecation cycle.
- Full public surface from `lib/rune.dart`: `RuneView`,
  `RuneConfig`, `RuneDefaults`, `RuneContext`, `RuneException`
  (sealed plus five variants), `RuneBuilder` /
  `RuneWidgetBuilder` / `RuneValueBuilder`, `ResolvedArguments`,
  `RuneDataContext`, `RuneEventDispatcher`, `RuneBridge`,
  `RuneDevOverlay`, `ExtensionRegistry`, `RuneExtensionHandler`,
  `Registry`, `WidgetRegistry`, `ValueRegistry`,
  `ConstantRegistry`, `ComponentRegistry`, `RuneComponent`,
  `RuneClosure`, `RuneScope`, `RuneState`, `SourceSpan`.

## [0.11.0] - 2026-04-19 - source-level state and setState sugar

### Added

- **Source-level state via StatefulBuilder and RuneState (Phase C
  of the v1.0.0 roadmap).** New `RuneState` value type (in
  `lib/src/core/rune_state.dart`) carries a mutable string-keyed
  bag readable from source through the existing Map-first branch
  of `PropertyResolver` and `IdentifierResolver`. Writes go
  through `state.set(key, value)`, `state.setMany({...})`,
  `state.remove(key)`, and `state.clear()`; each mutating
  operation fires an `onMutation` callback bound to the hosting
  widget's `setState`. New `StatefulBuilder` widget builder
  (registered as a default) takes a required `initial` map to
  seed the state on first mount plus a required `builder` closure
  that receives the state and returns a Widget; mutations that
  fire mid-build schedule a post-frame `setState` instead of
  re-entering synchronously, so infinite rebuild loops are
  impossible. `invokeBuiltinMethod` grows a `RuneState` branch so
  source can call `state.set`, `state.setMany`, `state.remove`,
  `state.clear`, `state.get`, `state.has`.
- **`setState` sugar and `RuneState` property-access assignment
  (Phase D of the v1.0.0 roadmap).** Source can now write
  `state.counter = state.counter + 1` (PrefixedIdentifier
  left-hand-side) or `(expression).counter = v` (PropertyAccess
  LHS); the assignment routes through `RuneState.set(memberName,
  rhs)` and triggers exactly one rebuild via the Phase C
  mutation callback. `InvocationResolver` also recognises the
  bare `setState(() { ... })` identifier with a no-arg closure
  and runs the closure; because Phase C mutations already
  trigger rebuilds, the wrapper is a semantic passthrough that
  exists to match Flutter's conventional pattern. Assignment to
  a non-`RuneState` prefix / target raises `ResolveException`
  citing the offending type; compound operators (`+=`, `-=`,
  etc.) stay rejected; `setState` calls with wrong arity or
  non-closure args raise clear `ResolveException` messages.

## [0.10.0] - 2026-04-19 - block-body closures and local scope

### Added

- **Block-body closures with local scope and assignment (Phase B
  of the v1.0.0 roadmap).** `(x) { ... }` closures now parse and
  execute; the Phase A.1 arrow-only restriction is lifted.
  `RuneClosure` gains two named constructors (`.expression` for
  the Phase A.1 arrow-body shape, `.block` for Phase B).
  Block-body closures create a fresh `RuneScope` on each call
  and walk the body's statements via the new
  `StatementResolver`. Early `return` short-circuits the
  sequence and yields the returned value; block bodies without
  a return yield `null`, matching Dart.
- **Local scope via `RuneScope`.** `var` and `final` declarations
  inside a block body live in a mutable `RuneScope`
  (`lib/src/core/rune_scope.dart`) with parent-chaining for
  nested blocks. `declare()` enforces no re-declaration in the
  same scope; `assign()` walks outward to find the declaring
  scope and raises `BindingException` when no scope owns the
  name. Distinct from `RuneDataContext`, which stays immutable
  and host-owned. `RuneContext` gains an optional nullable
  `scope` field (plus `copyWith` arg), and
  `IdentifierResolver.resolveSimple` now checks `ctx.scope`
  before `ctx.data` so block-body locals shadow host-provided
  data keys of the same name, matching Dart's lexical scoping.
- **Statement-level execution.** New
  `lib/src/resolver/statement_resolver.dart` dispatches
  `ExpressionStatement`, `ReturnStatement`,
  `VariableDeclarationStatement`, and `IfStatement`, plus
  nested `Block` as a child scope. Unsupported statements
  (loops, `try`/`catch`, `switch`) raise `ResolveException`
  pointing at the offending node.
- **Assignment expressions for locals.**
  `ExpressionResolver` gains an `AssignmentExpression` arm for
  the `=` operator with `SimpleIdentifier` on the left.
  Assigning to a host-supplied data name is forbidden with a
  clear diagnostic (data mutation is Phase C territory).
  Compound operators (`+=`, `-=`) and assignment to
  `PropertyAccess` / `IndexExpression` left-hand-sides stay
  deferred to Phase D. A `bindStatements` hook mirrors the
  existing `bind` / `bindProperty` pattern; the live pipeline
  uses a lazy self-bound `StatementResolver` so
  `dynamic_view.dart` needs no change.

## [0.9.0] - 2026-04-19 - closures in source

### Added
- **Closures in source (Phase A of the v1.0.0 roadmap).** `(x) => x + 1`
  now parses as a first-class value. The resolver gains a new
  `FunctionExpression` arm that produces `RuneClosure`s, captures
  the enclosing `RuneContext`, and re-enters the expression resolver
  on each call with the closure's arguments bound alongside the
  captured data. Arrow-body form only in this release; block-body
  closures (`(x) { return x; }`) are deferred to a later phase with
  a clear `ResolveException` message.
- **Builder callbacks accept closures.** Every event-accepting widget
  builder now accepts either a `String` event name (existing
  behavior, unchanged) or a closure. `ElevatedButton(onPressed: () =>
  state.counter + 1, ...)` routes through the widget's Flutter
  callback and invokes the closure with the event's arguments.
  `valueEventCallback<T>` forwards the bool/int/String/etc. value as
  the single positional argument to the closure; `voidEventCallback`
  calls the closure with an empty args list.
- **Collection methods with closures.** `invokeBuiltinMethod` grows
  eight new closure-accepting methods on `List`: `.map`, `.where`,
  `.any`, `.every`, `.firstWhere`, `.forEach`, `.fold`, `.reduce`.
  `.map` and `.where` return materialised `List<Object?>` (not lazy
  `Iterable`) so downstream builders see concrete lists.
  `.any/.every/.firstWhere/.where` validate that the closure's
  return is a `bool`. `.fold` takes an initial value plus a
  two-parameter combiner. `.reduce` takes a two-parameter combiner;
  empty lists propagate Dart's own `StateError('No element')`.

### Notes

- Phase A.1, A.2, and A.3 landed as four commits on top of v0.8.0.
  The architecture test gained a dedicated guard for the new
  `lib/src/builders/event_callback.dart` to `lib/src/resolver/rune_closure.dart`
  edge, ensuring future changes cannot silently pull unrelated
  resolver files into the builders layer.
- Phase B (block-body closures, local variable declarations, scoped
  mutation) is next on the v1.0.0 roadmap and ships in v0.10.0.

## [0.8.0] - 2026-04-19 - pragmatic gaps

### Added
- **Transform.translate, Transform.flip, and Offset**. Closes the
  Transform value-builder family started in v0.7.0 (which shipped
  `Transform.scale` and `Transform.rotate` but deferred translate
  pending an `Offset` value builder). `Offset(dx, dy)` takes two
  positional nums coerced to double. `Transform.translate` requires
  an `offset` plus optional `child` and `transformHitTests`.
  `Transform.flip` takes optional `flipX` / `flipY` booleans (both
  default false) plus `transformHitTests` and optional `child`;
  alignment is fixed to `Alignment.center` by Flutter's own
  constructor.
- **Sizing primitives**. Four constraint-manipulation widgets plus
  one value builder for the constraints themselves.
  `ConstrainedBox` applies arbitrary `BoxConstraints` to its child
  (required `constraints`). `LimitedBox` caps the child only when
  the parent offers unbounded constraints along that axis; optional
  `maxWidth` / `maxHeight` default to `double.infinity`.
  `UnconstrainedBox` discards parent constraints along one axis or
  both; optional `constrainedAxis`, `alignment`, `clipBehavior`.
  `FractionallySizedBox` sizes its child to a fraction of the
  parent; optional nullable `widthFactor` / `heightFactor` plus
  `alignment`. `BoxConstraints(minWidth, maxWidth, minHeight,
  maxHeight)` joins the value-builder set; all four edges default
  to Flutter's own (0 for mins, infinity for maxes).
- **Form input tiles**. `CheckboxListTile`, `SwitchListTile`,
  `RadioListTile` combine the existing Checkbox / Switch / Radio
  builders with a `ListTile` layout (title, subtitle, secondary,
  controlAffinity). All follow the two-way binding contract; the
  tile dispatches `(onChanged, [newValue])` on tap.
  `CheckboxListTile` and `RadioListTile` discriminate absent value
  (ArgumentException) from explicit `value: null` (legitimate for
  tristate / radio-deselect). `ListTileControlAffinity.leading`,
  `.trailing`, `.platform` join the constants table.
- **`MaterialColor[shade]` index access**. `Colors.grey[200]` now
  resolves in Rune source. Integer shade lookups on any registered
  `MaterialColor` go through `ExpressionResolver._resolveIndex`.
  Non-int indices raise `ResolveException`; unknown shades return
  `null`, matching Flutter's own `MaterialColor.operator[]`
  semantics.
- **Material 3 navigation**. `NavigationBar` with
  `NavigationDestination` replaces the Material 2 pattern
  (`BottomNavigationBar` / `BottomNavigationBarItem` still ship for
  consumers that need Material 2 theming). Required `destinations`
  (at least 2) and `selectedIndex`; optional `onDestinationSelected`
  event, plus theming via `backgroundColor`, `elevation`, `height`,
  `indicatorColor`. `NavigationRail` is the landscape / tablet
  variant with `extended` toggle, optional `labelType`
  (`NavigationRailLabelType` enum: `none`, `selected`, `all`),
  `leading`, `trailing`, and sizing (`minWidth`, `elevation`).
  `NavigationRailDestination` carries `icon` + `label` Widgets plus
  optional `selectedIcon` and `padding`.
- **Chip variants**. `ChoiceChip` (single-select) and `FilterChip`
  (multi-select toggle) complement the existing `Chip` info-tag
  builder. Both require `label` (Widget) and `selected` (bool);
  optional `onSelected` event name dispatches `(name, [newBool])`
  on tap plus avatar and colour theming. `FilterChip` also accepts
  `checkmarkColor` and `showCheckmark` (default true). ActionChip
  and InputChip remain deferred pending a concrete use case.

## [0.7.0] - 2026-04-19 - wrappers, slivers, transforms

### Added
- **Wrapper and utility widgets.** Seven everyday builders for
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
- **Slivers and CustomScrollView.** Compose advanced scrollable
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
- **Display wrappers and programmatic transforms.** Five
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

## [0.6.0] - 2026-04-19 - widget breadth (Material, animations, grids)

### Added
- **Material widget breadth.** Five more everyday builders.
  `FloatingActionButton` (onPressed event, optional child/tooltip/
  colors/mini), `Chip` (required label, optional avatar, onDeleted
  event, colors/style), `Badge` (wraps a child with an optional
  label overlay; supports backgroundColor/textColor/smallSize/
  largeSize/isLabelVisible), `CircularProgressIndicator` and
  `LinearProgressIndicator` (both indeterminate by default, set
  `value: 0.0-1.0` for determinate).
- **Animation expansions.** Four more animated widget builders
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
- **Grid views.** `GridView.count` (fixed column count) and
  `GridView.extent` (max cell extent) join the default value-builder
  registry. Both require their primary sizing arg
  (`crossAxisCount: int` / `maxCrossAxisExtent: num`); optional
  `children`, `mainAxisSpacing`, `crossAxisSpacing`,
  `childAspectRatio`, `scrollDirection` (Axis), `padding`,
  `shrinkWrap`, `reverse`. `GridView.builder` is deferred pending
  function-literal support in source.

## [0.5.0] - 2026-04-19 - animations + navigation + dropdown

### Added
- **Animated widgets and Duration support.** `AnimatedContainer`,
  `AnimatedOpacity`, `AnimatedPositioned`. Each takes a required
  `duration: Duration(...)` and optional `curve` (defaulting to
  `Curves.linear`). When the host rebuilds `RuneView` with new
  values for any tweenable slot (dimensions, colour, opacity,
  position), Flutter animates between old and new automatically.
  `Duration(milliseconds: n)` is a new default value builder; nine
  canonical `Curves.*` instances (`linear`, `easeIn/Out/InOut`,
  `bounceIn/Out`, `elasticIn/Out`, `fastOutSlowIn`) join the
  constants table.
- **Navigation widgets.** `BottomNavigationBar` (required `items`
  + `currentIndex`, optional `onTap` dispatching `(name, [newIndex])`,
  theming via `type/selectedItemColor/unselectedItemColor/
  backgroundColor`), `TabBar` + `Tab` (assume a host-side
  `DefaultTabController` ancestor), plus `BottomNavigationBarItem`
  as a value builder. `BottomNavigationBarType.fixed` /
  `.shifting` join the constants table.
- **Dropdown select.** `DropdownButton` with `DropdownMenuItem`.
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
  test continues to pass unchanged (pure refactor).

## [0.4.0] - 2026-04-19 - interactive + layout polish

### Added
- **Gesture handlers.** `GestureDetector` and `InkWell` widget
  builders, each wrapping a child with `onTap`, `onDoubleTap`, and
  `onLongPress` named-event dispatch. `InkWell` adds Material
  ink-splash feedback plus an optional `borderRadius` arg to shape
  the splash to a rounded container. Any widget now becomes
  tappable in Rune source without having to be a `*Button`.
- **Layout and scroll helpers.** `SingleChildScrollView` (wraps
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
  contract established by TextField/Switch/Checkbox: the host
  owns state, interactions fire named events with the new value
  as the single argument.

### Fixed
- Radio builder's test file used `hide RadioBuilder` to avoid a
  naming collision with a Flutter internal symbol on newer Flutter
  versions, which broke compilation on the Flutter 3.24.0 pinned
  in CI (where that symbol isn't exported). Switched to a
  `show`-import of just the needed names so the test compiles on
  any Flutter >= 3.22.

## [0.3.0] - 2026-04-19 - runtime-value members + layout helpers

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
  invocation stays forbidden (whitelist only), matching the
  store-compliance posture.
- **Three new widget builders.** `ListTile`, `Divider`, `Spacer`.
  `ListTile` covers the common slots (`title`, `subtitle`, `leading`,
  `trailing`) plus `onTap` as a named event and `dense`/`enabled`/
  `selected` flags. `Divider` accepts `height`, `thickness`, `indent`,
  `endIndent`, `color`. `Spacer` accepts `flex` (default 1). With
  these registered, the Quickstart snippet in the README now runs
  verbatim against `RuneConfig.defaults()`.

### Changed
- `PropertyResolver` precedence is now: Map key (if present), then
  built-in property (if the pair is recognised), then extension
  registry. Previously a Map with an absent key returned `null`
  silently; now if the absent key happens to match a built-in
  property name (e.g. `cart.length` on a Map with no `length` key),
  the Map's own size is returned. Callers relying on the old
  null-for-absent behaviour for keys that collide with built-in
  property names should use explicit `[…]` indexing instead.
- `IdentifierResolver.resolvePrefixed` gained the same built-in
  awareness so `items.length` (a `PrefixedIdentifier`) behaves
  identically to `cart.items.length` (a `PropertyAccess`); both
  consult the built-in table when the data value is a non-Map
  type or when a Map lacks the requested key.
- `InvocationResolver` now dispatches runtime method calls on
  resolved values. When a `MethodInvocation`'s target is a
  `SimpleIdentifier` that doesn't match a registered builder type,
  or any non-identifier target, the resolver resolves the target,
  then looks up `(runtimeType, methodName)` in the whitelist.
  Builder dispatch still wins for `TypeName.ctor(...)` shapes when
  `TypeName` is in the widget or value registry.

## [0.2.0] - 2026-04-19 - diagnostics + richer source language

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
- **Form input widget builders with two-way data binding.**
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
  factory.** The single source of truth for
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
  thrown exception. Backwards-compatible: existing callers without
  location keep working.

### Fixed
- Internal code in `lib/src/builders/values/` no longer imports
  `package:rune/rune.dart`; barrel imports are reserved for
  external consumers, matching the unidirectional layering guarded
  by `test/architecture/import_flow_test.dart`.
- Root `flutter analyze` no longer crawls `packages/**`; the
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
  are unaffected; the production path threads `widget.source`
  automatically.

## [0.1.0] - 2026-04-18 - Phase 4

### Added
- `benchmark/parse_resolve_bench.dart`: runnable Dart script that
  measures parse + resolve time on a canonical ~30-node widget tree
  over 500 iterations. Reports cold (cache-miss) and warm (cache-hit)
  stats; soft-checks cold p95 against a 16ms / 60fps budget.
- `RuneDevOverlay`: opt-in `StatelessWidget` wrapper that, on
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

## [0.0.10] - 2026-04-18 - Phase 3c

### Added
- Sibling package `rune_responsive_sizer` at `packages/rune_responsive_sizer/`:
  a `RuneBridge` implementation that registers four responsive-sizing
  property extensions: `.w` (percent of screen width), `.h` (percent of
  screen height), `.sp` (text-scaled pixels), `.dm` (percent of
  `min(width, height)`). Applied via
  `RuneConfig.defaults().withBridges([const ResponsiveSizerBridge()])`.
  Independent version track; ships at `0.0.1` alongside this root bump.

## [0.0.9] - 2026-04-18 - Phase 3b

### Added
- Deep dot-path data access: `user.profile.name` and arbitrary-depth
  traversal now work through `PropertyResolver`'s new map-first
  branch. Each `PropertyAccess` segment walks one map level; missing
  keys return `null`.
- Index access: `items[0]`, `map['key']`, `items[0].title` via a new
  `IndexExpression` dispatch arm. List out-of-range throws
  `ResolveException`; non-list/map targets throw with a type-mismatch
  message.
- `for`-element in list literals: `[for (final item in items)
  Text(item.title)]`. Loop variable binds into a scoped
  `RuneDataContext` via `extend`, so `item.title` resolves against
  the merged data. Static elements around the for-element are
  preserved in source order; nested for-elements compose. Only
  `for`-each with declaration is supported (C-style `for` and
  `IfElement` throw `ResolveException`).

### Changed
- `PropertyResolver.resolve`: when the target is a
  `Map<String, Object?>`, the map value wins over any same-named
  extension. Data beats extensions on conflict (matches the
  data-first rule established by `IdentifierResolver.resolvePrefixed`
  in Phase 3a).

## [0.0.8] - 2026-04-18 - Phase 3a

### Added
- `ExtensionRegistry`: property-name-keyed registry of
  `(target, ctx) => Object?` handlers. Used by the new
  `PropertyResolver` to evaluate receiver-style property access like
  `10.px`, `(5).doubled`.
- `RuneBridge`: single-method contract (`void registerInto(RuneConfig)`)
  that third-party packages implement to bundle widget/value/constant/
  extension contributions. Applied via `RuneConfig.withBridges([...])`.
- `PropertyResolver`: dispatcher arm for `PropertyAccess` AST nodes;
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

## [0.0.7] - 2026-04-18

### Changed
- Linter floor raised from `flutter_lints ^4.0.0` to
  `very_good_analysis ^5.1.0`. All source and tests pass the stricter
  rule set.

### Added
- `CHANGELOG.md` (this file) documenting every phase since `0.0.1-phase1`.
- `pubspec.yaml` metadata: `homepage`, `topics` for richer `pub.dev`
  presentation.

## [0.0.6] - 2026-04-18 - Phase 2e

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

## [0.0.5] - 2026-04-18 - Phase 2d

### Added
- Three button widget builders: `ElevatedButton`, `TextButton`,
  `IconButton`. Each translates a `String` `onPressed` source argument
  into a `VoidCallback` that invokes `ctx.events.dispatch(eventName)`.
- `RuneEventDispatcher.setCatchAllHandler`: catch-all bridge invoked
  on every dispatch in addition to any named handler.
- `RuneView._buildContext` now installs `widget.onEvent` as the
  dispatcher's catch-all when non-null, closing the gap that left
  source-declared events unobservable.

## [0.0.4] - 2026-04-18 - Phase 2c

### Added
- Ten widget builders: `Padding`, `Center`, `Stack`, `Expanded`,
  `Flexible`, `Card`, `Icon`, `ListView`, `AppBar`, `Scaffold`.
- Two `Image` value builders (`Image.network`, `Image.asset`),
  registered via `ValueRegistry` so they can coexist under the shared
  `typeName == 'Image'` and disambiguate on constructor name.
- `FlexFit` enum seeded into the Phase 2a constants module.
- Phase 2c icons seed (`phase_2c_icons.dart`): ~60 common `Icons.*`
  constants.

## [0.0.3] - 2026-04-18 - Phase 2b

### Added
- Seven value builders: `EdgeInsets.symmetric`, `EdgeInsets.only`,
  `EdgeInsets.fromLTRB`, `Color(hex)`, `TextStyle`,
  `BorderRadius.circular`, `BoxDecoration`.
- `BoxShape` enum seeded into constants registry.

### Fixed
- `ContainerBuilder` was silently dropping the `decoration` named
  argument. Discovered via Phase 2b integration tests and fixed as
  part of the same phase.

## [0.0.2] - 2026-04-18 - Phase 2a

### Added
- `ConstantRegistry`: two-level `typeName.memberName` keyed store
  (independent of the generic `Registry<T>` base because the
  two-level shape lets error messages cite both halves).
- `IdentifierResolver`: handles `SimpleIdentifier` (data lookup in
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

## [0.0.1] - 2026-04-18 - Phase 1 MVP

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
- `RuneView` public `StatefulWidget`: parses, caches (LRU), resolves,
  renders; `onError` callback + `fallback` widget for failures.
- Example app at `example/lib/main.dart` demonstrating the full Phase 1
  feature set.

[Unreleased]: https://github.com/CanArslanDev/rune/compare/v1.11.0...HEAD
[1.11.0]: https://github.com/CanArslanDev/rune/compare/v1.10.0...v1.11.0
[1.10.0]: https://github.com/CanArslanDev/rune/compare/v1.9.0...v1.10.0
[1.9.0]: https://github.com/CanArslanDev/rune/compare/v1.8.0...v1.9.0
[1.8.0]: https://github.com/CanArslanDev/rune/compare/v1.7.0...v1.8.0
[1.7.0]: https://github.com/CanArslanDev/rune/compare/v1.6.0...v1.7.0
[1.6.0]: https://github.com/CanArslanDev/rune/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/CanArslanDev/rune/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/CanArslanDev/rune/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/CanArslanDev/rune/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/CanArslanDev/rune/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/CanArslanDev/rune/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/CanArslanDev/rune/compare/v0.11.0...v1.0.0
[0.11.0]: https://github.com/CanArslanDev/rune/compare/v0.10.0...v0.11.0
[0.10.0]: https://github.com/CanArslanDev/rune/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.com/CanArslanDev/rune/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/CanArslanDev/rune/compare/v0.7.0...v0.8.0
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
