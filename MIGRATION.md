# Migration guide

This document walks you through upgrading between major Rune milestones. Format: each section lists the breaking changes from the previous anchor version, the rationale, and the concrete before/after diff for host-side and source-side code.

If you find a breaking change that isn't listed, open an issue with the bug-report template and we'll document it here.

## From 0.x to 1.x

### Public API surface

| Before (0.x)                  | After (1.x)                                 | Why                                            |
| ----------------------------- | ------------------------------------------- | ---------------------------------------------- |
| `RuneException` subclasses listed individually in the barrel | `export 'src/core/exceptions.dart';` (all 5 variants) | Consumers no longer have to chase exception names. |
| `RuneConfig()` with positional args | `RuneConfig()` then `RuneConfig.defaults()` | `defaults()` was a constructor in late 0.x; 1.x kept the static factory and added `withBridges([...])`. |
| `RuneBridge.registerInto(RuneConfig)` was optional | Required | Every bridge implements one method; the contract tightened for type safety. |

Most host-side code needs no edits. The breaking changes below affect advanced use cases.

### Stateful source and closures (v1.0.0)

v1.0.0 introduced `StatefulBuilder`, `RuneClosure`, and `RuneComponent`. These are purely additive: existing source strings work without changes.

One subtle migration item: if your 0.x source used a bare identifier that later became a closure parameter name, it now shadows the data-context lookup.

Before (0.x):

```dart
RuneView(
  data: {'state': someMap},
  source: r'''
    Column(children: [
      Text(state.count.toString()),  // reads from data
    ])
  ''',
)
```

After (v1.0+, if wrapped in a StatefulBuilder):

```dart
RuneView(
  data: {'state': someMap},  // outer state is shadowed
  source: r'''
    StatefulBuilder(
      initial: {'count': 0},
      builder: (state) =>  // `state` now refers to the builder's state bag
        Text(state.count.toString()),
    )
  ''',
)
```

If you need both, rename one:

```
data: {'outer': someMap},
source: r"StatefulBuilder(..., builder: (s) => Text(s.count + outer.base))",
```

### Lifecycle + controllers (v1.1.0)

`TextField(value:, onChanged:)` gained an internal `TextEditingController` when no external controller is supplied. 0.x users who threaded a controller through `data:` and rendered it with a custom widget should move to the simpler pattern:

Before:

```dart
RuneView(
  data: {'controller': _controller},
  source: "MyCustomTextField(controller: controller, onChanged: 'typed')",
)
```

After:

```dart
RuneView(
  data: {'username': username},
  source: "TextField(value: username, onChanged: 'typed')",
)
```

If you still need an external controller (e.g. for focus programming), supply it via `data:` and pass it through the `controller:` slot; the builder respects external controllers.

### Closure-based builder widgets (v1.2.0)

`ListView.builder`, `GridView.builder`, `FutureBuilder`, `StreamBuilder`, `LayoutBuilder`, `OrientationBuilder`, `Consumer`, and friends expect **closures**, not registered callbacks. If your 0.x source tried to pass an event name where a closure is now required, the resolver raises `ArgumentException`.

Before (0.x, would throw today):

```
ListView.builder(
  itemCount: 10,
  itemBuilder: 'buildItem',  // event name
)
```

After (v1.2+):

```
ListView.builder(
  itemCount: 10,
  itemBuilder: (ctx, index) => ListTile(title: Text('Row $index')),
)
```

Event-shaped callbacks (`onPressed:`, `onChanged:`) still accept either a string event name or a closure.

### Dialogs + overlays + imperative bridges (v1.3.0)

`showDialog`, `showModalBottomSheet`, `showSnackBar`, and `Navigator.*` moved from "fake widget" shapes in 0.x to imperative bridges. Source-level call syntax now works:

Before (0.x, doesn't work):

```dart
// host side
onEvent: (name, [args]) {
  if (name == 'showAbout') {
    showDialog(context: ctx, builder: (_) => AboutDialog());
  }
}
```

After (v1.3+):

```
// source side
TextButton(
  onPressed: () => showDialog(
    context: ctx,
    builder: (ctx) => AboutDialog(),
  ),
  child: Text('About'),
)
```

Source-level calls route through `RuneContext.flutterContext`, so the `RuneView` must be mounted under a `MaterialApp` (or similar) that provides a `BuildContext`.

### Theme + Material 3 polish (v1.4.0)

`Theme.of(context)` + property whitelist (e.g. `Theme.of(ctx).colorScheme.primary`) landed. 0.x users who threaded `ThemeData` through `data:` can drop that indirection:

Before:

```dart
RuneView(
  data: {'theme': Theme.of(context)},
  source: "Container(color: theme.colorScheme.primary)",
)
```

After:

```dart
RuneView(
  source: "Container(color: Theme.of(ctx).colorScheme.primary)",
)
```

### Forms + validation (v1.5.0)

`Form` + `TextFormField` gained source-level support with `validator:` closures returning `String?`. 0.x validation patterns that lived entirely in host callbacks can move inline. This is additive; no breaking changes.

### Navigation + routing (v1.6.0)

`Navigator.push(MaterialPageRoute(...))` works at the source level. 0.x users routing navigation through host `onEvent` callbacks can keep doing so; the new style is purely additive.

### Bridge packaging (v1.11.0 onward)

Cupertino, Provider, and go_router integrations moved out of the main package and into sibling bridge packages. If your 0.x code tried to use `CupertinoButton` or similar against the default registry, it will throw `UnregisteredBuilderException`. Fix:

```dart
final config = RuneConfig.defaults()
    .withBridges(const [CupertinoBridge()]);
```

Likewise for `ChangeNotifierProvider` / `Consumer` / `Selector` (add `ProviderBridge`) and `GoRoute` / `GoRouter` / `GoRouterApp` (add `RouterBridge`). See the main README's "Bridge packages" section.

## Between 1.x minors

### 1.x within the series

Every 1.x minor is source-compatible with its predecessor. The CHANGELOG records each release's additions and any deferred scope. See [`CHANGELOG.md`](CHANGELOG.md) for the full series.

If you upgrade from v1.11.0 or older to v1.12.0+, the ten v1.x deferred items (ListenableBuilder, CheckedPopupMenuItem, BottomSheet, PaginatedDataTable, PageRouteBuilder, SnackBarAction, RelativeRect.fromLTRB, FilledButton.tonal, Navigator.popUntil, showMenu) become available in source. Existing source strings keep rendering the same way.

### Sibling bridge packages (independent version tracks)

`rune_cupertino`, `rune_provider`, `rune_router`, and `rune_responsive_sizer` ship on independent `0.y.z` version tracks. Minor bumps on one bridge never require a main-package upgrade; major bumps (when they eventually happen) will be documented in the bridge package's own CHANGELOG.

## Opening an issue

Found a migration you can't resolve from this guide? Open an issue with the bug-report template and include:

- The old and new Rune versions.
- The exact `RuneView.source` string and `data` map.
- The error (`RuneException` variant + caret-pointer block, or a Flutter runtime error).

We'll answer, fix the bug if there is one, and document the fix here.
