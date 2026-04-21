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
/// Declarative scope:
/// - `GoRoute` value builder: `GoRoute(path, builder)` declares one
///   route with a `(ctx, state) -> Widget` closure.
/// - `GoRouter` value builder: `GoRouter(initialLocation, routes)`
///   constructs a `GoRouter` instance from a list of `GoRoute`s.
/// - `GoRouterApp` widget: wraps `MaterialApp.router(routerConfig:
///   router)` so the source can return an app-level widget that
///   installs the router at the root of the tree.
///
/// Source-level imperatives (v0.2.0+):
/// `RouterBridge(router: myRouter)` registers six `Router.*`
/// prefixed imperatives on `config.imperatives` so source can drive
/// navigation directly, without bouncing through `onEvent`:
/// `Router.go`, `Router.push`, `Router.pop`, `Router.pushReplacement`,
/// `Router.goNamed`, `Router.pushNamed`. The plain `const
/// RouterBridge()` form skips the imperative registrations and keeps
/// navigation host-driven.
library rune_router;

export 'src/router_bridge.dart' show RouterBridge;
