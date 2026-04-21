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

### Source-level imperatives (6, v0.2.0+)

When the bridge is constructed with `RouterBridge(router: myRouter)`, it also registers six prefixed imperatives on `config.imperatives` so Rune source can navigate without bouncing through host Dart:

| Call from source                                                      | Backed by                                 |
| --------------------------------------------------------------------- | ----------------------------------------- |
| `Router.go('/path', extra?)`                                          | `GoRouter.go`                             |
| `Router.push('/path', extra?)`                                        | `GoRouter.push`                           |
| `Router.pop([result])`                                                | `GoRouter.pop`                            |
| `Router.pushReplacement('/path', extra?)`                             | `GoRouter.pushReplacement`                |
| `Router.goNamed('name', pathParameters?, queryParameters?, extra?)`   | `GoRouter.goNamed`                        |
| `Router.pushNamed('name', pathParameters?, queryParameters?, extra?)` | `GoRouter.pushNamed`                      |

The plain `const RouterBridge()` form keeps the v0.1.0 behavior: only widget + value builders are registered and navigation stays host-driven.

## Requirements

- Flutter >= 3.22
- Dart >= 3.4
- `rune` ^1.19.0
- `go_router` ^14.0.0

## Install

```yaml
dependencies:
  rune: ^1.19.0
  rune_router: ^0.2.0
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

### Source-level navigation (v0.2.0+)

Supply the `GoRouter` instance to `RouterBridge` and source can navigate directly:

```dart
final router = GoRouter(/* ... */);
final config = RuneConfig.defaults()
    .withBridges([RouterBridge(router: router)]);

RuneView(
  config: config,
  source: """
    ElevatedButton(
      onPressed: () => Router.go('/settings'),
      child: Text('Settings'),
    )
  """,
);
```

## License

MIT. See [LICENSE](LICENSE).
