import 'package:rune/rune.dart';
import 'package:rune_router/src/values/go_route_builder.dart';
import 'package:rune_router/src/values/go_router_builder.dart';
import 'package:rune_router/src/widgets/go_router_app_builder.dart';

/// A [RuneBridge] that registers the `GoRoute` and `GoRouter` value
/// builders plus a `GoRouterApp` widget wrapper on a [RuneConfig].
///
/// Registered values:
/// - `GoRoute` - one route record; takes `path:` (required) and
///   `builder:` (a 2-arity `(BuildContext, GoRouterState) -> Widget`
///   closure).
/// - `GoRouter` - composed router built from a `routes:` list; takes
///   an optional `initialLocation:` (defaults to `/`).
///
/// Registered widgets:
/// - `GoRouterApp` - installs a given `GoRouter` at the root of the
///   tree through Flutter's `MaterialApp.router` constructor.
///
/// Duplicate-name collisions with the main-package defaults are
/// impossible: none of `GoRoute`, `GoRouter`, or `GoRouterApp`
/// appear in the default Rune registry.
final class RouterBridge implements RuneBridge {
  /// Const constructor. The bridge is stateless.
  const RouterBridge();

  @override
  void registerInto(RuneConfig config) {
    config.values
      ..registerBuilder(const GoRouteBuilder())
      ..registerBuilder(const GoRouterBuilder());
    config.widgets.registerBuilder(const GoRouterAppBuilder());
  }
}
