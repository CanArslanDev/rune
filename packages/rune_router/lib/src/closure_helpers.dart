import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rune/rune.dart';
// ignore: implementation_imports
import 'package:rune/src/resolver/rune_closure.dart' show RuneClosure;

/// Validates [source] is a [RuneClosure] with the given [expectedArity]
/// and returns it. Throws [ArgumentException] citing [widgetName] and
/// [slotName] for null / wrong-type / wrong-arity cases.
RuneClosure requireClosure({
  required Object? source,
  required String widgetName,
  required String slotName,
  required int expectedArity,
}) {
  if (source == null) {
    throw ArgumentException(
      widgetName,
      '$widgetName.$slotName is required.',
    );
  }
  if (source is! RuneClosure) {
    throw ArgumentException(
      widgetName,
      '$widgetName.$slotName must be a closure; got ${source.runtimeType}.',
    );
  }
  if (source.parameterNames.length != expectedArity) {
    throw ArgumentException(
      widgetName,
      '$widgetName.$slotName closure must take $expectedArity '
      'argument(s); got ${source.parameterNames.length}.',
    );
  }
  return source;
}

/// Wraps a [RuneClosure] into the `(BuildContext, GoRouterState) ->
/// Widget` shape used by `GoRoute.builder`. Verifies arity-2 at
/// registration time and widget-returning body at call time.
Widget Function(BuildContext, GoRouterState) toGoRouteBuilder(
  Object? source,
  String typeName,
) {
  final closure = requireClosure(
    source: source,
    widgetName: typeName,
    slotName: 'builder',
    expectedArity: 2,
  );
  return (ctx, state) {
    final result = closure.call(<Object?>[ctx, state]);
    if (result is! Widget) {
      throw ResolveException(
        typeName,
        '$typeName.builder closure must return a Widget; '
        'got ${result.runtimeType}',
      );
    }
    return result;
  };
}
