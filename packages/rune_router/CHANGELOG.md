# Changelog

All notable changes to this package are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-04-21

### Added

- **`RouterBridge(router: myRouter)` registers six `Router.*`
  prefixed imperatives on `config.imperatives`.** When a `GoRouter`
  is supplied to the bridge constructor, Rune source can drive
  navigation directly without bouncing through `onEvent` + host
  Dart:

  ```dart
  final router = GoRouter(...);
  final config = RuneConfig.defaults()
      .withBridges([RouterBridge(router: router)]);
  ```

  Registered imperatives:
  - `Router.go(location, extra?)` - replace the current stack.
  - `Router.push(location, extra?)` - push and return the result
    future.
  - `Router.pop([result])` - pop the top route with an optional
    result.
  - `Router.pushReplacement(location, extra?)` - replace the top
    route.
  - `Router.goNamed(name, pathParameters?, queryParameters?, extra?)`
    - route-by-name navigation.
  - `Router.pushNamed(name, pathParameters?, queryParameters?, extra?)`
    - route-by-name push.

  Source can invoke them as ordinary expressions:

  ```
  ElevatedButton(
    onPressed: () => Router.go('/settings'),
    child: Text('Settings'),
  )
  ```

- The plain `const RouterBridge()` form (no router) remains
  unchanged: widget + value builders are registered, and source
  keeps navigating through host-side `onEvent` callbacks.

### Notes

- Requires `rune ^1.19.0` (unchanged; the `ImperativeRegistry`
  itself landed in v1.16.0).
- No existing source breaks: the `const RouterBridge()` constructor
  still exists and still registers exactly what v0.1.0 did.

## [0.1.0] - 2026-04-20

### Added

- First release of `rune_router`. Registers two value builders and
  one widget builder on a `RuneConfig` via `RouterBridge`:
  - `GoRoute(path, builder, name?, routes?)` value builder. The
    `builder` closure is 2-arity `(BuildContext, GoRouterState) ->
    Widget`; closures of the wrong arity raise `ArgumentException`
    at registration time.
  - `GoRouter(routes, initialLocation?, debugLogDiagnostics?)`
    value builder. Non-GoRoute entries in `routes:` are filtered
    out silently so conditional `[if (...)]` constructs compose
    cleanly.
  - `GoRouterApp(router, title?, theme?, debugShowCheckedModeBanner?)`
    widget. Wraps `MaterialApp.router(routerConfig: router)` so the
    source can install the router at the app root.
- Source-level imperatives (`context.go('/path')`,
  `context.push('/path')`) remain out of scope for v0.1.0. Host
  apps navigate by keeping a reference to the `GoRouter` and
  calling `.go(...)` / `.push(...)` from `onEvent` callbacks.
