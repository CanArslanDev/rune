# rune_router

go_router ([`go_router`](https://pub.dev/packages/go_router)) bridge for the [`rune`](../..) package. Registers `GoRoute` and `GoRouter` value builders plus a `GoRouterApp` widget wrapper on a `RuneConfig` so Rune source can declare routed navigation structure.

## What the bridge adds

### Values (2)

| Type name   | Backed by | Notes                                                                                                                                                                      |
| ----------- | --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `GoRoute`   | `GoRoute` | Required: `path:` (String), `builder:` (closure `(ctx, state) -> Widget`). Optional: `name:`, `routes:` (nested list). Non-GoRoute list entries are filtered out silently. |
| `GoRouter`  | `GoRouter` | Required: `routes:` (List). Optional: `initialLocation:` (defaults to `/`), `debugLogDiagnostics:` (bool).                                                                  |

### Widgets (1)

| Type name      | Backed by                        | Notes                                                                                                            |
| -------------- | -------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `GoRouterApp`  | `MaterialApp.router(routerConfig:)` | Required: `router:` (GoRouter). Optional: `title:`, `theme:`, `debugShowCheckedModeBanner:`. Installs the supplied router at the app root. |

## Scope

v0.1.0 ships a focused declarative surface: inline route declarations, nested routes via the `routes:` slot on `GoRoute`, and a `MaterialApp.router`-shaped root widget. Source-level imperatives (`context.go('/path')`, `context.push('/path')`) stay deferred until the main `rune` package grows a pluggable imperative registry; until then, host apps keep a reference to the `GoRouter` instance and call `.go(...)` / `.push(...)` from `onEvent` callbacks.

## Requirements

- Flutter >= 3.22
- Dart >= 3.4
- `rune` (sibling package in the same monorepo; current dep: `path: ../..`)
- `go_router` ^14.0.0

## Install

```yaml
dependencies:
  rune: ^1.13.0
  rune_router: ^0.1.0
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:rune/rune.dart';
import 'package:rune_router/rune_router.dart';

void main() {
  runApp(
    RuneView(
      config: RuneConfig.defaults()
          .withBridges(const [RouterBridge()]),
      source: r'''
        GoRouterApp(
          router: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (ctx, state) => Scaffold(
                  appBar: AppBar(title: Text('Home')),
                  body: Center(
                    child: ElevatedButton(
                      onPressed: 'go-settings',
                      child: Text('Settings'),
                    ),
                  ),
                ),
              ),
              GoRoute(
                path: '/settings',
                builder: (ctx, state) => Scaffold(
                  appBar: AppBar(title: Text('Settings')),
                  body: Center(child: Text('Hello from settings.')),
                ),
              ),
            ],
          ),
        )
      ''',
      onEvent: (name, [args]) {
        // Host handles navigation through a reference to the router.
      },
    ),
  );
}
```

Pass the router instance into `data:` and navigate from the host:

```dart
final router = GoRouter(/* ... */);
RuneView(
  data: {'router': router},
  source: "GoRouterApp(router: router)",
);
// Host-side: router.go('/settings');
```

## License

MIT. See [LICENSE](LICENSE).
