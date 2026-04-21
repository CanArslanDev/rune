# Sibling bridge packages

Rune ships core widget / value / constant / extension registries and a default Material widget set. Anything beyond that lives in a **bridge package** that consumers opt into via `RuneConfig.defaults().withBridges([...])`. This keeps the core small, dependency-free (beyond `analyzer`), and lets each integration track its own version cadence on pub.dev.

This guide covers all five bridges that ship alongside `rune` today.

## Quick selection

| Want | Use |
|------|-----|
| Percent-of-screen sizing (`50.w`, `10.h`, `16.sp`, `12.dm`) | [rune_responsive_sizer](#rune_responsive_sizer) |
| Cupertino (iOS-style) widgets in source | [rune_cupertino](#rune_cupertino) |
| Reactive state via `ChangeNotifier` + `Consumer` / `Selector` | [rune_provider](#rune_provider) |
| Inline route declarations (`GoRoute`, `GoRouter`) | [rune_router](#rune_router) |
| Inspect live `RuneView`s from Flutter DevTools | [rune_devtools_extension](#rune_devtools_extension) |

You can stack multiple bridges on one config:

```dart
final config = RuneConfig.defaults().withBridges(const [
  ResponsiveSizerBridge(),
  CupertinoBridge(),
  ProviderBridge(),
]);
```

Each bridge owns a disjoint name space; duplicate-name collisions raise `StateError` at registration time.

## rune_responsive_sizer

Four property extensions for percent-of-screen sizing.

**Install**

```yaml
dependencies:
  rune_responsive_sizer: ^0.0.1
```

**Apply**

```dart
final config = RuneConfig.defaults()
    .withBridges(const [ResponsiveSizerBridge()]);
```

**Use from source**

```
SizedBox(width: 50.w, height: 10.h)
Text('scaled', style: TextStyle(fontSize: 16.sp))
Container(width: 20.dm, height: 20.dm)
```

| Extension | Formula |
|-----------|---------|
| `.w` | percent of screen width |
| `.h` | percent of screen height |
| `.sp` | text-scaled pixels (respects `MediaQuery.textScaler`) |
| `.dm` | percent of `min(width, height)` |

Handlers throw `ArgumentError` on non-numeric targets and `StateError` when `ctx.flutterContext` is null (happens only in unit tests with no live widget tree).

## rune_cupertino

15 Cupertino widget builders, a `CupertinoThemeData` value builder, 30 `CupertinoIcons` constants, and 3 supporting value builders.

**Install**

```yaml
dependencies:
  rune_cupertino: ^0.1.1
```

**Apply**

```dart
final config = RuneConfig.defaults()
    .withBridges(const [CupertinoBridge()]);
```

**Use from source**

```
CupertinoApp(
  home: CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(middle: Text('Home')),
    child: Center(
      child: CupertinoButton(
        onPressed: 'ok',
        child: Text('Continue'),
      ),
    ),
  ),
)
```

**Widgets**: `CupertinoApp`, `CupertinoPageScaffold`, `CupertinoNavigationBar`, `CupertinoButton`, `CupertinoSwitch`, `CupertinoSlider`, `CupertinoTextField`, `CupertinoActivityIndicator`, `CupertinoAlertDialog`, `CupertinoDialogAction`, `CupertinoPicker`, `CupertinoActionSheet`, `CupertinoSegmentedControl`, `CupertinoTabBar`, `CupertinoTabScaffold`.

**Values**: `CupertinoThemeData`, `CupertinoActionSheetAction`, `FixedExtentScrollController`.

**Icons**: `CupertinoIcons.home`, `CupertinoIcons.back`, `CupertinoIcons.settings`, `CupertinoIcons.heart`, etc. (30 entries; see the package README for the full list).

## rune_provider

`ChangeNotifierProvider`, `Consumer`, and `Selector` from [`package:provider`](https://pub.dev/packages/provider).

**Install**

```yaml
dependencies:
  rune_provider: ^0.1.0
```

**Apply**

```dart
final config = RuneConfig.defaults()
    .withBridges(const [ProviderBridge()]);
```

**Use from source**

Declare a `ChangeNotifier` on the host side that implements `RuneReactiveNotifier`:

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

Then consume from source:

```
ChangeNotifierProvider(
  value: counter,
  child: Consumer(
    builder: (ctx, state, child) => Text('Count: ${state.count}'),
  ),
)
```

The `state` field is the `Map`-projected view the source sees. `Selector` rebuilds only when a derived value changes:

```
Selector(
  selector: (ctx, state) => state.count,
  builder: (ctx, count, child) => Text('$count'),
)
```

**Alternative**: v1.17.0+ lets you register property + method accessors directly on a typed `ChangeNotifier` via `config.members.registerProperty<CounterNotifier>('count', (t, _) => t.count)`. You can then write `counter.count` without the `RuneReactiveNotifier` `state` indirection.

## rune_router

`GoRoute`, `GoRouter`, and a `GoRouterApp` widget wrapper that mounts `MaterialApp.router`.

**Install**

```yaml
dependencies:
  rune_router: ^0.1.0
```

**Apply**

```dart
final config = RuneConfig.defaults()
    .withBridges(const [RouterBridge()]);
```

**Use from source**

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

Source-level imperatives (`context.go('/path')`) are not directly exposed in v0.1.0. Host apps navigate by holding a reference to the `GoRouter` and calling `router.go('/settings')` from an `onEvent` callback. A later version can register a `Router.go` imperative via the v1.16.0 `ImperativeRegistry` if demand materializes.

## rune_devtools_extension

Flutter DevTools extension that surfaces a **rune** tab showing every live `RuneView` in the host app: source, data context, parse cache size, last render error.

**Install**

```yaml
dev_dependencies:
  rune_devtools_extension: ^0.1.0
```

**Setup**

No host-side registration. `rune` v1.18.0+ automatically registers the `ext.rune.inspect` VM service extension when a `RuneView` mounts; DevTools auto-discovers the extension and shows the tab after a restart.

**Details**: see [devtools.md](devtools.md).

## Writing your own bridge

A bridge is a `final class` implementing `RuneBridge` with a single `registerInto(RuneConfig config)` method. The root `README.md` has a step-by-step walkthrough in its "Writing a bridge" section; the five bridges above are live reference implementations ordered from simplest (`rune_responsive_sizer`, ~70 lines) to most elaborate (`rune_devtools_extension`, full Flutter-web app).

Propose a new bridge by opening an issue using the [bridge-proposal template](../.github/ISSUE_TEMPLATE/bridge_proposal.md).
