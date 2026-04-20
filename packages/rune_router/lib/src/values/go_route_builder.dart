import 'package:go_router/go_router.dart';
import 'package:rune/rune.dart';
import 'package:rune_router/src/closure_helpers.dart';

/// Builds a single [GoRoute] record from Rune source.
///
/// Supported named arguments:
/// - `path` ([String], required) - route pattern (e.g. `/`,
///   `/settings`, `/users/:id`).
/// - `builder` (closure `(ctx, state) -> Widget`, required) -
///   invoked when the route matches. Closure body must resolve to a
///   `Widget` at invocation time.
/// - `name` ([String]?) - optional name for named navigation.
/// - `routes` (`List<GoRoute>`?) - optional nested sub-routes.
///
/// Error paths: missing `path:` or `builder:` raise
/// [ArgumentException]; closures of the wrong arity raise
/// [ArgumentException] too; a closure body resolving to a non-Widget
/// surfaces as [ResolveException] at navigation time.
final class GoRouteBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const GoRouteBuilder();

  @override
  String get typeName => 'GoRoute';

  @override
  String? get constructorName => null;

  @override
  GoRoute build(ResolvedArguments args, RuneContext ctx) {
    final path = args.require<String>('path', source: 'GoRoute');
    final builder = toGoRouteBuilder(args.named['builder'], 'GoRoute');
    final name = args.get<String>('name');
    final nested = args.get<List<Object?>>('routes');
    final routes = nested == null
        ? const <GoRoute>[]
        : nested.whereType<GoRoute>().toList();
    return GoRoute(
      path: path,
      name: name,
      builder: builder,
      routes: routes,
    );
  }
}
