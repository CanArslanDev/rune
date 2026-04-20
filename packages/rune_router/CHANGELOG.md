# Changelog

All notable changes to this package are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
