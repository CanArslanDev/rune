import 'package:flutter/widgets.dart';
import 'package:rune/rune.dart';
// ignore: implementation_imports
import 'package:rune/src/resolver/rune_closure.dart' show RuneClosure;

/// Validates [source] is a [RuneClosure] with [expectedArity] and
/// returns it. Throws [ArgumentException] citing [widgetName] and
/// [slotName] on null / wrong-type / wrong-arity.
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

/// Wraps a 3-arity closure into `(BuildContext, T, Widget?) ->
/// Widget` shape. Matches `RiverpodConsumer.builder`.
Widget Function(BuildContext, T, Widget?) toBuilder<T>(
  Object? source, {
  required String widgetName,
}) {
  final closure = requireClosure(
    source: source,
    widgetName: widgetName,
    slotName: 'builder',
    expectedArity: 3,
  );
  return (ctx, value, child) {
    final result = closure.call(<Object?>[ctx, value, child]);
    if (result is! Widget) {
      throw ResolveException(
        widgetName,
        '$widgetName.builder closure must return a Widget; '
        'got ${result.runtimeType}',
      );
    }
    return result;
  };
}
