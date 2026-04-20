import 'package:go_router/go_router.dart';
import 'package:rune/rune.dart';

/// Builds a [GoRouter] instance from Rune source.
///
/// Supported named arguments:
/// - `routes` (`List<GoRoute>`, required) - the top-level route
///   records. Items that are not [GoRoute] are silently filtered out
///   so conditional `[if (...)]` constructs in the source compose
///   cleanly; an explicit empty list is acceptable.
/// - `initialLocation` ([String]?) - starting path. Defaults to `/`.
/// - `debugLogDiagnostics` ([bool]?) - forward to [GoRouter].
///
/// Returns the router instance. Callers pair it with `GoRouterApp`
/// to install it at the root of the tree.
final class GoRouterBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const GoRouterBuilder();

  @override
  String get typeName => 'GoRouter';

  @override
  String? get constructorName => null;

  @override
  GoRouter build(ResolvedArguments args, RuneContext ctx) {
    final rawRoutes = args.require<List<Object?>>(
      'routes',
      source: 'GoRouter',
    );
    final routes = rawRoutes.whereType<GoRoute>().toList();
    return GoRouter(
      routes: routes,
      initialLocation: args.get<String>('initialLocation') ?? '/',
      debugLogDiagnostics: args.get<bool>('debugLogDiagnostics') ?? false,
    );
  }
}
