/// Rune GoRouter bridge.
///
/// Registers a narrow subset of [go_router](https://pub.dev/packages/go_router)
/// on a `RuneConfig` so Rune source can declare routing structure
/// without escaping into the host app. Consumers apply the bridge
/// via `RuneConfig.withBridges`:
///
/// ```dart
/// final config = RuneConfig.defaults()
///     .withBridges(const [RouterBridge()]);
/// ```
///
/// v0.1.0 scope:
/// - `GoRoute` value builder: `GoRoute(path, builder)` declares one
///   route with a `(ctx, state) -> Widget` closure.
/// - `GoRouter` value builder: `GoRouter(initialLocation, routes)`
///   constructs a `GoRouter` instance from a list of `GoRoute`s.
/// - `GoRouterApp` widget: wraps `MaterialApp.router(routerConfig:
///   router)` so the source can return an app-level widget that
///   installs the router at the root of the tree.
///
/// Source-level imperatives (`context.go('/path')`,
/// `context.push('/path')`) stay deferred until the main `rune`
/// package grows a pluggable imperative registry. Host apps that
/// need programmatic navigation keep a reference to the `GoRouter`
/// instance in their data context and call `.go(...)` / `.push(...)`
/// from `onEvent` callbacks.
library rune_router;

export 'src/router_bridge.dart' show RouterBridge;
