import 'package:go_router/go_router.dart';
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
/// When constructed with `RouterBridge(router: myRouter)`, the bridge
/// also registers six prefixed imperatives on `config.imperatives`:
/// `Router.go`, `Router.push`, `Router.pop`, `Router.pushReplacement`,
/// `Router.goNamed`, and `Router.pushNamed`. Rune source can then drive
/// navigation directly:
///
/// ```
/// ElevatedButton(
///   onPressed: () => Router.go('/settings'),
///   child: Text('Settings'),
/// )
/// ```
///
/// The plain `const RouterBridge()` form (no router) skips the
/// imperative registrations and leaves navigation to the host app.
///
/// Duplicate-name collisions with the main-package defaults are
/// impossible: none of `GoRoute`, `GoRouter`, or `GoRouterApp`
/// appear in the default Rune registry, and `Router.*` is reserved
/// for router bridges.
final class RouterBridge implements RuneBridge {
  /// Creates a bridge. Pass [router] to additionally register the
  /// six `Router.*` prefixed imperatives on `config.imperatives`.
  /// Leaving [router] null registers widget + value builders only.
  const RouterBridge({this.router});

  /// The router powering the source-level imperatives. `null` means
  /// the bridge only registers widget + value builders.
  final GoRouter? router;

  @override
  void registerInto(RuneConfig config) {
    config.values
      ..registerBuilder(const GoRouteBuilder())
      ..registerBuilder(const GoRouterBuilder());
    config.widgets.registerBuilder(const GoRouterAppBuilder());

    final r = router;
    if (r == null) return;

    config.imperatives
      ..registerPrefixed('Router', 'go', (args, ctx) {
        final loc = args.requirePositional<String>(0, source: 'Router.go');
        r.go(loc, extra: args.get<Object>('extra'));
        return null;
      })
      ..registerPrefixed('Router', 'push', (args, ctx) {
        final loc = args.requirePositional<String>(0, source: 'Router.push');
        return r.push<Object?>(loc, extra: args.get<Object>('extra'));
      })
      ..registerPrefixed('Router', 'pop', (args, ctx) {
        r.pop<Object?>(args.positionalAt<Object>(0));
        return null;
      })
      ..registerPrefixed('Router', 'pushReplacement', (args, ctx) {
        final loc = args.requirePositional<String>(
          0,
          source: 'Router.pushReplacement',
        );
        return r.pushReplacement<Object?>(
          loc,
          extra: args.get<Object>('extra'),
        );
      })
      ..registerPrefixed('Router', 'goNamed', (args, ctx) {
        final name = args.requirePositional<String>(
          0,
          source: 'Router.goNamed',
        );
        r.goNamed(
          name,
          pathParameters: _stringMap(
            args.get<Map<Object?, Object?>>('pathParameters'),
          ),
          queryParameters: _dynamicMap(
            args.get<Map<Object?, Object?>>('queryParameters'),
          ),
          extra: args.get<Object>('extra'),
        );
        return null;
      })
      ..registerPrefixed('Router', 'pushNamed', (args, ctx) {
        final name = args.requirePositional<String>(
          0,
          source: 'Router.pushNamed',
        );
        return r.pushNamed<Object?>(
          name,
          pathParameters: _stringMap(
            args.get<Map<Object?, Object?>>('pathParameters'),
          ),
          queryParameters: _dynamicMap(
            args.get<Map<Object?, Object?>>('queryParameters'),
          ),
          extra: args.get<Object>('extra'),
        );
      });
  }
}

Map<String, String> _stringMap(Map<Object?, Object?>? src) {
  if (src == null) return const <String, String>{};
  return <String, String>{
    for (final entry in src.entries) '${entry.key}': '${entry.value}',
  };
}

Map<String, dynamic> _dynamicMap(Map<Object?, Object?>? src) {
  if (src == null) return const <String, dynamic>{};
  return <String, dynamic>{
    for (final entry in src.entries) '${entry.key}': entry.value,
  };
}
